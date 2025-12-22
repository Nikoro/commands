import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: |
            echo "A: {alpha}, B: {beta}, C: {charlie}"
          params:
            required:
              - alpha: '-a, --alpha' ## Description of parameter alpha
                values: [A1, A2, A3]
              - beta: '--beta, -b' ## Description of parameter beta
              - charlie: '-c, --charlie' ## Description of parameter charlie
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        for (String value in ['A1', 'A2', 'A3']) {
          test('prints error when required params is not specified', () async {
            final result = await Process.run('hello', [alpha, value]);
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
              final result = await Process.run('hello', [alpha, value, beta, 'y']);
              expect(result.stderr, equals('❌ Missing required named param: $bold${red}charlie$reset\n'));
            });

            for (String charlie in ['-c', '--charlie']) {
              test('prints error when required param is not specified', () async {
                final result = await Process.run('hello', [charlie, 'z']);
                expect(result.stderr,
                    equals('❌ Missing required named params: $bold${red}alpha$reset, $bold${red}beta$reset\n'));
              });
              test('prints error when required param is not specified', () async {
                final result = await Process.run('hello', [alpha, value, charlie, 'z']);
                expect(result.stderr, equals('❌ Missing required named param: $bold${red}beta$reset\n'));
              });

              test('shows interactive picker when required param is not specified', () async {
                final result = await Process.run('hello', [beta, 'y', charlie, 'z']);
                expect(
                  result.stdout,
                  equals('''

Select value for ${blue}alpha$reset:
${gray}Description of parameter alpha$reset

    ${green}1. A1 ✓$reset
    2. A2  
    3. A3  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
                );
              });
              test('prints "A: $value, B: y, C: z"', () async {
                final result = await Process.run('hello', [alpha, value, beta, 'y', charlie, 'z']);
                expect(result.stdout, equals('A: $value, B: y, C: z\n'));
              });
            }
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
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}alpha (-a, --alpha)$reset ${gray}Description of parameter alpha$reset
    ${bold}values$reset: A1, A2, A3
    ${magenta}beta (--beta, -b)$reset ${gray}Description of parameter beta$reset
    ${magenta}charlie (-c, --charlie)$reset ${gray}Description of parameter charlie$reset
'''));
        });
      }
    },
  );
}
