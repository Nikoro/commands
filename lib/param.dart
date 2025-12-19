/// Represents a parameter for a command with type information and validation.
class Param {
  const Param({
    required this.name,
    this.flags,
    this.description,
    this.defaultValue,
    this.type,
    this.values,
    this.isTypeExplicit = false,
  });

  final String name;
  final String? flags; // for named parameters like '--end, -e'
  final String? description;
  final String? defaultValue;

  /// The type of the parameter: 'boolean', 'string', 'int', 'double'
  /// If null, defaults to 'string'
  final String? type;

  /// Whether the type was explicitly specified in YAML (true) or inferred (false)
  final bool isTypeExplicit;

  /// List of allowed values for enum parameters
  /// If non-empty, the parameter is treated as an enum
  final List<String>? values;

  /// Parses a raw string value according to the parameter's type
  ///
  /// Returns the parsed value as the appropriate Dart type:
  /// - boolean type: returns bool
  /// - int type: returns int (throws if invalid)
  /// - double type: returns double (throws if invalid)
  /// - string type: returns String (default)
  ///
  /// Throws [FormatException] if parsing fails
  dynamic parseValue(String rawValue) {
    final effectiveType = type ?? 'string';

    switch (effectiveType) {
      case 'boolean':
        final lower = rawValue.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
        throw FormatException('Parameter "$name" expects a boolean value (true/false), got: "$rawValue"');

      case 'int':
        final value = int.tryParse(rawValue);
        if (value == null) {
          throw FormatException('Parameter "$name" expects an integer, got: "$rawValue"');
        }
        return value;

      case 'double':
        final value = double.tryParse(rawValue);
        if (value == null) {
          throw FormatException('Parameter "$name" expects a number, got: "$rawValue"');
        }
        return value;

      case 'string':
      default:
        return rawValue;
    }
  }

  /// Returns true if this parameter is a boolean type
  ///
  /// A parameter is boolean if:
  /// 1. type is explicitly 'boolean'
  ///
  /// Note: Parameters with quoted "true"/"false" defaults are treated as strings,
  /// not booleans, so they require explicit values and don't act as flags.
  bool get isBoolean {
    return type == 'boolean';
  }

  /// Returns true if this parameter is an enum (has a list of allowed values)
  bool get isEnum => values != null && values!.isNotEmpty;

  /// Returns true if this enum parameter requires an interactive picker
  ///
  /// A picker is required when:
  /// - The parameter is an enum (has values list), AND
  /// - No default value is provided
  bool get requiresEnumPicker => isEnum && defaultValue == null;

  /// Returns the default value as a boolean
  ///
  /// Only call this if [isBoolean] is true
  /// Returns false if no default is set
  bool get booleanDefault {
    if (defaultValue == null) return false;
    return defaultValue!.toLowerCase() == 'true';
  }

  /// Validates if the given value is allowed for this parameter
  ///
  /// For enum parameters, validates against the allowed values list
  /// - For string types: case-insensitive string comparison
  /// - For numeric types (int/double): numeric equivalence (e.g., "3.0" == "3" for int)
  /// For non-enum parameters, always returns true
  bool isValidValue(String value) {
    if (!isEnum) return true;

    // For numeric types, compare numeric values
    if (type == 'int' || type == 'double') {
      final valueNum = double.tryParse(value);
      if (valueNum == null) return false;

      return values!.any((v) {
        final enumNum = double.tryParse(v);
        if (enumNum == null) return false;
        return valueNum == enumNum;
      });
    }

    // For string/boolean types, use case-insensitive string comparison
    final lowerValue = value.toLowerCase();
    return values!.any((v) => v.toLowerCase() == lowerValue);
  }
}
