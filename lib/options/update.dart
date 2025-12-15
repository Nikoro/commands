import 'dart:io';

import 'package:commands_cli/colors.dart';
import 'package:commands_cli/extensions.dart';
import 'package:commands_cli/installation_source.dart';

Future<void> handleUpdate() async {
  final isGlobalExecution = Platform.script.toFilePath().contains('.pub-cache/global_packages');

  final ProcessResult result;

  if (isGlobalExecution) {
    // Determine if installed from git or pub.dev
    final installationInfo = await detectInstallationSource();

    if (installationInfo.source == InstallationSource.git) {
      // Update from git repository
      print('${bold}Updating global commands_cli package from git...$reset\n');
      result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', '--source', 'git', 'https://github.com/Nikoro/commands_cli.git'],
        runInShell: true,
      );
    } else {
      // Update from pub.dev
      print('${bold}Updating global commands_cli package...$reset\n');
      result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'commands_cli'],
        runInShell: true,
      );
    }
  } else {
    // Update local dependency
    print('${bold}Updating local commands_cli dependency...$reset\n');
    result = await Process.run(
      'dart',
      ['pub', 'upgrade', 'commands_cli'],
      runInShell: true,
    );
  }

  if (result.exitCode == 0) {
    final output = result.stdout.toString();
    print(output);

    // Check if already up to date
    if (output.containsAny([
      'already activated at newest available version',
      'is already active',
      'already using',
    ])) {
      print('$bold$blue Already up to date!$reset');
    } else {
      print('$bold$green✓ Successfully updated!$reset\n');

      // Regenerate commands after update
      await Process.run(
        'commands',
        ['regenerate'],
        runInShell: true,
      );
    }
  } else {
    print('$red✗ Update failed:$reset');
    print(result.stderr);
    exit(1);
  }
}
