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
            optional:
              - alpha:
                values: [A1, A2, A3]
                default: "A1"
              - beta:
                default: "B1"
              - charlie:
                default: "C1"
    ''',
    () {
      for (String value in ['A1', 'A2', 'A3']) {
        test('prints "A: $value, B: B1, C: C1"', () async {
          final result = await Process.run('hello', [value]);
          expect(result.stdout, equals('A: $value, B: B1, C: C1\n'));
        });

        test('prints "A: $value, B: y, C: C1"', () async {
          final result = await Process.run('hello', [value, 'y']);
          expect(result.stdout, equals('A: $value, B: y, C: C1\n'));
        });

        test('prints "A: $value, B: y, C: z"', () async {
          final result = await Process.run('hello', [value, 'y', 'z']);
          expect(result.stdout, equals('A: $value, B: y, C: z\n'));
        });
      }

      test('prints "A: A1, B: B1, C: C1" when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: A1, B: B1, C: C1\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
params:
  optional:
    ${magenta}alpha$reset
    ${bold}values$reset: A1, A2, A3
    ${bold}default$reset: "A1"
    ${magenta}beta$reset
    ${bold}default$reset: "B1"
    ${magenta}charlie$reset
    ${bold}default$reset: "C1"
'''));
        });
      }
    },
  );
}
