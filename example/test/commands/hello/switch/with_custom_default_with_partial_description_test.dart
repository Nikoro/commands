import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          switch:
            - opt1:
              script: echo "Option 1"
            - opt2: ## Description of option 2
              script: echo "Option 2"
            - opt3:
              script: echo "Option 3"
            - default: ## Description of custom option
              script: echo "Custom"
    ''',
    () {
      test('prints "Option 1"', () async {
        final result = await Process.run('hello', ['opt1']);
        expect(result.stdout, equals('Option 1\n'));
      });

      test('prints "Option 2"', () async {
        final result = await Process.run('hello', ['opt2']);
        expect(result.stdout, equals('Option 2\n'));
      });

      test('prints "Option 3"', () async {
        final result = await Process.run('hello', ['opt3']);
        expect(result.stdout, equals('Option 3\n'));
      });

      test('runs default option when no option is specified', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Custom\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
options:
  ${blue}opt1$reset
  ${blue}opt2$reset: ${gray}Description of option 2$reset
  ${blue}opt3$reset
  ${bold}default$reset: ${gray}Description of custom option$reset
'''));
        });
      }
    },
  );
}
