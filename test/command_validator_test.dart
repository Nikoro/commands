import 'package:commands_cli/command_validator.dart';
import 'package:test/test.dart';

void main() {
  group('command_validator', () {
    group('isValidCommandName', () {
      test('returns true for valid command names', () {
        expect(isValidCommandName('command'), isTrue);
        expect(isValidCommandName('command-with-hyphen'), isTrue);
        expect(isValidCommandName('command_with_underscore'), isTrue);
        expect(isValidCommandName('CommandWithCamelCase'), isTrue);
        expect(isValidCommandName('command123'), isTrue);
      });

      test('returns false for command names with spaces', () {
        expect(isValidCommandName('command with space'), isFalse);
      });

      test('returns false for command names with special characters', () {
        expect(isValidCommandName('command!'), isFalse);
        expect(isValidCommandName('command@'), isFalse);
        expect(isValidCommandName('command#'), isFalse);
        expect(isValidCommandName('command\$'), isFalse);
        expect(isValidCommandName('command%'), isFalse);
        expect(isValidCommandName('command^'), isFalse);
        expect(isValidCommandName('command&'), isFalse);
        expect(isValidCommandName('command*'), isFalse);
        expect(isValidCommandName('command()'), isFalse);
        expect(isValidCommandName('command='), isFalse);
        expect(isValidCommandName('command+'), isFalse);
      });

      test('returns false for an empty command name', () {
        expect(isValidCommandName(''), isFalse);
      });

      test('returns false for command names with leading or trailing spaces', () {
        expect(isValidCommandName(' command'), isFalse);
        expect(isValidCommandName('command '), isFalse);
      });
    });

    group('CommandValidator.validate', () {
      group('Rule 1: Script + Switch conflict', () {
        test('returns error when command has both script and switch', () {
          final result = CommandValidator.validate('build', {
            'script': 'echo "hello"',
            'switch': {
              'ios': {'script': 'echo "iOS"'},
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Cannot use both'));
          expect(result.errorMessage, contains('script'));
          expect(result.errorMessage, contains('switch'));
          expect(result.errorMessage, contains('at the same time'));
          expect(result.hint, contains('Move your script content into a \'default\' switch case'));
        });

        test('returns success when command has only script', () {
          final result = CommandValidator.validate('build', {'script': 'echo "hello"'});

          expect(result.isValid, isTrue);
        });

        test('returns success when command has only switch', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
            },
          });

          expect(result.isValid, isTrue);
        });
      });

      group('Rule 2: Params + Switch conflict', () {
        test('returns error when command has both params and switch', () {
          final result = CommandValidator.validate('deploy', {
            'params': {
              'required': [
                {'env': '-e, --env'},
              ],
            },
            'switch': {
              'staging': {'script': 'echo "staging"'},
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Cannot use \'params\' and \'switch\''));
          expect(result.hint, contains('Parameters should be defined within individual switch cases'));
        });

        test('returns success when params are inside switch cases', () {
          final result = CommandValidator.validate('deploy', {
            'switch': {
              'staging': {
                'script': 'echo "staging {env}"',
                'params': {
                  'optional': [
                    {'env': '-e, --env'},
                  ],
                },
              },
            },
          });

          expect(result.isValid, isTrue);
        });
      });

      group('Rule 3: Default switch validation', () {
        test('returns error when default references non-existent switch', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'android': {'script': 'echo "Android"'},
              'default': 'web', // doesn't exist
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Default switch \'web\' does not exist'));
          expect(result.hint, contains('Available switches'));
        });

        test('returns error when default references itself', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'default': 'default', // self-reference
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Default switch cannot reference itself'));
        });

        test('returns success when default references existing switch', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'android': {'script': 'echo "Android"'},
              'default': 'ios',
            },
          });

          expect(result.isValid, isTrue);
        });

        test('returns success when default is a full command definition', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'default': {'script': 'echo "default build"'},
            },
          });

          expect(result.isValid, isTrue);
        });
      });

      group('Rule 4: Switch name validation', () {
        test('returns error for invalid switch names', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios!': {'script': 'echo "iOS"'}, // invalid character
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Invalid switch name \'ios!\''));
        });

        test('returns success for valid switch names', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'android-debug': {'script': 'echo "Android Debug"'},
              'web_dev': {'script': 'echo "Web Dev"'},
              'test123': {'script': 'echo "Test"'},
            },
          });

          expect(result.isValid, isTrue);
        });

        test('allows "default" as reserved switch name', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'ios': {'script': 'echo "iOS"'},
              'default': 'ios',
            },
          });

          expect(result.isValid, isTrue);
        });
      });

      group('Nested switch validation', () {
        test('validates nested switches recursively', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'unit': {
                'switch': {
                  'all': {'script': 'echo "all"'},
                  'specific': {
                    'script': 'echo "specific"',
                    'switch': {}, // Invalid: script + switch at same level
                  },
                },
              },
            },
          });

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('Cannot use both'));
          expect(result.errorMessage, contains('script'));
          expect(result.errorMessage, contains('switch'));
          expect(result.errorMessage, contains('at the same time'));
        });

        test('validates deeply nested valid structure', () {
          final result = CommandValidator.validate('build', {
            'switch': {
              'level1': {
                'switch': {
                  'level2': {
                    'switch': {
                      'level3': {'script': 'echo "deep"'},
                    },
                  },
                },
              },
            },
          });

          expect(result.isValid, isTrue);
        });
      });
    });

    group('CommandValidator.isValidFlagsFormat', () {
      test('returns true for valid flag formats', () {
        expect(CommandValidator.isValidFlagsFormat('-s'), isTrue);
        expect(CommandValidator.isValidFlagsFormat('--stg'), isTrue);
        expect(CommandValidator.isValidFlagsFormat('-s, --stg'), isTrue);
        expect(CommandValidator.isValidFlagsFormat('-p, --prod, --production'), isTrue);
      });

      test('returns false for invalid flag formats', () {
        expect(CommandValidator.isValidFlagsFormat('staging'), isFalse);
        expect(CommandValidator.isValidFlagsFormat('s, --stg'), isFalse);
      });
    });

    group('CommandValidator.validateParamTypeCompatibility', () {
      test('returns error when quoted default has explicit int type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'port',
          'int',
          '3000',
          true, // wasQuoted
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Parameter'));
        expect(result.errorMessage, contains('port'));
        expect(result.errorMessage, contains('[int]'));
        expect(result.errorMessage, contains('[string]'));
        expect(result.hint, contains('Quoted values are always strings'));
        expect(result.hint, contains('default: 3000'));
      });

      test('returns error when quoted default has explicit double type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'rate',
          'double',
          '30.0',
          true, // wasQuoted
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Parameter'));
        expect(result.errorMessage, contains('rate'));
        expect(result.errorMessage, contains('[double]'));
        expect(result.errorMessage, contains('[string]'));
      });

      test('returns error when quoted default has explicit boolean type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'verbose',
          'boolean',
          'true',
          true, // wasQuoted
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Parameter'));
        expect(result.errorMessage, contains('verbose'));
        expect(result.errorMessage, contains('[boolean]'));
        expect(result.errorMessage, contains('[string]'));
      });

      test('returns success when quoted default has explicit string type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'name',
          'string',
          '123',
          true, // wasQuoted
        );

        expect(result.isValid, isTrue);
      });

      test('returns success when quoted default has no explicit type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'port',
          null,
          '3000',
          true, // wasQuoted
        );

        expect(result.isValid, isTrue);
      });

      test('returns success when unquoted numeric default has explicit int type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'port',
          'int',
          '3000',
          false, // wasQuoted
        );

        expect(result.isValid, isTrue);
      });

      test('returns success when unquoted numeric default has explicit double type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'rate',
          'double',
          '30.0',
          false, // wasQuoted
        );

        expect(result.isValid, isTrue);
      });

      test('returns error when unquoted int default has explicit string type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'code',
          'string',
          '123',
          false, // wasQuoted
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Parameter'));
        expect(result.errorMessage, contains('code'));
        expect(result.errorMessage, contains('[string]'));
        expect(result.errorMessage, contains('[int]'));
        expect(result.hint, contains('Add quotes around numeric values'));
        expect(result.hint, contains('default: "123"'));
      });

      test('returns error when unquoted double default has explicit string type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'version',
          'string',
          '1.5',
          false, // wasQuoted
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Parameter'));
        expect(result.errorMessage, contains('version'));
        expect(result.errorMessage, contains('[string]'));
        expect(result.errorMessage, contains('[double]'));
        expect(result.hint, contains('Add quotes around numeric values'));
        expect(result.hint, contains('default: "1.5"'));
      });

      test('returns success when unquoted non-numeric default has explicit string type', () {
        final result = CommandValidator.validateParamTypeCompatibility(
          'name',
          'string',
          'hello',
          false, // wasQuoted
        );

        expect(result.isValid, isTrue);
      });
    });

    group('EnumTypeValidator', () {
      group('isValidInt', () {
        test('returns true for valid integers', () {
          expect(EnumTypeValidator.isValidInt('1'), isTrue);
          expect(EnumTypeValidator.isValidInt('42'), isTrue);
          expect(EnumTypeValidator.isValidInt('-10'), isTrue);
          expect(EnumTypeValidator.isValidInt('0'), isTrue);
        });

        test('returns true for whole number doubles (2.0, 3.0)', () {
          expect(EnumTypeValidator.isValidInt('2.0'), isTrue);
          expect(EnumTypeValidator.isValidInt('3.0'), isTrue);
          expect(EnumTypeValidator.isValidInt('-5.0'), isTrue);
        });

        test('returns false for non-integer doubles', () {
          expect(EnumTypeValidator.isValidInt('2.5'), isFalse);
          expect(EnumTypeValidator.isValidInt('3.14'), isFalse);
          expect(EnumTypeValidator.isValidInt('0.1'), isFalse);
        });

        test('returns false for strings', () {
          expect(EnumTypeValidator.isValidInt('ios'), isFalse);
          expect(EnumTypeValidator.isValidInt('abc'), isFalse);
          expect(EnumTypeValidator.isValidInt('text'), isFalse);
        });
      });

      group('isValidDouble', () {
        test('returns true for doubles', () {
          expect(EnumTypeValidator.isValidDouble('3.14'), isTrue);
          expect(EnumTypeValidator.isValidDouble('0.5'), isTrue);
          expect(EnumTypeValidator.isValidDouble('-2.5'), isTrue);
        });

        test('returns true for integers (coercion)', () {
          expect(EnumTypeValidator.isValidDouble('1'), isTrue);
          expect(EnumTypeValidator.isValidDouble('42'), isTrue);
          expect(EnumTypeValidator.isValidDouble('-10'), isTrue);
        });

        test('returns false for strings', () {
          expect(EnumTypeValidator.isValidDouble('ios'), isFalse);
          expect(EnumTypeValidator.isValidDouble('abc'), isFalse);
          expect(EnumTypeValidator.isValidDouble('text'), isFalse);
        });
      });

      group('getValueType', () {
        test('returns integer for int values', () {
          expect(EnumTypeValidator.getValueType('1'), equals('integer'));
          expect(EnumTypeValidator.getValueType('42'), equals('integer'));
          expect(EnumTypeValidator.getValueType('-5'), equals('integer'));
        });

        test('returns double for double values', () {
          expect(EnumTypeValidator.getValueType('3.14'), equals('double'));
          expect(EnumTypeValidator.getValueType('0.5'), equals('double'));
          expect(EnumTypeValidator.getValueType('2.0'), equals('double'));
        });

        test('returns string for non-numeric values', () {
          expect(EnumTypeValidator.getValueType('ios'), equals('string'));
          expect(EnumTypeValidator.getValueType('abc'), equals('string'));
          expect(EnumTypeValidator.getValueType('text'), equals('string'));
        });
      });

      group('validateEnumValues', () {
        test('returns success when type is null', () {
          final result = EnumTypeValidator.validateEnumValues(
            'platform',
            null,
            ['ios', 'android', 'web'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when type is string', () {
          final result = EnumTypeValidator.validateEnumValues(
            'platform',
            'string',
            ['ios', 'android', 'web'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when all values match int type', () {
          final result = EnumTypeValidator.validateEnumValues(
            'level',
            'int',
            ['1', '2', '3'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when int enum has whole number doubles', () {
          final result = EnumTypeValidator.validateEnumValues(
            'level',
            'int',
            ['1', '2.0', '3'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when all values match double type', () {
          final result = EnumTypeValidator.validateEnumValues(
            'ratio',
            'double',
            ['0.5', '1.0', '1.5'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when double enum has integers', () {
          final result = EnumTypeValidator.validateEnumValues(
            'ratio',
            'double',
            ['1', '2', '3'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns error when int enum has string value', () {
          final result = EnumTypeValidator.validateEnumValues(
            'platform',
            'int',
            ['ios', '1', '2'],
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('platform'));
          expect(result.errorMessage, contains('[integer]'));
          expect(result.errorMessage, contains('"ios"'));
          expect(result.errorMessage, contains('[string]'));
        });

        test('returns error with multiple invalid values', () {
          final result = EnumTypeValidator.validateEnumValues(
            'platform',
            'int',
            ['ios', '1', '2.2'],
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('"ios"'));
          expect(result.errorMessage, contains('"2.2"'));
          expect(result.errorMessage, contains('[string]'));
          expect(result.errorMessage, contains('[double]'));
        });

        test('returns error when double enum has string value', () {
          final result = EnumTypeValidator.validateEnumValues(
            'ratio',
            'double',
            ['text', '1.5', '2.0'],
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('ratio'));
          expect(result.errorMessage, contains('[double]'));
          expect(result.errorMessage, contains('"text"'));
        });
      });

      group('validateEnumDefault', () {
        test('returns success when type is null', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'platform',
            null,
            'text',
            ['text', 'value'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when type is string', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'platform',
            'string',
            'text',
            ['text', 'value'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when default matches int type', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'level',
            'int',
            '1',
            ['1', '2', '3'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns success when int default is whole number double', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'level',
            'int',
            '2.0',
            ['1', '2.0', '3'],
          );
          expect(result.isValid, isTrue);
        });

        test('returns error when int default is string', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'platform',
            'int',
            'text',
            ['1', '2', '3'],
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('platform'));
          expect(result.errorMessage, contains('"text"'));
          expect(result.hint, contains('Integer'));
          expect(result.hint, contains('Must be one of'));
        });

        test('returns error when double default is string', () {
          final result = EnumTypeValidator.validateEnumDefault(
            'ratio',
            'double',
            'text',
            ['0.5', '1.0', '1.5'],
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('ratio'));
          expect(result.errorMessage, contains('"text"'));
        });
      });
    });
  });
}
