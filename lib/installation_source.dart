import 'dart:io';

enum InstallationSource {
  git,
  hosted,
}

class InstallationInfo {
  final InstallationSource source;
  final String? gitUrl;
  final String? gitRef;
  final String? version;

  InstallationInfo({
    required this.source,
    this.gitUrl,
    this.gitRef,
    this.version,
  });
}

/// Detects the installation source of commands_cli from the global pub cache
Future<InstallationInfo> detectInstallationSource() async {
  try {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      return InstallationInfo(source: InstallationSource.hosted);
    }

    final pubspecLockPath = '$home/.pub-cache/global_packages/commands_cli/pubspec.lock';
    final pubspecLockFile = File(pubspecLockPath);

    if (!await pubspecLockFile.exists()) {
      return InstallationInfo(source: InstallationSource.hosted);
    }

    final content = await pubspecLockFile.readAsString();

    // Parse the pubspec.lock to find the commands_cli package entry
    final commandsCliSection = RegExp(
      r'commands_cli:.*?source:\s*(\w+)',
      dotAll: true,
    ).firstMatch(content);

    if (commandsCliSection != null) {
      final source = commandsCliSection.group(1);

      if (source == 'git') {
        // Extract git URL and ref
        final gitUrlMatch = RegExp(
          r'url:\s*"([^"]+)"',
        ).firstMatch(content);

        final gitRefMatch = RegExp(
          r'resolved-ref:\s*"?([a-f0-9]+)"?',
        ).firstMatch(content);

        return InstallationInfo(
          source: InstallationSource.git,
          gitUrl: gitUrlMatch?.group(1),
          gitRef: gitRefMatch?.group(1),
        );
      } else if (source == 'hosted') {
        // Extract version from pub.dev
        final versionMatch = RegExp(
          r'commands_cli:.*?version:\s*"([^"]+)"',
          dotAll: true,
        ).firstMatch(content);

        return InstallationInfo(
          source: InstallationSource.hosted,
          version: versionMatch?.group(1),
        );
      }
    }

    // Default to hosted (pub.dev)
    return InstallationInfo(source: InstallationSource.hosted);
  } catch (e) {
    // If we can't detect, assume hosted (pub.dev)
    return InstallationInfo(source: InstallationSource.hosted);
  }
}
