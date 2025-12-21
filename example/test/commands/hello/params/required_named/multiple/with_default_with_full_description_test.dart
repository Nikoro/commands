import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha: '-a, --alpha' ## Description of parameter alpha
                default: "A1"
              - beta: '--beta, -b' ## Description of parameter beta
                default: "B1"
              - charlie: '-c, --charlie' ## Description of parameter charlie
                default: "C1"
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: x, B: B1, C: C1"', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stdout, equals('A: x, B: B1, C: C1\n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints "A: A1, B: y, C: C1"', () async {
            final result = await Process.run('hello', [beta, 'y']);
            expect(result.stdout, equals('A: A1, B: y, C: C1\n'));
          });
          test('prints "A: x, B: y, C: C1"', () async {
            final result = await Process.run('hello', [alpha, 'x', beta, 'y']);
            expect(result.stdout, equals('A: x, B: y, C: C1\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: A1, B: C1, C: z"', () async {
              final result = await Process.run('hello', [charlie, 'z']);
              expect(result.stdout, equals('A: A1, B: B1, C: z\n'));
            });
            test('prints "A: x, B: B1, C: z"', () async {
              final result = await Process.run('hello', [alpha, 'x', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: B1, C: z\n'));
            });
            test('prints "A: A1, B: y, C: z"', () async {
              final result = await Process.run('hello', [beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: A1, B: y, C: z\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await Process.run('hello', [alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints "A: A1, B: B1, C: C1" when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints error when no value for required param [$alpha] is specified', () async {
          final result = await Process.run('hello', [alpha]);
          expect(result.stderr, equals('❌ Missing value for param: $bold${red}alpha$reset\n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints error when no value for required param [$beta] is specified', () async {
            final result = await Process.run('hello', [beta]);
            expect(result.stderr, equals('❌ Missing value for param: $bold${red}beta$reset\n'));
          });

          test('prints error when no value for required params [$alpha] and [$beta] is specified', () async {
            final result = await Process.run('hello', [alpha, beta]);
            expect(
                result.stderr,
                equals(
                    '❌ Missing value for param: $bold${red}alpha$reset\n')); // This should be adjusted it should be: '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset\n'
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when no value for required param [$charlie] is specified', () async {
              final result = await Process.run('hello', [charlie]);
              expect(result.stderr, equals('❌ Missing value for param: $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha] and [$charlie] is specified', () async {
              final result = await Process.run('hello', [alpha, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for param: $bold${red}alpha$reset\n')); // This should be adjusted it should be: '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'
            });

            test('prints error when no value for required params [$beta] and [$charlie] is specified', () async {
              final result = await Process.run('hello', [beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for param: $bold${red}beta$reset\n')); // This should be adjusted it should be: '❌ Missing value for params: $bold${red}beta$reset, $bold${red}charlie$reset\n'
            });

            test('prints error when no value for required params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', [alpha, beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for param: $bold${red}alpha$reset\n')); // This should be adjusted it should be: '❌ Missing value for params: $bold${red}beta$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'
            });
          }
        }
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
    ${bold}default$reset: "A1"
    ${magenta}beta (--beta, -b)$reset ${gray}Description of parameter beta$reset
    ${bold}default$reset: "B1"
    ${magenta}charlie (-c, --charlie)$reset ${gray}Description of parameter charlie$reset
    ${bold}default$reset: "C1"
'''));
        });
      }
    },
  );
}
