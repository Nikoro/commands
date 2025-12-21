import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../../../../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello {name}"
          params:
            required:
              - name: ## Description of parameter name
                values: [Alpha, Bravo, Charlie]
    ''',
    () {
      for (Object param in ['Alpha', 'Bravo', 'Charlie']) {
        test('prints "Hello $param"', () async {
          final result = await Process.run('hello', ['$param']);
          expect(result.stdout, equals('Hello $param\n'));
        });
      }

      test('shows interactive picker when no required param is specified', () async {
        final result = await Process.run('hello', []);
        expect(
          result.stdout,
          equals('''

Select value for ${blue}name$reset:
${gray}Description of parameter name$reset

    ${green}1. Alpha   ✓$reset
    2. Bravo    
    3. Charlie  

${gray}Press number (1-3) or press Esc to cancel:$reset
'''),
        );
      });

      test('prints error when invalid value for required param is specified', () async {
        final result = await Process.run('hello', ['Delta']);
        expect(result.stderr, equals('''
❌ Parameter $bold${red}name$reset has invalid value: "Delta"
💡 Must be one of: $bold${green}Alpha$reset, $bold${green}Bravo$reset, $bold${green}Charlie$reset
'''));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('''
${blue}hello$reset: ${gray}Description of command hello$reset
params:
  required:
    ${magenta}name$reset ${gray}Description of parameter name$reset
    ${bold}values$reset: Alpha, Bravo, Charlie
'''));
        });
      }
    },
  );
}
