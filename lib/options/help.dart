import 'package:commands_cli/colors.dart';

void showHelp() {
  final options = [
    ('help, --help, -h', 'Display this help message'),
    ('version, --version, -v', 'Show the current version of commands'),
    ('update, --update, -u', 'Update commands package to the latest version'),
    ('list, --list, -l', 'List all installed commands'),
    ('create [--empty|-e]', 'Create a new commands.yaml file (use --empty or -e for empty file)'),
    ('watch, --watch, -w', 'Watch commands.yaml for changes and auto-reload'),
    ('--watch-detached, -wd', 'Start watching in detached mode (background process)'),
    ('--watch-kill, -wk', 'Kill the detached watcher process'),
    ('--watch-kill-all, -wka', 'Kill all detached watcher processes'),
    ('deactivate, --deactivate, -d [command]', 'Deactivate commands package or specific commands'),
    ('clean, --clean, -c', 'Remove all generated commands'),
  ];

  final flags = [
    ('--silent, -s', 'Suppress success output (only show errors/warnings)'),
    ('--exit-error, -ee', 'Exit with code 1 immediately on error'),
    ('--exit-warning, -ew', 'Exit with code 1 immediately on error or warning'),
  ];

  final maxLength = [...options, ...flags].map((o) => o.$1.length).reduce((a, b) => a > b ? a : b);

  print('''
${bold}Commands - CLI tool for managing custom commands$reset

${bold}Usage:$reset commands [option] [flags]

${bold}Options:$reset''');

  for (final (option, description) in options) {
    final padding = ' ' * (maxLength - option.length);
    print('  $blue$option$reset$padding  $gray- $description$reset');
  }

  print('\n${bold}Flags:$reset');

  for (final (flag, description) in flags) {
    final padding = ' ' * (maxLength - flag.length);
    print('  $blue$flag$reset$padding  $gray- $description$reset');
  }

  print('''

${bold}Default behavior:$reset
  Running ${blue}commands$reset without arguments will load and activate
  all commands from commands.yaml in the current directory

${bold}Examples:$reset
  $blue commands --silent$reset              Activate commands without success output
  $blue commands -s -ee$reset                Silent mode, exit on error
  $blue commands --exit-warning$reset        Exit with error code if warnings occur''');
}
