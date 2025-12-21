import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha: '-a, --alpha'
              - beta: '--beta, -b'
              - charlie: '-c, --charlie'
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        test('prints error when required params is not specified', () async {
          final result = await Process.run('hello', [alpha, 'x']);
          expect(result.stderr,
              equals('❌ Missing required named params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
        });
        for (String beta in ['-b', '--beta']) {
          test('prints error when required param is not specified', () async {
            final result = await Process.run('hello', [beta, 'y']);
            expect(result.stderr,
                equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
          });
          test('prints error when required param is not specified', () async {
            final result = await Process.run('hello', [alpha, 'x', beta, 'y']);
            expect(result.stderr, equals('❌ Missing required named param: $bold${red}charlie$reset\n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', [charlie, 'z']);
              expect(result.stderr,
                  equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', [alpha, 'x', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}beta$reset\n'));
            });
            test('prints error when required param is not specified', () async {
              final result = await Process.run('hello', [beta, 'y', charlie, 'z']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}alpha$reset\n'));
            });
            test('prints "A: x, B: y, C: z"', () async {
              final result = await Process.run('hello', [alpha, 'x', beta, 'y', charlie, 'z']);
              expect(result.stdout, equals('A: x, B: y, C: z\n'));
            });
          }
        }
      }

      test('prints error when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(
            result.stderr,
            equals(
                '❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset, $bold${red}charlie$reset\n'));
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
                    '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
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
                      '❌ Missing value for params: $bold${red}alpha$reset, $bold${red}charlie$reset\n'));
            });

            test('prints error when no value for required params [$beta] and [$charlie] is specified', () async {
              final result = await Process.run('hello', [beta, charlie]);
              expect(
                  result.stderr,
                  equals(
                      '❌ Missing value for params: $bold${red}beta$reset, $bold${red}charlie$reset\n'));
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
    ${magenta}beta (--beta, -b)$reset
    ${magenta}charlie (-c, --charlie)$reset
'''));
        });
      }
    },
  );
}
