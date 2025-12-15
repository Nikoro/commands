import 'dart:io';

import 'package:commands_cli/activator.dart';
import 'package:commands_cli/bin_writer.dart';
import 'package:commands_cli/colors.dart';
import 'package:commands_cli/detached_watcher.dart';
import 'package:commands_cli/extensions.dart';
import 'package:commands_cli/generated_commands.dart';
import 'package:commands_cli/pubspec_writer.dart';

Future<void> handleRegenerate() async {
  // Step 1: Get list of currently generated commands before cleaning
  final commands = GeneratedCommands.binDir.existsSync()
      ? GeneratedCommands.binDir.listSync().map((e) => (e as File).onlyName).toList()
      : <String>[];

  if (commands.isEmpty) {
    print('⚠️  ${yellow}No commands to regenerate$reset');
    exit(0);
  }

  // Step 2: Perform clean (same as handleClean but without deleting GeneratedCommands)
  await killAllWatchers(silent: true);
  await Process.run('dart', ['pub', 'global', 'deactivate', 'generated_commands'], runInShell: true);

  // Step 3: Ensure the generated_commands directory exists
  GeneratedCommands.ensureExists();

  // Step 4: Recreate bin files for the commands
  writeBinFiles(GeneratedCommands.binDir, commands);

  // Step 5: Write the pubspec.yaml with the commands
  await writePubspec(GeneratedCommands.dir, commands);

  // Step 6: Activate the generated_commands package
  final activationResult = await activatePackage(GeneratedCommands.dir);
  if (activationResult != 0) {
    print('❌ Failed to activate commands package');
    exit(1);
  }

  // Step 7: Warm up all commands to create snapshots
  final commandText = '🔄 Regenerating ${commands.length} command${commands.length > 1 ? 's' : ''}';
  stdout.write('$commandText - ${gray}0%$reset');
  await warmUpCommands(commands, onProgress: (current, total) {
    final percentage = ((current / total) * 100).round();
    stdout.write('\r$commandText - $gray$percentage%$reset');
  });
  stdout.writeln(); // Move to next line after progress complete

  // Step 8: Reactivate after warmup to register snapshots
  await activatePackage(GeneratedCommands.dir);

  print('✅ ${green}Successfully regenerated all commands$reset');
  exit(0);
}
