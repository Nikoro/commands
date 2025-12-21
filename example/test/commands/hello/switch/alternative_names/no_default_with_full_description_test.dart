import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1: '-o1, one' ## Description of option 1
              script: echo "Option 1"
            - opt2: -o2, two ## Description of option 2
              script: echo "Option 2"
            - opt3: "-o3, three" ## Description of option 3
              script: echo "Option 3"
    ''',
    () {
      for (String option in ['opt1', '-o1', 'one']) {
        test('prints "Option 1"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 1\n'));
        });
      }

      for (String option in ['opt2', '-o2', 'two']) {
        test('prints "Option 2"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 2\n'));
        });
      }
      for (String option in ['opt3', '-o3', 'three']) {
        test('prints "Option 3"', () async {
          final result = await Process.run('hello', [option]);
          expect(result.stdout, equals('Option 3\n'));
        });
      }
      test('shows interactive picker when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(
          result.stdout,
          equals('''

Select an option for ${blue}hello$reset:

    ${green}1. opt1 ✓$reset or ${green}-o1$reset, ${green}one$reset ${gray}- Description of option 1$reset
    2. opt2   or -o2, two$reset ${gray}- Description of option 2$reset
    3. opt3   or -o3, three$reset ${gray}- Description of option 3$reset

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset or ${blue}-o1$reset, ${blue}one$reset: ${gray}Description of option 1$reset
  ${blue}opt2$reset or ${blue}-o2$reset, ${blue}two$reset: ${gray}Description of option 2$reset
  ${blue}opt3$reset or ${blue}-o3$reset, ${blue}three$reset: ${gray}Description of option 3$reset
'''));
        });
      }
    },
  );
}
