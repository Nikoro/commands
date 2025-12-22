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
            optional:
              - alpha: '-a, --alpha' ## Description of parameter alpha
                values: [A1, A2, A3]
              - beta: '--beta, -b' ## Description of parameter beta
              - charlie: '-c, --charlie' ## Description of parameter charlie
    ''',
    () {
      for (String alpha in ['-a', '--alpha']) {
        for (String value in ['A1', 'A2', 'A3']) {
          test('prints "A: $value, B: , C: "', () async {
            final result = await Process.run('hello', [alpha, value]);
            expect(result.stdout, equals('A: $value, B: , C: \n'));
          });
          for (String beta in ['-b', '--beta']) {
            test('prints "A: , B: y, C: "', () async {
              final result = await Process.run('hello', [beta, 'y']);
              expect(result.stdout, equals('A: , B: y, C: \n'));
            });
            test('prints "A: $value, B: y, C: "', () async {
              final result = await Process.run('hello', [alpha, value, beta, 'y']);
              expect(result.stdout, equals('A: $value, B: y, C: \n'));
            });

            for (String charlie in ['-c', '--charlie']) {
              test('prints "A: , B: , C: z"', () async {
                final result = await Process.run('hello', [charlie, 'z']);
                expect(result.stdout, equals('A: , B: , C: z\n'));
              });
              test('prints "A: $value, B: , C: z"', () async {
                final result = await Process.run('hello', [alpha, value, charlie, 'z']);
                expect(result.stdout, equals('A: $value, B: , C: z\n'));
              });
              test('prints "A: , B: y, C: z"', () async {
                final result = await Process.run('hello', [beta, 'y', charlie, 'z']);
                expect(result.stdout, equals('A: , B: y, C: z\n'));
              });
              test('prints "A: $value, B: y, C: z"', () async {
                final result = await Process.run('hello', [alpha, value, beta, 'y', charlie, 'z']);
                expect(result.stdout, equals('A: $value, B: y, C: z\n'));
              });
            }
          }
        }
      }

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: , B: , C: \n'));
      });

      for (String alpha in ['-a', '--alpha']) {
        test('prints "A: , B: , C: " when no value for optional param [$alpha] is specified', () async {
          final result = await Process.run('hello', [alpha]);
          expect(result.stdout, equals('A: , B: , C: \n'));
        });

        for (String beta in ['-b', '--beta']) {
          test('prints "A: , B: , C: " when no value for optional param [$beta] is specified', () async {
            final result = await Process.run('hello', [beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$beta] is specified', () async {
            final result = await Process.run('hello', [alpha, beta]);
            expect(result.stdout, equals('A: , B: , C: \n'));
          });

          for (String charlie in ['-c', '--charlie']) {
            test('prints "A: , B: , C: " when no value for optional param [$charlie] is specified', () async {
              final result = await Process.run('hello', [charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$alpha] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', [alpha, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test('prints "A: , B: , C: " when no value for optional params [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', [beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
            });

            test(
                'prints "A: , B: , C: " when no value for optional params [$alpha], [$beta] and [$charlie] is specified',
                () async {
              final result = await Process.run('hello', [alpha, beta, charlie]);
              expect(result.stdout, equals('A: , B: , C: \n'));
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
  optional:
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
