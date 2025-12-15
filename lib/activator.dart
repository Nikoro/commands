import 'dart:io';

Future<bool> isPackageActivated(String packageName) async {
  final result = await Process.run('dart', ['pub', 'global', 'list'], runInShell: true);
  return result.stdout.toString().contains('$packageName ');
}

Future<Set<String>> getExistingSnapshots() async {
  // Check for actual snapshot files created by git dependencies
  final home = Platform.environment['HOME'];
  if (home == null) return {};

  final snapshotDir = Directory('$home/.generated_commands/.dart_tool/pub/bin/generated_commands');
  if (!snapshotDir.existsSync()) return {};

  final snapshots = <String>{};
  await for (final entity in snapshotDir.list()) {
    if (entity is File && entity.path.endsWith('.snapshot')) {
      // Extract command name from filename like: s1_no_comment.dart-3.9.2.snapshot
      final filename = entity.path.split('/').last;
      final commandName = filename.split('.dart-').first;
      snapshots.add(commandName);
    }
  }
  return snapshots;
}

Future<int> activatePackage(Directory projectDir) async {
  final result = await Process.run(
      'dart',
      [
        'pub',
        'global',
        'activate',
        '--source',
        'path',
        projectDir.absolute.path,
      ],
      runInShell: true);
  if (result.exitCode != 0) {
    print(result.stderr);
  }
  return result.exitCode;
}

Future<void> warmUpCommands(Iterable keys, {void Function(int current, int total)? onProgress}) async {
  // Sequential execution required for proper snapshot creation
  // Parallel execution interferes with Dart's compilation caching
  final commandsList = keys.toList();
  for (var i = 0; i < commandsList.length; i++) {
    final name = commandsList[i];
    await Process.run('dart', ['pub', 'global', 'run', 'generated_commands:$name', '--help'], runInShell: true);
    onProgress?.call(i + 1, commandsList.length);
  }
}

Iterable<String> getCommandsNeedingWarmup(Iterable<String> allCommands, Set<String> existingSnapshots) {
  return allCommands.where((cmd) => !existingSnapshots.contains(cmd));
}
