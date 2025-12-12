import 'package:commands_cli/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Flag parsing', () {
    group('--silent flag', () {
      test('recognizes --silent', () {
        final args = ['--silent'];
        expect(args.containsAny(['--silent', '-s']), isTrue);
      });

      test('recognizes -s', () {
        final args = ['-s'];
        expect(args.containsAny(['--silent', '-s']), isTrue);
      });

      test('does not match other flags', () {
        final args = ['--version'];
        expect(args.containsAny(['--silent', '-s']), isFalse);
      });
    });

    group('--exit-error flag', () {
      test('recognizes --exit-error', () {
        final args = ['--exit-error'];
        expect(args.containsAny(['--exit-error', '-ee']), isTrue);
      });

      test('recognizes -ee', () {
        final args = ['-ee'];
        expect(args.containsAny(['--exit-error', '-ee']), isTrue);
      });

      test('does not match other flags', () {
        final args = ['--exit-warning'];
        expect(args.containsAny(['--exit-error', '-ee']), isFalse);
      });
    });

    group('--exit-warning flag', () {
      test('recognizes --exit-warning', () {
        final args = ['--exit-warning'];
        expect(args.containsAny(['--exit-warning', '-ew']), isTrue);
      });

      test('recognizes -ew', () {
        final args = ['-ew'];
        expect(args.containsAny(['--exit-warning', '-ew']), isTrue);
      });

      test('does not match other flags', () {
        final args = ['--exit-error'];
        expect(args.containsAny(['--exit-warning', '-ew']), isFalse);
      });
    });

    group('Combined flags', () {
      test('recognizes multiple flags together', () {
        final args = ['-s', '-ee'];
        expect(args.containsAny(['--silent', '-s']), isTrue);
        expect(args.containsAny(['--exit-error', '-ee']), isTrue);
      });

      test('recognizes mixed short and long flags', () {
        final args = ['--silent', '-ee', '--exit-warning'];
        expect(args.containsAny(['--silent', '-s']), isTrue);
        expect(args.containsAny(['--exit-error', '-ee']), isTrue);
        expect(args.containsAny(['--exit-warning', '-ew']), isTrue);
      });

      test('filters out flags correctly', () {
        final args = ['--silent', '-ee', 'help'];
        final cleanArgs = args.where((arg) =>
          !['--silent', '-s', '--exit-error', '-ee', '--exit-warning', '-ew'].contains(arg)
        ).toList();

        expect(cleanArgs, equals(['help']));
      });

      test('preserves other arguments when filtering flags', () {
        final args = ['--silent', 'create', '-ee', '--empty'];
        final cleanArgs = args.where((arg) =>
          !['--silent', '-s', '--exit-error', '-ee', '--exit-warning', '-ew'].contains(arg)
        ).toList();

        expect(cleanArgs, equals(['create', '--empty']));
      });
    });
  });
}
