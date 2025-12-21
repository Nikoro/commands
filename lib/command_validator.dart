import 'package:commands_cli/colors.dart';

final _allowedCommandPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

bool isValidCommandName(String name) => _allowedCommandPattern.hasMatch(name);

/// Validator for command definitions to ensure correct structure and relationships
class CommandValidator {
  /// Validates that a command doesn't mix incompatible properties
  ///
  /// Critical rules:
  /// 1. Cannot have both 'script' AND 'switch' at the same level
  /// 2. Cannot have both 'params' AND 'switch' at the same level
  /// 3. If 'default' is a string reference, it must point to an existing switch
  /// 4. Switch names must be valid identifiers
  static ValidationResult validate(String commandName, Map<String, dynamic> commandData) {
    final hasScript = commandData.containsKey('script');
    final hasSwitch = commandData.containsKey('switch');
    final hasParams = commandData.containsKey('params');

    // Rule 2: Params + Switch conflict (check this first, as params takes precedence over script)
    if (hasParams && hasSwitch) {
      return ValidationResult.error(
        'Cannot use both $bold${red}params$reset and $bold${red}switch$reset at the same time',
        hint: 'Parameters should be defined within individual switch cases, not at the switch level',
      );
    }

    // Rule 1: Script + Switch conflict
    if (hasScript && hasSwitch) {
      return ValidationResult.error(
        'Cannot use both $bold${red}script$reset and $bold${red}switch$reset at the same time',
        hint: 'Move your script content into a \'default\' switch case',
      );
    }

    // Rule 3: Validate default reference if it exists
    if (hasSwitch && commandData['switch'] is Map) {
      final switches = commandData['switch'] as Map<String, dynamic>;
      final defaultValue = switches['default'];

      if (defaultValue is String) {
        // Default references another switch by name
        if (!switches.containsKey(defaultValue)) {
          return ValidationResult.error(
            'Default switch \'$defaultValue\' does not exist in command: $commandName',
            hint: 'Available switches: ${switches.keys.where((k) => k != 'default').join(', ')}',
          );
        }

        // Check for self-reference
        if (defaultValue == 'default') {
          return ValidationResult.error(
            'Default switch cannot reference itself in command: $commandName',
            hint: 'Point default to an existing switch name or define default as a command',
          );
        }
      }

      // Rule 4: Validate switch names
      for (final switchName in switches.keys) {
        if (switchName == 'default') continue; // 'default' is allowed reserved word

        if (!_isValidSwitchName(switchName)) {
          return ValidationResult.error(
            'Invalid switch name \'$switchName\' in command: $commandName',
            hint: 'Switch names must be valid identifiers (letters, numbers, hyphens, underscores)',
          );
        }
      }

      // Recursively validate nested switches
      for (final entry in switches.entries) {
        if (entry.key == 'default' && entry.value is String) continue;

        final switchData = entry.value;
        if (switchData is Map<String, dynamic>) {
          final nestedResult = validate('$commandName > ${entry.key}', switchData);
          if (!nestedResult.isValid) {
            return nestedResult;
          }
        }
      }
    }

    return ValidationResult.success();
  }

  /// Check if a switch name follows valid naming conventions
  static bool _isValidSwitchName(String name) {
    // Allow letters, numbers, hyphens, and underscores
    final pattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    return pattern.hasMatch(name);
  }

  /// Validate switch flags format
  static bool isValidFlagsFormat(String flags) {
    // Flags should be comma-separated, starting with - or --
    // Examples: "-s", "--stg", "-s, --stg", "-p, --prod"
    final parts = flags.split(',').map((f) => f.trim());
    return parts.every((part) => part.startsWith('-') || part.startsWith('--'));
  }

  /// Validates parameter type and default value compatibility
  ///
  /// Rules:
  /// 1. Quoted default values are strings, so they cannot be used with explicit non-string types
  /// 2. Explicit string type should not have numeric unquoted defaults
  static ValidationResult validateParamTypeCompatibility(
    String? paramName,
    String? type,
    String? defaultValue,
    bool wasQuoted,
  ) {
    if (defaultValue == null || type == null) {
      return ValidationResult.success();
    }

    // Rule 1: If default value was quoted and type is explicitly non-string, that's an error
    if (wasQuoted && type != 'string') {
      final displayType = type == 'int' ? 'integer' : type;
      return ValidationResult.error(
        'Parameter $bold$red$paramName$reset is declared as type $gray[$displayType]$reset, but its default value is $gray[string]$reset',
        hint:
            'Quoted values are always strings. Either remove quotes (default: $defaultValue) or change type to string',
      );
    }

    // Rule 2: If type is explicitly string but default is numeric (unquoted), that's an error
    if (!wasQuoted && type == 'string') {
      final isInt = int.tryParse(defaultValue) != null && !defaultValue.contains('.');
      final isDouble = double.tryParse(defaultValue) != null && defaultValue.contains('.');

      if (isInt || isDouble) {
        final actualType = isInt ? 'integer' : 'double';
        return ValidationResult.error(
          'Parameter $bold$red$paramName$reset is declared as type $gray[string]$reset, but its default value is $gray[$actualType]$reset',
          hint:
              'Add quotes around numeric values for string type (default: "$defaultValue") or change type to $actualType',
        );
      }
    }

    return ValidationResult.success();
  }
}

