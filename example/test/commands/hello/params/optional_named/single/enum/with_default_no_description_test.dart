import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name, nm'
                values: [Alpha, Bravo, Charlie]
                default: Charlie
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

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello Charlie\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints with default value when no value for optional param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('Hello Charlie\n'));
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
${blue}hello$reset
params:
  optional:
    ${magenta}name (-n, --name, nm)$reset
    ${bold}values$reset: Alpha, Bravo, Charlie
    ${bold}default$reset: "Charlie"
'''));
        });
      }
    },
  );

  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            optional:
              - name: '-n, --name, nm'
                values: [Alpha, Bravo, Charlie]
                default: Delta
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
          test('prints error when invalid default value is specified', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
          });
        }
      }

      test('prints error when invalid default value is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }
      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when invalid default value is specified', () async {
          final result = await Process.run('hello', [flag, 'Delta']);
          expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid default: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
        });
      }

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
