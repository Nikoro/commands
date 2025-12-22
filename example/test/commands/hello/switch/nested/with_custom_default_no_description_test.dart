import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          switch:
            - level1a:
              switch:
                - level2a:
                  script: echo "Level 1a 2a"
                - level2b:
                  script: echo "Level 1a 2b"
                - level2c:
                  script: echo "Level 1a 2c"
                - default:
                  script: echo "Level 1a Custom"
            - level1b:
              script: echo "Level 1b"
            - level1c:
              script: echo "Level 1c"
            - default:
              script: echo "Custom"
    ''',
    () {
      test('runs default option when option with nested switch is not specified', () async {
        final result = await Process.run('hello', ['level1a']);
        expect(result.stdout, equals('Level 1a Custom\n'));
      });

      test('prints "Level 1b"', () async {
        final result = await Process.run('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await Process.run('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Custom\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset
options:
  ${blue}level1a$reset
  options:
    ${blue}level2a$reset
    ${blue}level2b$reset
    ${blue}level2c$reset
    ${bold}default$reset
  ${blue}level1b$reset
  ${blue}level1c$reset
  ${bold}default$reset
'''));
        });
      }
    },
  );
}
