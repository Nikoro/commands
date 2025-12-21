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
            optional:
              - alpha:
              - beta:
              - charlie: ## Description of parameter charlie
    ''',
    () {
      test('prints "A: x, B: , C: "', () async {
        final result = await Process.run('hello', ['x']);
        expect(result.stdout, equals('A: x, B: , C: \n'));
      });

      test('prints "A: x, B: y, C: "', () async {
        final result = await Process.run('hello', ['x', 'y']);
        expect(result.stdout, equals('A: x, B: y, C: \n'));
      });

      test('prints "A: x, B: y, C: z"', () async {
        final result = await Process.run('hello', ['x', 'y', 'z']);
        expect(result.stdout, equals('A: x, B: y, C: z\n'));
      });

      test('prints "A: , B: , C: " when no optional param is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('A: , B: , C: \n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  optional:
    ${magenta}alpha$reset
    ${magenta}beta$reset
    ${magenta}charlie$reset ${gray}Description of parameter charlie$reset
'''));
        });
      }
    },
  );
}
