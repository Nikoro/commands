import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('Runtime Validation Error Messages', () {
    late File commandsYaml;
    late String originalContent;

    setUp(() {
      commandsYaml = File('commands.yaml');
      originalContent = commandsYaml.readAsStringSync();
    });

    tearDown(() {
      // Always restore original content
      commandsYaml.writeAsStringSync(originalContent);
    });

    test('shows clean error message for quoted int with explicit int type', () async {
      // Temporarily break type_numeric_types command by changing default to quoted string
      final modifiedContent = originalContent.replaceAll(
        '      - port: \'-p, --port\'\n'
            '        type: int\n'
            '        default: 3000',
        '      - port: \'-p, --port\'\n'
            '        type: int\n'
            '        default: "3000"',
      );

      commandsYaml.writeAsStringSync(modifiedContent);

      // Try to run the now-invalid command
      final result = await Process.run('type_numeric_types', []);

      expect(result.exitCode, 1);
      expect(
        result.stderr,
        equals(
          '❌ Parameter $bold${red}port$reset is declared as type $gray[integer]$reset, but its default value is $gray[string]$reset\n',
        ),
      );
    });

    test('shows clean error message for script and switch conflict', () async {
      // Temporarily break type_numeric_types by adding both script and switch
      final modifiedContent = originalContent.replaceAll(
        'type_numeric_types: ## Test int and double\n'
            '  script: echo "port={port} timeout={timeout}"',
        'type_numeric_types: ## Test int and double\n'
            '  script: echo "port={port} timeout={timeout}"\n'
            '  switch:\n'
            '    - opt1:\n'
            '      script: echo "test"\n'
            '    - default: opt1',
      );

      commandsYaml.writeAsStringSync(modifiedContent);

      // Try to run the now-invalid command
      final result = await Process.run('type_numeric_types', []);

      expect(result.exitCode, 1);
      expect(
        result.stderr,
        equals('❌ Cannot use both $bold${red}script$reset and $bold${red}switch$reset at the same time\n'),
      );
    });

    test('shows clean error message for string type with unquoted int default', () async {
      // Temporarily break type_numeric_types by changing type to string
      final modifiedContent = originalContent.replaceAll(
        '      - port: \'-p, --port\'\n'
            '        type: int\n'
            '        default: 3000',
        '      - port: \'-p, --port\'\n'
            '        type: string\n'
            '        default: 3000',
      );

      commandsYaml.writeAsStringSync(modifiedContent);

      // Try to run the now-invalid command
      final result = await Process.run('type_numeric_types', []);

      expect(result.exitCode, 1);
      expect(
        result.stderr,
        equals(
          '❌ Parameter $bold${red}port$reset is declared as type $gray[string]$reset, but its default value is $gray[integer]$reset\n',
        ),
      );
    });

    test('shows clean error message for double type with quoted default', () async {
      // Temporarily break type_numeric_types timeout parameter
      final modifiedContent = originalContent.replaceAll(
        '      - timeout: \'--timeout\'\n'
            '        type: double\n'
            '        default: 30.0',
        '      - timeout: \'--timeout\'\n'
            '        type: double\n'
            '        default: "30.0"',
      );

      commandsYaml.writeAsStringSync(modifiedContent);

      // Try to run the now-invalid command
      final result = await Process.run('type_numeric_types', []);

      expect(result.exitCode, 1);
      expect(
        result.stderr,
        equals(
          '❌ Parameter $bold${red}timeout$reset is declared as type $gray[double]$reset, but its default value is $gray[string]$reset\n',
        ),
      );
    });
  });
}
