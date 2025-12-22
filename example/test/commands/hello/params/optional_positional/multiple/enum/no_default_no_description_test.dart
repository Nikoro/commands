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
              - beta:
              - charlie:
    ''',
    () {
      for (String value in ['A1', 'A2', 'A3']) {
        test('prints "A: $value, B: , C: "', () async {
          final result = await Process.run('hello', [value]);
          expect(result.stdout, equals('A: $value, B: , C: \n'));
        });

        test('prints "A: $value, B: y, C: "', () async {
          final result = await Process.run('hello', [value, 'y']);
          expect(result.stdout, equals('A: $value, B: y, C: \n'));
        });

        test('prints "A: $value, B: y, C: z"', () async {
          final result = await Process.run('hello', [value, 'y', 'z']);
          expect(result.stdout, equals('A: $value, B: y, C: z\n'));
        });
      }

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: , B: , C: \n'));
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
    ${magenta}beta$reset
    ${magenta}charlie$reset
'''));
        });
      }
    },
  );
}
