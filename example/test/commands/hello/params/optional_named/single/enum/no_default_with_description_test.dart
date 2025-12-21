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
              - name: -n ## Description of parameter name
                values: [Alpha, Bravo, Charlie]
    ''',
    () {
      for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['-n', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints "Hello " when no value for optional param is specified', () async {
        final result = await Process.run('hello', ['-n']);
        expect(result.stdout, equals('Hello \n'));
      });

      test('prints error when invalid value for optional param is specified', () async {
        final result = await Process.run('hello', ['-n', 'Delta']);
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
    ${magenta}name (-n)$reset ${gray}Description of parameter name$reset
    ${bold}values$reset: Alpha, Bravo, Charlie
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
              - name: '-n, --name, nm' ## Description of parameter name
                values: [Alpha, Bravo, Charlie]
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints "Hello " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello \n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints "Hello " when no value for optional param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('Hello \n'));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid value for optional param is specified', () async {
          final result = await Process.run('hello', [flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
    ${bold}values$reset: Alpha, Bravo, Charlie
'''));
        });
      }
    },
  );
}
