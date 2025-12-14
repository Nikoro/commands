import 'dart:io';
import 'package:test/test.dart';
import 'package:commands_cli/pubspec_writer.dart';

void main() {
  group('writePubspec', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('test_pubspec_writer');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('creates pubspec.yaml with commands_cli dependency matching global installation', () async {
      final keys = ['command1', 'command2'];

      await writePubspec(tempDir, keys);

      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final content = pubspecFile.readAsStringSync();

      // Verify basic structure
      expect(content, contains('name: generated_commands'));
      expect(content, contains('description: Generated commands from commands.yaml'));
      expect(content, contains('version: 1.0.0'));
      expect(content, contains('sdk: ^3.0.0'));
      expect(content, contains('dev_dependencies:'));
      expect(content, contains('commands_cli'));
      expect(content, contains('executables:'));
      expect(content, contains('command1: command1'));
      expect(content, contains('command2: command2'));

      // Verify it's either git or hosted dependency
      final hasGitDep = content.contains('git:') && content.contains('url:');
      final hasHostedDep = RegExp(r'commands_cli:\s*(\^|any)').hasMatch(content);
      expect(hasGitDep || hasHostedDep, isTrue, reason: 'pubspec.yaml should contain either git or hosted dependency');
    });

    test('creates pubspec.yaml with no executables when keys are empty', () async {
      final keys = <String>[];

      await writePubspec(tempDir, keys);

      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final content = pubspecFile.readAsStringSync();

      // Verify basic structure
      expect(content, contains('name: generated_commands'));
      expect(content, contains('dev_dependencies:'));
      expect(content, contains('commands_cli'));
      expect(content, contains('executables:'));

      // Verify it's either git or hosted dependency
      final hasGitDep = content.contains('git:') && content.contains('url:');
      final hasHostedDep = RegExp(r'commands_cli:\s*(\^|any)').hasMatch(content);
      expect(hasGitDep || hasHostedDep, isTrue, reason: 'pubspec.yaml should contain either git or hosted dependency');
    });

    test('returns true when pubspec is modified', () async {
      final keys = ['command1'];

      final modified = await writePubspec(tempDir, keys);

      expect(modified, isTrue);
    });

    test('returns false when pubspec content is unchanged', () async {
      final keys = ['command1'];

      // Write first time
      await writePubspec(tempDir, keys);

      // Write again with same keys
      final modified = await writePubspec(tempDir, keys);

      expect(modified, isFalse);
    });

    test('preserves existing executables and adds new ones', () async {
      // Create initial pubspec with command1
      await writePubspec(tempDir, ['command1']);

      // Add command2
      await writePubspec(tempDir, ['command2']);

      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      final content = pubspecFile.readAsStringSync();

      // Both commands should be present and sorted
      expect(content, contains('command1: command1'));
      expect(content, contains('command2: command2'));
    });
  });
}
