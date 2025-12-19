import 'dart:io';
import 'package:commands_cli/commands_loader.dart';
import 'package:test/test.dart';

void main() {
  group('Typed enum loader validation', () {
    late Directory tempDir;
    late File testYaml;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('typed_enum_test_');
      testYaml = File('${tempDir.path}/commands.yaml');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('stores validation error for int enum with string value (no default)', () {
      testYaml.writeAsStringSync('''
test_invalid_enum:
  script: echo "platform={platform}"
  params:
    required:
      - platform:
        type: int
        values: [ios, 1, 2]
''');

      final commands = loadCommandsFrom(testYaml);
      expect(commandValidationErrors.containsKey('test_invalid_enum'), isTrue,
          reason: 'Expected validation error for test_invalid_enum');
      expect(commandValidationErrors['test_invalid_enum'], contains('platform'));
      expect(commandValidationErrors['test_invalid_enum'], contains('[integer]'));
      expect(commands.containsKey('test_invalid_enum'), isFalse,
          reason: 'Invalid command should not be in commands map');
    });

    test('stores validation error for int enum with string and double values (no default)', () {
      testYaml.writeAsStringSync('''
test_invalid_enum_multi:
  script: echo "platform={platform}"
  params:
    required:
      - platform:
        type: int
        values: [ios, 1, 2.2]
''');

      final commands = loadCommandsFrom(testYaml);
      expect(commandValidationErrors.containsKey('test_invalid_enum_multi'), isTrue,
          reason: 'Expected validation error for test_invalid_enum_multi');
      expect(commandValidationErrors['test_invalid_enum_multi'], contains('platform'));
      expect(commandValidationErrors['test_invalid_enum_multi'], contains('"ios"'));
      expect(commandValidationErrors['test_invalid_enum_multi'], contains('"2.2"'));
      expect(commands.containsKey('test_invalid_enum_multi'), isFalse,
          reason: 'Invalid command should not be in commands map');
    });
  });
}
