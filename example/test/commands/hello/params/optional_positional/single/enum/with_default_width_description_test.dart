import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: ## Description of parameter name
                values: [Alpha, Bravo, Charlie]
                default: Charlie
    ''',
    () {
      for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello Charlie\n'));
      });

      test('prints error when invalid value for optional param is specified', () async {
        final result = await Process.run('hello', ['Delta']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name$reset ${gray}Description of parameter name$reset
    ${bold}values$reset: Alpha, Bravo, Charlie
    ${bold}default$reset: "Charlie"
'''));
        });
      }
    },
  );

  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            optional:
              - name: ## Description of parameter name
                values: [Alpha, Bravo, Charlie]
                default: Delta
    ''',
    () {
      for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', ['$param']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', ['Delta']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-h', '--help']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }
    },
  );
}