/// Result of a validation operation
class ValidationResult {
  const ValidationResult({required this.isValid, this.errorMessage, this.hint});

  factory ValidationResult.success() => const ValidationResult(isValid: true);

  factory ValidationResult.error(String message, {String? hint}) {
    return ValidationResult(isValid: false, errorMessage: message, hint: hint);
  }

  final bool isValid;
  final String? errorMessage;
  final String? hint;

  String get fullMessage {
    final buffer = StringBuffer();
    if (errorMessage != null) {
      buffer.writeln('❌ $errorMessage');
    }
    if (hint != null) {
      buffer.writeln('💡 Hint: $hint');
    }
    return buffer.toString().trimRight();
  }
}

/// Validates enum values against an explicit type
class EnumTypeValidator {
  /// Checks if a value is a valid integer
  static bool isValidInt(String value) {
    // First check if it's a valid integer directly
    if (int.tryParse(value) != null) return true;

    // Also accept doubles that are whole numbers (e.g., "2.0")
    final doubleVal = double.tryParse(value);
    if (doubleVal != null && doubleVal == doubleVal.truncateToDouble()) {
      return true;
    }

    return false;
  }

  /// Checks if a value is a valid double (including integers)
  static bool isValidDouble(String value) {
    return double.tryParse(value) != null;
  }

  /// Gets the detected type of a value as a display string
  static String getValueType(String value) {
    // Check for integer first (no decimal point)
    if (int.tryParse(value) != null && !value.contains('.')) {
      return 'integer';
    }

    // Check for double (has decimal point or is parseable as double)
    if (double.tryParse(value) != null) {
      return 'double';
    }

    return 'string';
  }

  /// Validates enum values against the specified type
  ///
  /// Returns a ValidationResult with error details if any values don't match the type.
  /// If type is null or 'string', all values are valid.
  static ValidationResult validateEnumValues(
    String? paramName,
    String? type,
    List<String>? values,
  ) {
    if (type == null || type == 'string' || values == null || values.isEmpty) {
      return ValidationResult.success();
    }

    final invalidValues = <String, String>{};

    for (final value in values) {
      if (type == 'int') {
        if (!isValidInt(value)) {
          invalidValues[value] = getValueType(value);
        }
      } else if (type == 'double') {
        if (!isValidDouble(value)) {
          invalidValues[value] = getValueType(value);
        }
      }
    }

    if (invalidValues.isEmpty) {
      return ValidationResult.success();
    }

    // Build error message with all invalid values
    final typeName = type == 'int' ? 'integer' : type;
    final gotParts = invalidValues.entries.map((e) => '"${e.key}" $gray[${e.value}]$reset').join(', ');

    return ValidationResult.error(
      'Parameter $bold$red$paramName$reset expects an $gray[$typeName]$reset. Got: $gotParts',
      hint:
          '${typeName.substring(0, 1).toUpperCase()}${typeName.substring(1)} parameters must have valid $typeName values',
    );
  }

  /// Validates that an enum's default value matches the specified type
  ///
  /// Returns a ValidationResult with error details if the default doesn't match.
  static ValidationResult validateEnumDefault(
    String? paramName,
    String? type,
    String? defaultValue,
    List<String>? values,
  ) {
    if (type == null || type == 'string' || defaultValue == null) {
      return ValidationResult.success();
    }

    bool isValidType = false;
    if (type == 'int') {
      isValidType = isValidInt(defaultValue);
    } else if (type == 'double') {
      isValidType = isValidDouble(defaultValue);
    }

    if (isValidType) {
      return ValidationResult.success();
    }

    final typeName = type == 'int' ? 'integer' : type;
    final defaultTypeName = getValueType(defaultValue);

    return ValidationResult.error(
      'Parameter $bold$red$paramName$reset is declared as type $gray[$typeName]$reset, but its default value is $gray[$defaultTypeName]$reset',
      hint: 'Quoted values are always strings. Either remove quotes (default: $defaultValue) or change type to string',
    );
  }
}
