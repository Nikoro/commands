import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello {name}"
          params:
            required:
              - name: -n
    ''',
    () {
      for (Object param in ['World', 1, 2.2, true]) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['-n', '$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
      });

      test('prints error when no required value for param is specified', () async {
        final result = await Process.run('hello', ['-n']);
        expect(
            result.stderr,
            equals(
                '❌ Missing value for param: $bold${red}name$reset\n')); // This fails because name is not red and should be, implementation needs to be adjusted
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n)$reset
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
            required:
              - name: '-n, --name, nm'
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no required value for param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(
              result.stderr,
              equals(
                  '❌ Missing value for param: $bold${red}name$reset\n')); // This fails because name is not red and should be, implementation needs to be adjusted
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n, --name, nm)$reset
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
            required:
              - name: '-n, --name, nm' ## Description of parameter name
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stderr, equals('❌ Missing required named param: $bold${red}name$reset\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no required value for param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(
              result.stderr,
              equals(
                  '❌ Missing value for param: $bold${red}name$reset\n')); // This fails because name is not red and should be, implementation needs to be adjusted
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
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
            required:
              - name: '-n, --name, nm'
                default: Bob
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello Bob\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no required value for param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(
              result.stderr,
              equals(
                  '❌ Missing value for param: $bold${red}name$reset\n')); // This fails because name is not red and should be, implementation needs to be adjusted
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}name (-n, --name, nm)$reset
    ${bold}default$reset: "Bob"
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
            required:
              - name: '-n, --name, nm' ## Description of parameter name
                default: Bob
    ''',
    () {
      for (String flag in ['-n', '--name', 'nm']) {
        for (Object param in ['World', 1, 2.2, true]) {
          test('prints "Hello $param"', () async {
            final result = await Process.run('hello', [flag, '$param']);
            expect(result.stdout, equals('Hello $param\n'));
          });
        }
      }

      test('prints with default value if none specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello Bob\n'));
      });

      for (String flag in ['-n', '--name', 'nm']) {
        test('prints error when no required value for param is specified', () async {
          final result = await Process.run('hello', [flag]);
          expect(
              result.stderr,
              equals(
                  '❌ Missing value for param: $bold${red}name$reset\n')); // This fails because name is not red and should be, implementation needs to be adjusted
        });
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name (-n, --name, nm)$reset ${gray}Description of parameter name$reset
    ${bold}default$reset: "Bob"
'''));
        });
      }
    },
  );
}
