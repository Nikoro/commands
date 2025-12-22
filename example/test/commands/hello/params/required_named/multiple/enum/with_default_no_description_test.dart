import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha: '-a, --alpha'
                values: [A1, A2, A3]
                default: "A1"
              - beta: '--beta, -b'
                default: "B1"
              - charlie: '-c, --charlie'
                default: "C1"
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        for (String value in ['A1', 'A2', 'A3']) {
          test('prints "A: $value, B: B1, C: C1"', () async {
            final result = await Process.run('hello', [alpha, value]);
            expect(result.stdout, equals('A: $value, B: B1, C: C1\n'));
          });
          for (String beta in ['-b', '--beta']) {
            test('prints "A: A1, B: y, C: C1"', () async {
              final result = await Process.run('hello', [beta, 'y']);
              expect(result.stdout, equals('A: A1, B: y, C: C1\n'));
            });
            test('prints "A: $value, B: y, C: C1"', () async {
              final result = await Process.run('hello', [alpha, value, beta, 'y']);
              expect(result.stdout, equals('A: $value, B: y, C: C1\n'));
            });

            for (String charlie in ['-c', '--charlie']) {
              test('prints "A: A1, B: C1, C: z"', () async {
                final result = await Process.run('hello', [charlie, 'z']);
                expect(result.stdout, equals('A: A1, B: B1, C: z\n'));
              });
              test('prints "A: $value, B: B1, C: z"', () async {
                final result = await Process.run('hello', [alpha, value, charlie, 'z']);
                expect(result.stdout, equals('A: $value, B: B1, C: z\n'));
              });
              test('prints "A: A1, B: y, C: z"', () async {
                final result = await Process.run('hello', [beta, 'y', charlie, 'z']);
                expect(result.stdout, equals('A: A1, B: y, C: z\n'));
              });
              test('prints "A: $value, B: y, C: z"', () async {
                final result = await Process.run('hello', [alpha, value, beta, 'y', charlie, 'z']);
                expect(result.stdout, equals('A: $value, B: y, C: z\n'));
              });
            }
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
                result.stderr, equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when no value for required param [$charlie] is specified', () async {
              final result = await Process.run('hello', [charlie]);
              expect(result.stderr, equals('❌ Missing value for param: $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha] and [$charlie] is specified', () async {
              final result = await Process.run('hello', [alpha, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$beta] and [$charlie] is specified', () async {
              final result = await Process.run('hello', [beta, charlie]);
              expect(result.stderr,
                  equals('❌ Missing value for params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', [alpha, beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
            });
          }
        }
      }

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset
    ${bold}values$reset: A1, A2, A3
    ${bold}default$reset: "A1"
    ${magenta}beta (--beta, -b)$reset
    ${bold}default$reset: "B1"
    ${magenta}charlie (-c, --charlie)$reset
    ${bold}default$reset: "C1"
'''));
        });
      }
    },
  );
}
