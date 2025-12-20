import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

import '../../integration_tests.dart';

void main() {
  integrationTests(
    '''
        hello:
          script: echo "Hello World"
    ''',
    () {
      test('prints "Hello World"', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello World\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('${blue}hello$reset\n'));
        });
      }
    },
  );

  integrationTests(
    '''
        hello: ## Description of command hello
          script: echo "Hello World"
    ''',
    () {
      test('prints "Hello World"', () async {
        final result = await Process.run('hello', []);
        expect(result.stdout, equals('Hello World\n'));
      });

      for (String flag in ['-h', '--help']) {
        test('$flag prints help', () async {
          final result = await Process.run('hello', [flag]);
          expect(result.stdout, equals('${blue}hello$reset: ${gray}Description of command hello$reset\n'));
        });
      }
    },
  );
}
