import 'dart:io';
import 'package:commands_cli/colors.dart';
import 'package:test/test.dart';

void main() {
  group('commands flags', () {
    group('--silent flag', () {
      test('--silent suppresses success output but shows errors', () async {
        final result = await Process.run('commands', ['--silent']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // Should still contain warnings (⚠️) - there's a 'test' reserved command
        expect(output, contains('⚠️'));

        // Should still contain errors (❌)
        expect(output, contains('❌'));

        expect(result.exitCode, equals(0));
      });

      test('-s is shorthand for --silent', () async {
        final result = await Process.run('commands', ['-s']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // Should still contain warnings (⚠️)
        expect(output, contains('⚠️'));

        // Should still contain errors (❌)
        expect(output, contains('❌'));

        expect(result.exitCode, equals(0));
      });
    });

    group('--exit-error flag', () {
      test('--exit-error exits with code 1 when errors exist', () async {
        final result = await Process.run('commands', ['--exit-error']);

        // Should exit with code 1 because there are errors in the YAML
        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should still show the errors
        expect(output, contains('❌'));
      });

      test('-ee is shorthand for --exit-error', () async {
        final result = await Process.run('commands', ['-ee']);

        // Should exit with code 1 because there are errors in the YAML
        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should still show the errors
        expect(output, contains('❌'));
      });
    });

    group('--exit-warning flag', () {
      test('--exit-warning exits with code 1 when warnings exist', () async {
        final result = await Process.run('commands', ['--exit-warning']);

        // Should exit with code 1 because there are warnings in the YAML (reserved 'test' command)
        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should show warnings and errors
        expect(output, contains('⚠️'));
        expect(output, contains('❌'));
      });

      test('-ew is shorthand for --exit-warning', () async {
        final result = await Process.run('commands', ['-ew']);

        // Should exit with code 1 because there are warnings in the YAML
        expect(result.exitCode, equals(1));

        final output = result.stdout as String;

        // Should show warnings and errors
        expect(output, contains('⚠️'));
        expect(output, contains('❌'));
      });
    });

    group('Combined flags', () {
      test('--silent --exit-error shows only errors and exits', () async {
        final result = await Process.run('commands', ['--silent', '--exit-error']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // In silent mode with errors, should still show warnings
        expect(output, contains('⚠️'));

        // Should show errors
        expect(output, contains('❌'));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });

      test('-s -ee works as shorthand', () async {
        final result = await Process.run('commands', ['-s', '-ee']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // Should show errors and warnings
        expect(output, contains('❌'));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });

      test('--silent --exit-warning shows only errors/warnings and exits', () async {
        final result = await Process.run('commands', ['--silent', '--exit-warning']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // Should show warnings
        expect(output, contains('⚠️'));

        // Should show errors
        expect(output, contains('❌'));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });

      test('-s -ew works as shorthand', () async {
        final result = await Process.run('commands', ['-s', '-ew']);

        final output = result.stdout as String;

        // Should NOT contain success messages (✅)
        expect(output, isNot(contains('✅')));

        // Should show warnings and errors
        expect(output, contains('⚠️'));
        expect(output, contains('❌'));

        // Should exit with code 1
        expect(result.exitCode, equals(1));
      });
    });

    group('Flags with other commands', () {
      test('flags do not interfere with help', () async {
        final result = await Process.run('commands', ['--help', '--silent']);

        final output = result.stdout as String;

        // Should show help output
        expect(output, contains('Commands - CLI tool'));
        expect(output, contains('--silent, -s'));
        expect(output, contains('--exit-error, -ee'));
        expect(output, contains('--exit-warning, -ew'));

        expect(result.exitCode, equals(0));
      });

      test('flags do not interfere with version', () async {
        final result = await Process.run('commands', ['--version', '-s']);

        final output = result.stdout as String;

        // Should show version
        expect(output, contains('commands_cli version:'));

        expect(result.exitCode, equals(0));
      });

      test('flags do not interfere with list', () async {
        final result = await Process.run('commands', ['--list', '--silent']);

        final output = result.stdout as String;

        // Should show list
        expect(output, contains('Installed commands:'));

        expect(result.exitCode, equals(0));
      });
    });
  });
}
