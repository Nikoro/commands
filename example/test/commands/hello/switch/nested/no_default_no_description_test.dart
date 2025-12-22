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
            - level1b:
              script: echo "Level 1b"
            - level1c:
              script: echo "Level 1c"
    ''',
    () {
      test('shows interactive picker when option with nested switch is not specified', () async {
        final result = await Process.run('hello', ['level1a']);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello level1a$reset:

    ${green}1. level2a ✓$reset
    2. level2b  
    3. level2c  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      test('prints "Level 1b"', () async {
        final result = await Process.run('hello', ['level1b']);
        expect(result.stdout, equals('Level 1b\n'));
      });

      test('prints "Level 1c"', () async {
        final result = await Process.run('hello', ['level1c']);
        expect(result.stdout, equals('Level 1c\n'));
      });

      test('shows interactive picker when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. level1a ✓$reset
    2. level1b  
    3. level1c  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
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
  ${blue}level1b$reset
  ${blue}level1c$reset
'''));
        });
      }
    },
  );
}
