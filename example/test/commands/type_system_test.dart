import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  // ============================================================================
  // BOOLEAN FLAGS TESTS
  // ============================================================================

  group('type_bool_flags', () {
    test('runs with default boolean values', () async {
      final result = await Process.run('type_bool_flags', []);
      expect(result.stdout, equals('verbose=false debug=true\n'));
    });

    test('accepts -v flag (sets verbose to true)', () async {
      final result = await Process.run('type_bool_flags', ['-v']);
      expect(result.stdout, equals('verbose=true debug=true\n'));
    });

    test('accepts --verbose flag (sets verbose to true)', () async {
      final result = await Process.run('type_bool_flags', ['--verbose']);
      expect(result.stdout, equals('verbose=true debug=true\n'));
    });

    test('accepts -d flag (toggles debug from true to false)', () async {
      final result = await Process.run('type_bool_flags', ['-d']);
      expect(result.stdout, equals('verbose=false debug=false\n'));
    });

    test('accepts multiple boolean flags (both toggle)', () async {
      final result = await Process.run('type_bool_flags', ['-v', '-d']);
      expect(result.stdout, equals('verbose=true debug=false\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with boolean type info', () async {
        final result = await Process.run('type_bool_flags', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_bool_flags$reset: ${gray}Test boolean flags$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}verbose (-v, --verbose)$reset\n'
            '    ${bold}default$reset: "false"\n'
            '    ${magenta}debug (-d, --debug)$reset\n'
            '    ${bold}default$reset: "true"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // ENUM WITH DEFAULT TESTS
  // ============================================================================

  group('type_enum_with_default', () {
    test('runs with default enum value', () async {
      final result = await Process.run('type_enum_with_default', []);
      expect(result.stdout, equals('env=staging\n'));
    });

    test('accepts -e flag with valid enum value', () async {
      final result = await Process.run('type_enum_with_default', ['-e', 'dev']);
      expect(result.stdout, equals('env=dev\n'));
    });

    test('accepts --environment flag with valid enum value', () async {
      final result = await Process.run('type_enum_with_default', ['--environment', 'prod']);
      expect(result.stdout, equals('env=prod\n'));
    });

    test('rejects invalid enum value', () async {
      final result = await Process.run('type_enum_with_default', ['-e', 'invalid']);
      expect(
        result.stderr,
        equals(
          "❌ Parameter ${red}env$reset has invalid value: \"invalid\"\n"
          "💡 Must be one of: ${green}dev$reset, ${green}staging$reset, ${green}prod$reset\n",
        ),
      );
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with enum values', () async {
        final result = await Process.run('type_enum_with_default', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_enum_with_default$reset: ${gray}Test enum with default$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}env (-e, --environment)$reset\n'
            '    ${bold}values$reset: dev, staging, prod\n'
            '    ${bold}default$reset: "staging"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // ENUM WITHOUT DEFAULT TESTS (PICKER)
  // ============================================================================

  group('type_enum_no_default', () {
    test('accepts -t flag with valid enum value', () async {
      final result = await Process.run('type_enum_no_default', ['-t', 'ios']);
      expect(result.stdout, equals('target=ios\n'));
    });

    test('accepts --target flag with valid enum value', () async {
      final result = await Process.run('type_enum_no_default', ['--target', 'android']);
      expect(result.stdout, equals('target=android\n'));
    });

    test('rejects invalid enum value', () async {
      final result = await Process.run('type_enum_no_default', ['-t', 'desktop']);
      expect(
        result.stderr,
        equals(
          "❌ Parameter ${red}target$reset has invalid value: \"desktop\"\n"
          "💡 Must be one of: ${green}ios$reset, ${green}android$reset, ${green}web$reset\n",
        ),
      );
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with enum values and description', () async {
        final result = await Process.run('type_enum_no_default', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_enum_no_default$reset: ${gray}Test enum without default (picker)$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}target (-t, --target)$reset\n'
            '    ${bold}values$reset: ios, android, web\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // NUMERIC TYPES TESTS (EXPLICIT TYPE)
  // ============================================================================

  group('type_numeric_types', () {
    test('runs with default numeric values', () async {
      final result = await Process.run('type_numeric_types', []);
      expect(result.stdout, equals('port=3000 timeout=30.0\n'));
    });

    test('accepts -p flag with valid integer', () async {
      final result = await Process.run('type_numeric_types', ['-p', '8080']);
      expect(result.stdout, equals('port=8080 timeout=30.0\n'));
    });

    test('accepts --timeout flag with valid double', () async {
      final result = await Process.run('type_numeric_types', ['--timeout', '45.5']);
      expect(result.stdout, equals('port=3000 timeout=45.5\n'));
    });

    test('rejects non-integer for int type', () async {
      final result = await Process.run('type_numeric_types', ['-p', 'abc']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('port'));
      expect(result.stderr, contains('[integer]'));
      expect(result.stderr, contains('Got: "abc"'));
      expect(result.exitCode, equals(1));
    });

    test('rejects non-double for double type', () async {
      final result = await Process.run('type_numeric_types', ['--timeout', 'xyz']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('timeout'));
      expect(result.stderr, contains('[number]'));
      expect(result.stderr, contains('Got: "xyz"'));
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with numeric types', () async {
        final result = await Process.run('type_numeric_types', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_numeric_types$reset: ${gray}Test int and double$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}port (-p, --port)$reset ${gray}[int]$reset\n'
            '    ${bold}default$reset: "3000"\n'
            '    ${magenta}timeout (--timeout)$reset ${gray}[double]$reset\n'
            '    ${bold}default$reset: "30.0"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // MIXED TYPES TESTS
  // ============================================================================

  group('type_mixed_types', () {
    test('runs with all default values', () async {
      final result = await Process.run('type_mixed_types', []);
      expect(result.stdout, equals('env=staging replicas=3 timeout=30.5 verbose=false\n'));
    });

    test('accepts enum value', () async {
      final result = await Process.run('type_mixed_types', ['-e', 'prod']);
      expect(result.stdout, equals('env=prod replicas=3 timeout=30.5 verbose=false\n'));
    });

    test('accepts int value', () async {
      final result = await Process.run('type_mixed_types', ['-r', '5']);
      expect(result.stdout, equals('env=staging replicas=5 timeout=30.5 verbose=false\n'));
    });

    test('accepts double value', () async {
      final result = await Process.run('type_mixed_types', ['-t', '60.5']);
      expect(result.stdout, equals('env=staging replicas=3 timeout=60.5 verbose=false\n'));
    });

    test('accepts boolean flag', () async {
      final result = await Process.run('type_mixed_types', ['-v']);
      expect(result.stdout, equals('env=staging replicas=3 timeout=30.5 verbose=true\n'));
    });

    test('accepts all parameters together', () async {
      final result = await Process.run('type_mixed_types', ['-e', 'dev', '-r', '10', '-t', '45.0', '-v']);
      expect(result.stdout, equals('env=dev replicas=10 timeout=45.0 verbose=true\n'));
    });

    test('rejects invalid enum value', () async {
      final result = await Process.run('type_mixed_types', ['-e', 'invalid']);
      expect(
        result.stderr,
        equals(
          "❌ Parameter ${red}env$reset has invalid value: \"invalid\"\n"
          "💡 Must be one of: ${green}dev$reset, ${green}staging$reset, ${green}prod$reset\n",
        ),
      );
      expect(result.exitCode, equals(1));
    });

    test('rejects invalid int value', () async {
      final result = await Process.run('type_mixed_types', ['-r', 'abc']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('replicas'));
      expect(result.stderr, contains('[integer]'));
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with all type information', () async {
        final result = await Process.run('type_mixed_types', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_mixed_types$reset: ${gray}Test all types together$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}env (-e, --environment)$reset\n'
            '    ${bold}values$reset: dev, staging, prod\n'
            '    ${bold}default$reset: "staging"\n'
            '    ${magenta}replicas (-r, --replicas)$reset ${gray}[int]$reset\n'
            '    ${bold}default$reset: "3"\n'
            '    ${magenta}timeout (-t, --timeout)$reset ${gray}[double]$reset\n'
            '    ${bold}default$reset: "30.5"\n'
            '    ${magenta}verbose (-v, --verbose)$reset\n'
            '    ${bold}default$reset: "false"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // INFERRED INT TYPE TESTS
  // ============================================================================

  group('type_inferred_int', () {
    test('runs with default inferred int values', () async {
      final result = await Process.run('type_inferred_int', []);
      expect(result.stdout, equals('port=8080 workers=4\n'));
    });

    test('accepts valid integer for port', () async {
      final result = await Process.run('type_inferred_int', ['-p', '3000']);
      expect(result.stdout, equals('port=3000 workers=4\n'));
    });

    test('accepts valid integer for workers', () async {
      final result = await Process.run('type_inferred_int', ['-w', '8']);
      expect(result.stdout, equals('port=8080 workers=8\n'));
    });

    test('rejects non-integer for inferred int type', () async {
      final result = await Process.run('type_inferred_int', ['-p', 'abc']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('port'));
      expect(result.stderr, contains('[integer]'));
      expect(result.exitCode, equals(1));
    });

    test('rejects decimal for inferred int type', () async {
      final result = await Process.run('type_inferred_int', ['-p', '3000.5']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('port'));
      expect(result.stderr, contains('[integer]'));
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with inferred int type', () async {
        final result = await Process.run('type_inferred_int', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_inferred_int$reset: ${gray}Test inferred int type$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}port (-p, --port)$reset\n'
            '    ${bold}default$reset: "8080"\n'
            '    ${magenta}workers (-w, --workers)$reset\n'
            '    ${bold}default$reset: "4"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // INFERRED DOUBLE TYPE TESTS
  // ============================================================================

  group('type_inferred_double', () {
    test('runs with default inferred double values', () async {
      final result = await Process.run('type_inferred_double', []);
      expect(result.stdout, equals('ratio=0.5 timeout=30.0\n'));
    });

    test('accepts valid double for ratio', () async {
      final result = await Process.run('type_inferred_double', ['-r', '0.75']);
      expect(result.stdout, equals('ratio=0.75 timeout=30.0\n'));
    });

    test('accepts valid integer for double type (coercion)', () async {
      final result = await Process.run('type_inferred_double', ['-r', '2']);
      expect(result.stdout, equals('ratio=2 timeout=30.0\n'));
    });

    test('rejects non-numeric for inferred double type', () async {
      final result = await Process.run('type_inferred_double', ['-r', 'abc']);
      expect(result.stderr, contains('Parameter'));
      expect(result.stderr, contains('ratio'));
      expect(result.stderr, contains('[number]'));
      expect(result.exitCode, equals(1));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with inferred double type', () async {
        final result = await Process.run('type_inferred_double', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_inferred_double$reset: ${gray}Test inferred double type$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}ratio (-r, --ratio)$reset\n'
            '    ${bold}default$reset: "0.5"\n'
            '    ${magenta}timeout (-t, --timeout)$reset\n'
            '    ${bold}default$reset: "30.0"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // INFERRED BOOLEAN TYPE TESTS
  // ============================================================================

  group('type_inferred_boolean', () {
    test('runs with default inferred boolean values', () async {
      final result = await Process.run('type_inferred_boolean', []);
      expect(result.stdout, equals('enabled=true verbose=false\n'));
    });

    test('accepts -e flag (toggles enabled from true to false)', () async {
      final result = await Process.run('type_inferred_boolean', ['-e']);
      expect(result.stdout, equals('enabled=false verbose=false\n'));
    });

    test('accepts -e with explicit true value', () async {
      final result = await Process.run('type_inferred_boolean', ['-e', 'true']);
      expect(result.stdout, equals('enabled=true verbose=false\n'));
    });

    test('accepts -e with explicit false value', () async {
      final result = await Process.run('type_inferred_boolean', ['-e', 'false']);
      expect(result.stdout, equals('enabled=false verbose=false\n'));
    });

    test('accepts -v flag (toggles verbose from false to true)', () async {
      final result = await Process.run('type_inferred_boolean', ['-v']);
      expect(result.stdout, equals('enabled=true verbose=true\n'));
    });

    test('accepts -v with explicit true value', () async {
      final result = await Process.run('type_inferred_boolean', ['-v', 'true']);
      expect(result.stdout, equals('enabled=true verbose=true\n'));
    });

    test('accepts -v with explicit false value', () async {
      final result = await Process.run('type_inferred_boolean', ['-v', 'false']);
      expect(result.stdout, equals('enabled=true verbose=false\n'));
    });

    test('accepts both flags (both toggle)', () async {
      final result = await Process.run('type_inferred_boolean', ['-e', '-v']);
      expect(result.stdout, equals('enabled=false verbose=true\n'));
    });

    test('accepts both flags with explicit true values', () async {
      final result = await Process.run('type_inferred_boolean', ['-e', 'true', '-v', 'true']);
      expect(result.stdout, equals('enabled=true verbose=true\n'));
    });

    test('accepts both flags with explicit false values', () async {
      final result = await Process.run('type_inferred_boolean', ['-e', 'false', '-v', 'false']);
      expect(result.stdout, equals('enabled=false verbose=false\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with inferred boolean type', () async {
        final result = await Process.run('type_inferred_boolean', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_inferred_boolean$reset: ${gray}Test inferred boolean type$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}enabled (-e, --enabled)$reset\n'
            '    ${bold}default$reset: "true"\n'
            '    ${magenta}verbose (-v, --verbose)$reset\n'
            '    ${bold}default$reset: "false"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // INFERRED STRING TYPE TESTS
  // ============================================================================

  group('type_inferred_string', () {
    test('runs with default inferred string values', () async {
      final result = await Process.run('type_inferred_string', []);
      expect(result.stdout, equals('name=example message=hello world\n'));
    });

    test('accepts custom name', () async {
      final result = await Process.run('type_inferred_string', ['-n', 'custom']);
      expect(result.stdout, equals('name=custom message=hello world\n'));
    });

    test('accepts custom message', () async {
      final result = await Process.run('type_inferred_string', ['-m', 'goodbye']);
      expect(result.stdout, equals('name=example message=goodbye\n'));
    });

    test('accepts numeric-looking strings', () async {
      final result = await Process.run('type_inferred_string', ['-n', '123', '-m', '45.67']);
      expect(result.stdout, equals('name=123 message=45.67\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with inferred string type', () async {
        final result = await Process.run('type_inferred_string', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_inferred_string$reset: ${gray}Test inferred string type$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}name (-n, --name)$reset\n'
            '    ${bold}default$reset: "example"\n'
            '    ${magenta}message (-m, --message)$reset\n'
            '    ${bold}default$reset: "hello world"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // INFERRED MIXED TYPES TESTS
  // ============================================================================

  group('type_inferred_mixed', () {
    test('runs with all default inferred values', () async {
      final result = await Process.run('type_inferred_mixed', []);
      expect(result.stdout, equals('port=3000 ratio=1.5 enabled=true name=server\n'));
    });

    test('accepts inferred int', () async {
      final result = await Process.run('type_inferred_mixed', ['-p', '8080']);
      expect(result.stdout, equals('port=8080 ratio=1.5 enabled=true name=server\n'));
    });

    test('accepts inferred double', () async {
      final result = await Process.run('type_inferred_mixed', ['-r', '2.5']);
      expect(result.stdout, equals('port=3000 ratio=2.5 enabled=true name=server\n'));
    });

    test('accepts inferred boolean flag (toggles from true to false)', () async {
      final result = await Process.run('type_inferred_mixed', ['-e']);
      expect(result.stdout, equals('port=3000 ratio=1.5 enabled=false name=server\n'));
    });

    test('accepts inferred string', () async {
      final result = await Process.run('type_inferred_mixed', ['-n', 'api']);
      expect(result.stdout, equals('port=3000 ratio=1.5 enabled=true name=api\n'));
    });

    test('accepts all parameters together', () async {
      final result = await Process.run('type_inferred_mixed', ['-p', '9000', '-r', '3.0', '-e', '-n', 'web']);
      expect(result.stdout, equals('port=9000 ratio=3.0 enabled=false name=web\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help with all inferred types', () async {
        final result = await Process.run('type_inferred_mixed', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_inferred_mixed$reset: ${gray}Test all inferred types together$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}port (-p, --port)$reset\n'
            '    ${bold}default$reset: "3000"\n'
            '    ${magenta}ratio (-r, --ratio)$reset\n'
            '    ${bold}default$reset: "1.5"\n'
            '    ${magenta}enabled (-e, --enabled)$reset\n'
            '    ${bold}default$reset: "true"\n'
            '    ${magenta}name (-n, --name)$reset\n'
            '    ${bold}default$reset: "server"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // QUOTED INT TYPE TESTS
  // ============================================================================

  group('type_quoted_int', () {
    test('runs with default quoted int values (treated as strings)', () async {
      final result = await Process.run('type_quoted_int', []);
      expect(result.stdout, equals('port=8080 count=42\n'));
    });

    test('accepts any value (treated as string)', () async {
      final result = await Process.run('type_quoted_int', ['-p', '9000']);
      expect(result.stdout, equals('port=9000 count=42\n'));
    });

    test('accepts non-integer values (treated as string)', () async {
      final result = await Process.run('type_quoted_int', ['-c', 'abc']);
      expect(result.stdout, equals('port=8080 count=abc\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help showing string type', () async {
        final result = await Process.run('type_quoted_int', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_quoted_int$reset: ${gray}Test quoted int becomes string$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}port (-p, --port)$reset\n'
            '    ${bold}default$reset: "8080"\n'
            '    ${magenta}count (-c, --count)$reset\n'
            '    ${bold}default$reset: "42"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // QUOTED DOUBLE TYPE TESTS
  // ============================================================================

  group('type_quoted_double', () {
    test('runs with default quoted double values (treated as strings)', () async {
      final result = await Process.run('type_quoted_double', []);
      expect(result.stdout, equals('ratio=0.75 timeout=30.0\n'));
    });

    test('accepts any value (treated as string)', () async {
      final result = await Process.run('type_quoted_double', ['-r', '1.25']);
      expect(result.stdout, equals('ratio=1.25 timeout=30.0\n'));
    });

    test('accepts non-numeric values (treated as string)', () async {
      final result = await Process.run('type_quoted_double', ['-t', 'xyz']);
      expect(result.stdout, equals('ratio=0.75 timeout=xyz\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help showing string type', () async {
        final result = await Process.run('type_quoted_double', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_quoted_double$reset: ${gray}Test quoted double becomes string$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}ratio (-r, --ratio)$reset\n'
            '    ${bold}default$reset: "0.75"\n'
            '    ${magenta}timeout (-t, --timeout)$reset\n'
            '    ${bold}default$reset: "30.0"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // QUOTED BOOLEAN TYPE TESTS
  // ============================================================================

  group('type_quoted_boolean', () {
    test('runs with default quoted boolean values (treated as strings)', () async {
      final result = await Process.run('type_quoted_boolean', []);
      expect(result.stdout, equals('enabled=true verbose=false\n'));
    });

    test('accepts string value for enabled (requires explicit value)', () async {
      final result = await Process.run('type_quoted_boolean', ['-e', 'yes']);
      expect(result.stdout, equals('enabled=yes verbose=false\n'));
    });

    test('accepts string value for verbose (requires explicit value)', () async {
      final result = await Process.run('type_quoted_boolean', ['-v', 'no']);
      expect(result.stdout, equals('enabled=true verbose=no\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help showing string type', () async {
        final result = await Process.run('type_quoted_boolean', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_quoted_boolean$reset: ${gray}Test quoted boolean becomes string$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}enabled (-e, --enabled)$reset\n'
            '    ${bold}default$reset: "true"\n'
            '    ${magenta}verbose (-v, --verbose)$reset\n'
            '    ${bold}default$reset: "false"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // QUOTED INFERRED TYPE TESTS
  // ============================================================================

  group('type_quoted_inferred', () {
    test('runs with default quoted values (treated as strings)', () async {
      final result = await Process.run('type_quoted_inferred', []);
      expect(result.stdout, equals('port=9000 ratio=2.5\n'));
    });

    test('accepts any value for port (treated as string)', () async {
      final result = await Process.run('type_quoted_inferred', ['-p', '7000']);
      expect(result.stdout, equals('port=7000 ratio=2.5\n'));
    });

    test('accepts any value for ratio (treated as string)', () async {
      final result = await Process.run('type_quoted_inferred', ['-r', '3.0']);
      expect(result.stdout, equals('port=9000 ratio=3.0\n'));
    });

    test('accepts non-numeric values (treated as string)', () async {
      final result = await Process.run('type_quoted_inferred', ['-p', 'abc', '-r', 'xyz']);
      expect(result.stdout, equals('port=abc ratio=xyz\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help showing string types for quoted defaults', () async {
        final result = await Process.run('type_quoted_inferred', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_quoted_inferred$reset: ${gray}Test quoted values become strings$reset\n'
            'params:\n'
            '  optional:\n'
            '    ${magenta}port (-p, --port)$reset\n'
            '    ${bold}default$reset: "9000"\n'
            '    ${magenta}ratio (-r, --ratio)$reset\n'
            '    ${bold}default$reset: "2.5"\n',
          ),
        );
      });
    }
  });

  // ============================================================================
  // EXPLICIT STRING TYPE TESTS
  // ============================================================================

  group('type_explicit_string', () {
    test('accepts numeric-looking strings without validation', () async {
      final result = await Process.run('type_explicit_string', ['-c', '999', '-v', '3.14']);
      expect(result.stdout, equals('code=999 version=3.14\n'));
    });

    test('accepts non-numeric strings', () async {
      final result = await Process.run('type_explicit_string', ['-c', 'ABC-123', '-v', 'v2.0-beta']);
      expect(result.stdout, equals('code=ABC-123 version=v2.0-beta\n'));
    });

    test('accepts quoted strings', () async {
      final result = await Process.run('type_explicit_string', ['-c', '"quoted"', '-v', "'single'"]);
      expect(result.stdout, equals('code=quoted version=\'single\'\n'));
    });

    for (String flag in ['-h', '--help']) {
      test('$flag prints help showing explicit string type', () async {
        final result = await Process.run('type_explicit_string', [flag]);
        expect(
          result.stdout,
          equals(
            '${blue}type_explicit_string$reset: ${gray}Test explicit string type prevents inference$reset\n'
            'params:\n'
            '  required:\n'
            '    ${magenta}code (-c, --code)$reset ${gray}[string]$reset\n'
            '    ${magenta}version (-v, --version)$reset ${gray}[string]$reset\n',
          ),
        );
      });
    }
  });
}
