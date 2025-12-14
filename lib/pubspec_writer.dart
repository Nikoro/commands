import 'dart:io';

import 'package:commands_cli/installation_source.dart';

/// Returns true if the pubspec was modified
Future<bool> writePubspec(Directory projectDir, Iterable<String> newKeys) async {
  final pubspecFile = File('${projectDir.path}/pubspec.yaml');

  // Collect existing executables if pubspec.yaml exists
  final existingKeys = <String>{};
  if (pubspecFile.existsSync()) {
    final lines = pubspecFile.readAsLinesSync();
    bool inExecutables = false;
    for (final line in lines) {
      if (line.trim() == 'executables:') {
        inExecutables = true;
        continue;
      }
      if (inExecutables) {
        if (line.trim().isEmpty || !line.contains(':')) break;
        final key = line.split(':').first.trim();
        if (key.isNotEmpty) existingKeys.add(key);
      }
    }
  }

  // Merge and sort
  final allKeys = {...existingKeys, ...newKeys}.toList()..sort();

  // Build executables block
  final executables = allKeys.map((k) => '  $k: $k').join('\n');

  // Detect installation source and build dependency block
  final installationInfo = await detectInstallationSource();
  final dependencyBlock = _buildDependencyBlock(installationInfo);

  // Write new pubspec.yaml (override fully)
  final content = '''
name: generated_commands
description: Generated commands from commands.yaml
version: 1.0.0
environment:
  sdk: ^3.0.0

dev_dependencies:
$dependencyBlock

executables:
$executables
''';

  // Check if content changed
  if (pubspecFile.existsSync() && pubspecFile.readAsStringSync() == content) {
    return false;
  }

  pubspecFile.writeAsStringSync(content);
  return true;
}

String _buildDependencyBlock(InstallationInfo info) {
  if (info.source == InstallationSource.git) {
    // Build git dependency
    final buffer = StringBuffer();
    buffer.writeln('  commands_cli:');
    buffer.writeln('    git:');
    buffer.write('      url: ${info.gitUrl ?? 'https://github.com/Nikoro/commands_cli.git'}');

    // Add git ref if available
    if (info.gitRef != null) {
      buffer.writeln();
      buffer.write('      ref: ${info.gitRef}');
    }

    return buffer.toString();
  } else {
    // Build hosted (pub.dev) dependency
    if (info.version != null) {
      return '  commands_cli: ^${info.version}';
    } else {
      // Fallback if version couldn't be detected
      return '  commands_cli: any';
    }
  }
}
