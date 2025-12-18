import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:commands_cli/command.dart';
import 'package:commands_cli/command_validator.dart';
import 'package:commands_cli/param.dart';

// Track commands with validation errors
final Map<String, String> _validationErrors = {};

Map<String, String> get commandValidationErrors => Map.unmodifiable(_validationErrors);

Map<String, Command> loadCommandsFrom(File yaml) {
  _validationErrors.clear(); // Clear previous errors
  final lines = yaml.readAsLinesSync();
  final result = <String, Command>{};

  String? currentCommand;
  String? currentCommandDescription;
  String? currentParamName;
  String? currentParamType; // 'required' or 'optional'
  int? paramsIndentLevel; // Indentation level where 'params:' was found
  Map<String, Param> tempParams = {};
  Map<String, dynamic> tempCommandMap = {};

  // Current param metadata being built
  Map<String, dynamic> currentParamMetadata = {};

  // Switch parsing state
  List<Map<String, dynamic>> switchStack = []; // Stack of switch maps for nested switches
  List<int> switchIndentStack = []; // Stack of indentation levels for switches
  String? currentSwitchName; // Current switch name being parsed
  String? currentSwitchDescription; // Description for current switch
  String? currentSwitchFlags; // Flags for current switch

  // Multiline command capture state
  bool capturingMultilineCommand = false;
  final multilineBuffer = <String>[];
  int multilineBaseIndent = 0; // indent of the "script:" line
  int? multilineContentIndent; // indent of the first non-empty content line

  int indentOf(String s) => s.length - s.trimLeft().length;

  // Helper to get the current map where we should add content
  Map<String, dynamic> getCurrentTargetMap() {
    if (currentSwitchName != null && switchStack.isNotEmpty) {
      return switchStack.last[currentSwitchName] as Map<String, dynamic>;
    }
    return tempCommandMap;
  }

  // Helper to finalize a parameter with collected metadata
  void finalizeCurrentParam() {
    if (currentParamName == null) return;

    final existing = tempParams[currentParamName];
    if (existing == null) return;

    final type = currentParamMetadata['type'] as String?;
    final values = currentParamMetadata['values'] as List<String>?;
    final defaultValue = currentParamMetadata['default'] as String?;

    // Boolean type inference only if no type and no default explicitly set
    String? effectiveType = type;

    // Validate enum values against explicit type (only if type is explicitly set)
    if (type != null && values != null && values.isNotEmpty && currentParamMetadata['isTypeExplicit'] == true) {
      final enumValidation = EnumTypeValidator.validateEnumValues(currentParamName, type, values);
      if (!enumValidation.isValid && currentCommand != null) {
        _validationErrors[currentCommand] = enumValidation.errorMessage ?? 'validation error';
        currentParamName = null;
        currentParamMetadata = {};
        return;
      }
    }

    // If type, values, or default were specified, rebuild the param
    if (type != null || values != null || defaultValue != null) {
      final updated = Param(
        name: existing.name,
        description: currentParamMetadata['description'] as String? ?? existing.description,
        defaultValue: defaultValue ?? existing.defaultValue,
        flags: currentParamMetadata['flags'] as String? ?? existing.flags,
        type: effectiveType,
        values: values,
        isTypeExplicit: currentParamMetadata['isTypeExplicit'] as bool? ?? false,
      );

      tempParams[currentParamName!] = updated;

      // Replace in list
      final targetMap = getCurrentTargetMap();
      targetMap['params'] ??= {'required': <Param>[], 'optional': <Param>[]};

      final paramsMap = targetMap['params'];
      if (paramsMap is Map && currentParamType != null) {
        final paramList = paramsMap[currentParamType];
        if (paramList is List<Param>) {
          final idx = paramList.indexWhere((p) => p.name == currentParamName);
          if (idx != -1) {
            paramList[idx] = updated;
          }
        }
      }
    }

    currentParamName = null;
    currentParamMetadata = {};
  }

  // Helper to safely add param to the targetMap
  void addParamToTargetMap(Map<String, dynamic> targetMap, String? paramType, Param param) {
    targetMap['params'] ??= {'required': <Param>[], 'optional': <Param>[]};
    if (paramType != null && targetMap['params'] is Map) {
      final paramsList = (targetMap['params'] as Map)[paramType];
      if (paramsList is List<Param>) {
        paramsList.add(param);
      }
    }
  }

  void finalizeCurrentCommand() {
    if (currentCommand != null) {
      // Validate command structure before building
      final validationResult = CommandValidator.validate(currentCommand, tempCommandMap);
      if (!validationResult.isValid) {
        // Store error and skip this command
        _validationErrors[currentCommand] = validationResult.errorMessage ?? 'validation error';
        return;
      }
    }

    final command = _buildCommand(tempCommandMap, currentCommandDescription);
    if (currentCommand != null) {
      result[currentCommand] = command;
    }
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    // Handle multiline command continuation
    if (capturingMultilineCommand) {
      final lineIndent = indentOf(line);

      // If we hit a non-empty line whose indent is <= base indent, the block ends
      if (trimmed.isNotEmpty && lineIndent <= multilineBaseIndent) {
        // finalize block (do NOT consume current line; process it below)
        final scriptContent = multilineBuffer.join('\n');
        final targetMap = getCurrentTargetMap();
        targetMap['script'] = scriptContent;

        multilineBuffer.clear();
        capturingMultilineCommand = false;
        multilineContentIndent = null;
        // fall through to process current line
      } else {
        // Still inside block
        if (trimmed.isEmpty) {
          multilineBuffer.add('');
        } else {
          multilineContentIndent ??= lineIndent;
          final cut = multilineContentIndent;
          final content = line.length > cut ? line.substring(cut) : trimmed; // safe cut
          multilineBuffer.add(content);
        }
        continue;
      }
    }

    // Match command name + description (description is optional)
    // If we see a command at indent level 0, start a new command regardless of context
    final commandMatch = RegExp(r'^([a-zA-Z0-9_-]+!?):\s*(?:##\s*(.+))?').firstMatch(trimmed);
    final currentIndent = indentOf(line);

    if (commandMatch != null && (switchStack.isEmpty || currentIndent == 0)) {
      final potentialCommand = commandMatch[1]!.toLowerCase();
      // We need to make sure this isn't a keyword for another section.
      final reserved = [
        'override',
        'script',
        'params',
        'required',
        'optional',
        'default',
        'switch',
        'flags',
        'description',
        'type',
        'values',
      ];
      if (!reserved.contains(potentialCommand)) {
        if (currentCommand != null) {
          finalizeCurrentParam(); // Finalize any pending parameter
          finalizeCurrentCommand();
          tempCommandMap = {};
          switchStack.clear(); // Clear switch context when starting new top-level command
          switchIndentStack.clear();
          currentSwitchName = null;
          currentSwitchDescription = null;
          currentParamName = null; // Reset param context
          currentParamType = null;
          paramsIndentLevel = null;
          tempParams = {};
          currentParamMetadata = {};
        }
        currentCommand = potentialCommand;
        currentCommandDescription = commandMatch[2]; // null if no description
        continue;
      }
    }

    if (trimmed.isEmpty) continue;

    if (trimmed.startsWith('override:')) {
      tempCommandMap['override'] = trimmed.substring('override:'.length).trim().toLowerCase() == 'true';
      continue;
    }

    // Match command text
    if (trimmed.startsWith('script:')) {
      multilineBaseIndent = indentOf(line);

      final targetMap = getCurrentTargetMap();

      if (trimmed.endsWith('|')) {
        capturingMultilineCommand = true;
        multilineBuffer.clear();
        multilineContentIndent = null;
        continue;
      } else {
        targetMap['script'] = trimmed.substring('script:'.length).trim();
        continue;
      }
    }

    if (trimmed.startsWith('params:')) {
      final targetMap = getCurrentTargetMap();
      targetMap['params'] = {'required': <Param>[], 'optional': <Param>[]};
      paramsIndentLevel = indentOf(line); // Track where params section starts
      continue;
    }

    // Handle switch keyword
    if (trimmed.startsWith('switch:')) {
      final switchMap = <String, dynamic>{};

      // Determine which map to add the switch to
      if (currentSwitchName != null && switchStack.isNotEmpty) {
        // Nested switch: add to current switch's map
        final parentSwitchMap = switchStack.last[currentSwitchName] as Map<String, dynamic>;
        parentSwitchMap['switch'] = switchMap;
        switchStack.add(switchMap);
      } else {
        // Top-level switch: add to command map
        tempCommandMap['switch'] = switchMap;
        switchStack.add(switchMap);
      }

      switchIndentStack.add(indentOf(line));
      currentSwitchName = null; // Reset for next switch name
      continue;
    }

    // Check if we're exiting a switch level based on indentation
    while (switchIndentStack.isNotEmpty && indentOf(line) <= switchIndentStack.last && trimmed.isNotEmpty) {
      switchIndentStack.removeLast();
      switchStack.removeLast();
      // When exiting a switch, also exit any params context
      paramsIndentLevel = null;
      currentParamType = null;
      currentParamName = null;
      // Note: Don't reset currentSwitchName here, it's handled when we enter a new switch
    }

    // Check if we're exiting params section based on indentation
    // If we're in params and encounter a line at or shallower than params: indent, exit params context
    if (paramsIndentLevel != null && trimmed.isNotEmpty) {
      // Allow exiting params for non-list items OR list items at switch level (not param list items)
      final isParamListItem = trimmed.startsWith('-') && indentOf(line) > paramsIndentLevel;
      if (!isParamListItem && indentOf(line) <= paramsIndentLevel) {
        // We've exited the params section
        currentParamType = null;
        currentParamName = null;
        paramsIndentLevel = null;
      }
    }

    // Check if this is a switch name definition
    // Patterns to match:
    // 1. - switchName: ## description
    // 2. - switchName:
    // 3. - default: switchReference (special case - string on same line)
    // 4. - default: (will have nested definition)
    // 5. switchName: (without dash, for backwards compatibility)
    // NOTE: Don't match param defaults (those have currentParamName set)
    // NOTE: Don't match params inside a params section (paramsIndentLevel != null)
    if (switchStack.isNotEmpty && currentParamName == null && paramsIndentLevel == null) {
      // Remove leading "- " if present (YAML list item)
      final switchLine = trimmed.startsWith('- ') ? trimmed.substring(2).trim() : trimmed;

      // Skip param list items (they start with "- paramName:")
      if (trimmed.startsWith('-') && !switchLine.contains(':')) {
        continue;
      }

      // Special handling for default: value (string reference)
      if (switchLine.startsWith('default:')) {
        final defaultValue = switchLine.substring('default:'.length).trim();
        if (defaultValue.isNotEmpty && !defaultValue.startsWith('##')) {
          // It's a string reference to another switch
          switchStack.last['default'] = defaultValue;
          continue;
        } else {
          // It's either "default: ## desc" or "default:" (will have nested definition)
          currentSwitchName = 'default';
          currentSwitchDescription = defaultValue.startsWith('##') ? defaultValue.substring(2).trim() : null;
          currentSwitchFlags = null;

          // Create a new map for default switch
          final switchCommandMap = <String, dynamic>{};
          if (currentSwitchDescription != null) {
            switchCommandMap['description'] = currentSwitchDescription;
          }

          switchStack.last['default'] = switchCommandMap;
          continue;
        }
      }

      // Match regular switch name with optional flags and/or description
      // Formats supported:
      // 1. switchName: "flags" ## description
      // 2. switchName: 'flags' ## description
      // 3. switchName: flags ## description (unquoted)
      // 4. switchName: ## description (no flags)
      // 5. switchName: (no flags, no description)

      // Try to match with double-quoted flags
      var switchNameMatch = RegExp(r'^([a-zA-Z0-9_-]+):\s*"([^"]*)"\s*(?:##\s*(.+))?$').firstMatch(switchLine);
      String? matchedFlags;
      String? matchedDescription;
      String? potentialSwitchName;

      if (switchNameMatch != null) {
        potentialSwitchName = switchNameMatch[1];
        matchedFlags = switchNameMatch[2];
        matchedDescription = switchNameMatch[3];
      } else {
        // Try single-quoted flags
        switchNameMatch = RegExp(r"^([a-zA-Z0-9_-]+):\s*'([^']*)'\s*(?:##\s*(.+))?$").firstMatch(switchLine);
        if (switchNameMatch != null) {
          potentialSwitchName = switchNameMatch[1];
          matchedFlags = switchNameMatch[2];
          matchedDescription = switchNameMatch[3];
        } else {
          // Try unquoted flags (must not start with # and must have non-whitespace)
          switchNameMatch = RegExp(r'^([a-zA-Z0-9_-]+):\s*([^\s#][^#\n]*?)\s*(?:##\s*(.+))?$').firstMatch(switchLine);
          if (switchNameMatch != null) {
            potentialSwitchName = switchNameMatch[1];
            matchedFlags = switchNameMatch[2]?.trim();
            matchedDescription = switchNameMatch[3];
          } else {
            // Try no flags, just description or nothing
            switchNameMatch = RegExp(r'^([a-zA-Z0-9_-]+):\s*(?:##\s*(.+))?$').firstMatch(switchLine);
            if (switchNameMatch != null) {
              potentialSwitchName = switchNameMatch[1];
              matchedFlags = null;
              matchedDescription = switchNameMatch[2];
            }
          }
        }
      }

      if (potentialSwitchName != null) {
        // Don't treat reserved keywords as switch names
        if (![
          'params',
          'required',
          'optional',
          'script',
          'override',
          'flags',
          'description',
        ].contains(potentialSwitchName)) {
          // Reset param context when entering a new switch
          currentParamName = null;
          currentParamType = null;
          paramsIndentLevel = null;

          currentSwitchName = potentialSwitchName;
          currentSwitchDescription = matchedDescription;
          currentSwitchFlags = matchedFlags;

          // Create a new map for this switch
          final switchCommandMap = <String, dynamic>{};
          if (currentSwitchDescription != null) {
            switchCommandMap['description'] = currentSwitchDescription;
          }
          if (currentSwitchFlags != null) {
            switchCommandMap['flags'] = currentSwitchFlags;
          }

          // Add to the current switch level
          switchStack.last[currentSwitchName] = switchCommandMap;

          // If this switch might have nested content, prepare to parse it
          // (we'll need to check subsequent lines)
          continue;
        }
      }
    }

    // Check for 'flags:' and 'description:' keys within a switch
    if (currentSwitchName != null && switchStack.isNotEmpty) {
      if (trimmed.startsWith('flags:')) {
        final flagsValue = trimmed.substring('flags:'.length).trim();
        currentSwitchFlags = flagsValue.replaceAll('"', '').replaceAll("'", "");
        final switchCommandMap = switchStack.last[currentSwitchName] as Map<String, dynamic>;
        switchCommandMap['flags'] = currentSwitchFlags;
        continue;
      }

      if (trimmed.startsWith('description:')) {
        final descValue = trimmed.substring('description:'.length).trim();
        currentSwitchDescription = descValue.replaceAll('"', '').replaceAll("'", "");
        final switchCommandMap = switchStack.last[currentSwitchName] as Map<String, dynamic>;
        switchCommandMap['description'] = currentSwitchDescription;
        continue;
      }
    }

    // Check if we're in required/optional params
    final reqOptMatch = RegExp(r'^(required|optional):').firstMatch(trimmed);
    if (reqOptMatch != null) {
      currentParamType = reqOptMatch[1];
      continue;
    }

    // --- PARAM MATCHING ---

    // Case: - name: 'flags' ## description  OR - name: 'flags'  (single-quoted)
    final paramMatchWithFlagsSingle = RegExp(r"^-\s*(\w+):\s*'([^']*)'\s*(?:##\s*(.+))?$").firstMatch(trimmed);

    // Case: - name: "flags" ## description  OR - name: "flags"  (double-quoted)
    final paramMatchWithFlagsDouble = RegExp(r'^-\s*(\w+):\s*"([^"]*)"\s*(?:##\s*(.+))?$').firstMatch(trimmed);

    // Case: - name: unquoted-flags ## description OR - name: unquoted-flags
    // Require at least one non-space, non-# char before the optional "##" so we don't
    // accidentally capture a lone space as "flags" in lines like "- name: ## desc".
    final paramMatchUnquotedFlags = RegExp(r'^-\s*(\w+):\s*([^\s#][^#\n]*?)\s*(?:##\s*(.+))?$').firstMatch(trimmed);

    // Case: - name: ## description  (no flags, only description)
    final paramMatchSimple = RegExp(r'^-\s*(\w+):\s*##\s*(.+)?$').firstMatch(trimmed);

    // Case: - name:   (no description, no flags) - must be strict/anchored
    final paramMatchBare = RegExp(r'^-\s*(\w+):\s*$').firstMatch(trimmed);

    final paramMatchBareNoColon = RegExp(r'^-\s*(\w+)\s*$').firstMatch(trimmed);

    if (paramMatchBareNoColon != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchBareNoColon[1]!;
      currentParamMetadata = {'name': currentParamName!};
      final param = Param(name: currentParamName!);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    // Now check matches in order: flags-first, then description-only, then bare.
    if (paramMatchWithFlagsSingle != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchWithFlagsSingle[1]!;
      final flagsRaw = paramMatchWithFlagsSingle[2]!.trim();
      final flags = flagsRaw.isEmpty ? null : flagsRaw;
      final paramDescription = paramMatchWithFlagsSingle[3];
      currentParamMetadata = {'name': currentParamName!, 'flags': flags, 'description': paramDescription};
      final param = Param(name: currentParamName!, description: paramDescription, flags: flags);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    if (paramMatchWithFlagsDouble != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchWithFlagsDouble[1]!;
      final flagsRaw = paramMatchWithFlagsDouble[2]!.trim();
      final flags = flagsRaw.isEmpty ? null : flagsRaw;
      final paramDescription = paramMatchWithFlagsDouble[3];
      currentParamMetadata = {'name': currentParamName!, 'flags': flags, 'description': paramDescription};
      final param = Param(name: currentParamName!, description: paramDescription, flags: flags);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    if (paramMatchUnquotedFlags != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchUnquotedFlags[1]!;
      final flagsRaw = paramMatchUnquotedFlags[2]!.trim();
      final flags = flagsRaw.isEmpty ? null : flagsRaw;
      final paramDescription = paramMatchUnquotedFlags[3];
      currentParamMetadata = {'name': currentParamName!, 'flags': flags, 'description': paramDescription};
      final param = Param(name: currentParamName!, description: paramDescription, flags: flags);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    if (paramMatchSimple != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchSimple[1]!;
      final paramDescription = paramMatchSimple[2]!;
      currentParamMetadata = {'name': currentParamName!, 'description': paramDescription};
      final param = Param(name: currentParamName!, description: paramDescription);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    if (paramMatchBare != null && currentParamType != null) {
      finalizeCurrentParam(); // Finalize previous param if any
      currentParamName = paramMatchBare[1]!;
      currentParamMetadata = {'name': currentParamName!};
      final param = Param(name: currentParamName!);
      tempParams[currentParamName!] = param;
      final targetMap = getCurrentTargetMap();

      addParamToTargetMap(targetMap, currentParamType, param);
      continue;
    }

    // Match type field for param
    final typeMatch = RegExp(r'^type:\s*(.+)$').firstMatch(trimmed);
    if (typeMatch != null && currentParamName != null) {
      var typeValue = typeMatch[1]!.trim();
      // Strip surrounding quotes if present
      if ((typeValue.startsWith('"') && typeValue.endsWith('"')) ||
          (typeValue.startsWith("'") && typeValue.endsWith("'"))) {
        typeValue = typeValue.substring(1, typeValue.length - 1);
      }

      // Validate type value
      const validTypes = ['boolean', 'string', 'int', 'double'];
      if (!validTypes.contains(typeValue)) {
        stderr.writeln(
            '❌ Invalid type "$typeValue" for parameter "$currentParamName". Must be one of: ${validTypes.join(', ')}');
        exit(1);
      }

      currentParamMetadata['type'] = typeValue;
      currentParamMetadata['isTypeExplicit'] = true; // Mark as explicit
      continue;
    }

    // Match values list for param (enum)
    // Format: values: [dev, staging, prod] or values: ['dev', 'staging', 'prod']
    final valuesMatch = RegExp(r'^values:\s*\[(.+)\]$').firstMatch(trimmed);
    if (valuesMatch != null && currentParamName != null) {
      final valuesRaw = valuesMatch[1]!;
      // Split by comma and clean up
      final valuesList = valuesRaw
          .split(',')
          .map((v) => v.trim())
          .map((v) {
            // Remove quotes if present
            if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
              return v.substring(1, v.length - 1);
            }
            return v;
          })
          .where((v) => v.isNotEmpty)
          .toList();

      if (valuesList.isEmpty) {
        stderr.writeln('❌ Parameter "$currentParamName" has empty values list');
        exit(1);
      }

      currentParamMetadata['values'] = valuesList;
      continue;
    }

    // Match default value for the most recent param
    final defaultMatch = RegExp(r'^default:\s*(.+)?').firstMatch(trimmed);
    if (defaultMatch != null && currentParamName != null) {
      final existing = tempParams[currentParamName]!;
      var defaultValue = defaultMatch[1]!;

      // Check if the value was quoted (before stripping)
      final wasQuoted = (defaultValue.startsWith('"') && defaultValue.endsWith('"')) ||
          (defaultValue.startsWith("'") && defaultValue.endsWith("'"));

      // Strip surrounding quotes if present
      if (wasQuoted) {
        defaultValue = defaultValue.substring(1, defaultValue.length - 1);
      }

      currentParamMetadata['default'] = defaultValue;

      // Now rebuild the param with all collected metadata
      final type = currentParamMetadata['type'] as String?;
      final values = currentParamMetadata['values'] as List<String>?;

      // Validation: quoted defaults incompatible with explicit non-string types
      final validationResult = CommandValidator.validateParamTypeCompatibility(
        currentParamName,
        type,
        defaultValue,
        wasQuoted,
      );
      final hasValidationError = !validationResult.isValid && currentCommand != null;
      if (hasValidationError) {
        // Store validation error for this command
        _validationErrors[currentCommand] = validationResult.errorMessage ?? 'validation error';
      }

      // Skip the rest of param building if there was a validation error
      if (!hasValidationError) {
        // Type inference: if type not provided, infer from default value
        String? effectiveType = type;
        if (effectiveType == null && values == null) {
          // If the value was quoted in YAML, treat it as a string
          if (wasQuoted) {
            effectiveType = 'string';
          }
          // Boolean: true/false
          else if (defaultValue == 'true' || defaultValue == 'false') {
            effectiveType = 'boolean';
          }
          // Integer: parseable as int without decimal point
          else if (int.tryParse(defaultValue) != null && !defaultValue.contains('.')) {
            effectiveType = 'int';
          }
          // Double: parseable as double with decimal point
          else if (double.tryParse(defaultValue) != null && defaultValue.contains('.')) {
            effectiveType = 'double';
          }
          // String: default type
          else {
            effectiveType = 'string';
          }
          // Store the inferred type
          currentParamMetadata['type'] = effectiveType;
        }

        // Validation: boolean type with non-boolean default
        if (effectiveType == 'boolean' && defaultValue != 'true' && defaultValue != 'false') {
          stderr.writeln('❌ Parameter "$currentParamName" has invalid default: "$defaultValue"');
          stderr.writeln('💡 Boolean parameters must have default: true or false');
          exit(1);
        }

        // Validation: typed enum values - ensure all values match the explicit type
        if (type != null && values != null && values.isNotEmpty && currentParamMetadata['isTypeExplicit'] == true) {
          final enumValidation = EnumTypeValidator.validateEnumValues(currentParamName, type, values);
          if (!enumValidation.isValid && currentCommand != null) {
            _validationErrors[currentCommand] = enumValidation.errorMessage ?? 'validation error';
            currentParamName = null;
            currentParamMetadata = {};
            continue;
          }
        }

        // Validation: typed enum default - ensure default matches the explicit type
        if (type != null && values != null && values.isNotEmpty && currentParamMetadata['isTypeExplicit'] == true) {
          final enumDefaultValidation = EnumTypeValidator.validateEnumDefault(currentParamName, type, defaultValue, values);
          if (!enumDefaultValidation.isValid && currentCommand != null) {
            _validationErrors[currentCommand] = enumDefaultValidation.errorMessage ?? 'validation error';
            currentParamName = null;
            currentParamMetadata = {};
            continue;
          }
        }

        // Validation: enum with default - ensure default is in values list
        if (values != null && values.isNotEmpty) {
          final lowerDefault = defaultValue.toLowerCase();
          final isValid = values.any((v) => v.toLowerCase() == lowerDefault);
          if (!isValid) {
            stderr.writeln('❌ Parameter $red$currentParamName$reset has invalid default: "$defaultValue"');
            final greenValues = values.map((v) => '$green$v$reset').join(', ');
            stderr.writeln('💡 Must be one of: $greenValues');
            exit(1);
          }
        }

        // Validation: numeric types with default (skip if explicitly string type)
        // Use EnumTypeValidator for consistency with typed enums
        if (effectiveType == 'int' && type == 'int' && !EnumTypeValidator.isValidInt(defaultValue)) {
          stderr.writeln('❌ Parameter "$currentParamName" has invalid default: "$defaultValue"');
          stderr.writeln('💡 Integer parameters must have a valid integer default');
          exit(1);
        }

        if (effectiveType == 'double' && type == 'double' && !EnumTypeValidator.isValidDouble(defaultValue)) {
          stderr.writeln('❌ Parameter "$currentParamName" has invalid default: "$defaultValue"');
          stderr.writeln('💡 Numeric parameters must have a valid number default');
          exit(1);
        }

        final updated = Param(
          name: existing.name,
          description: currentParamMetadata['description'] as String? ?? existing.description,
          defaultValue: defaultValue,
          flags: currentParamMetadata['flags'] as String? ?? existing.flags,
          type: effectiveType,
          values: values,
          isTypeExplicit: currentParamMetadata['isTypeExplicit'] as bool? ?? false,
        );

        // Replace in tempParams
        tempParams[currentParamName!] = updated;

        // Replace in list
        final targetMap = getCurrentTargetMap();

        // Ensure params structure exists
        targetMap['params'] ??= {'required': <Param>[], 'optional': <Param>[]};

        final paramsMap = targetMap['params'];
        if (paramsMap is Map && currentParamType != null) {
          final paramList = paramsMap[currentParamType];
          if (paramList is List<Param>) {
            final idx = paramList.indexWhere((p) => p.name == currentParamName);
            if (idx != -1) {
              paramList[idx] = updated;
            }
          }
        }
      } // end of !hasValidationError

      currentParamName = null;
      currentParamMetadata = {};
      continue;
    }
  }

  // Handle leftover multiline script at EOF
  if (capturingMultilineCommand) {
    final targetMap = getCurrentTargetMap();
    targetMap['script'] = multilineBuffer.join('\n');
  }

  // Finalize any pending parameter
  finalizeCurrentParam();

  // Finalize last command
  if (currentCommand != null) {
    finalizeCurrentCommand();
  }

  return result;
}

Command _buildCommand(Map<String, dynamic> map, String? description) {
  final script = map['script']?.toString();
  final paramsRaw = map['params'];
  final paramsMap = paramsRaw is Map<String, dynamic>
      ? {
          'required': (paramsRaw['required'] as List?)?.cast<Param>() ?? <Param>[],
          'optional': (paramsRaw['optional'] as List?)?.cast<Param>() ?? <Param>[],
        }
      : null;
  final override = map['override'] as bool?;
  final flags = map['flags'] as String?;
  final commandDescription = map['description'] as String?;
  final switchesMap = map['switch'] as Map<String, dynamic>?;
  final switches = <String, Command>{};
  String? defaultSwitch;

  // Parse switches if they exist
  if (switchesMap != null) {
    for (final entry in switchesMap.entries) {
      if (entry.key == 'default') {
        // Check if default is a string reference or a full command
        if (entry.value is String) {
          defaultSwitch = entry.value as String;
        } else if (entry.value is Map<String, dynamic>) {
          // Default is a full command definition - add it as a switch named 'default'
          switches['default'] = _buildCommand(entry.value as Map<String, dynamic>, null);
          defaultSwitch = 'default'; // Make it the default switch
        }
      } else {
        // Regular switch case
        if (entry.value is Map<String, dynamic>) {
          switches[entry.key] = _buildCommand(entry.value as Map<String, dynamic>, null);
        }
      }
    }
  }

  return Command(
    script: script,
    description: description ?? commandDescription,
    requiredParams: paramsMap?['required'] ?? [],
    optionalParams: paramsMap?['optional'] ?? [],
    override: override ?? false,
    switches: switches,
    defaultSwitch: defaultSwitch,
    flags: flags,
  );
}
