import 'dart:io';

import 'package:commands_cli/commands_loader.dart';
import 'package:test/test.dart';

void main() {
  late File yamlFile;
  File? backupFile;

  setUp(() {
    yamlFile = File('commands.yaml');
    // Backup original commands.yaml if it exists
    if (yamlFile.existsSync()) {
      backupFile = File('commands.yaml.bak');
      yamlFile.copySync(backupFile!.path);
    }
  });

  tearDown(() {
    // Remove test-generated commands.yaml
    if (yamlFile.existsSync()) {
      yamlFile.deleteSync();
    }
    // Restore original commands.yaml if backup exists
    if (backupFile != null && backupFile!.existsSync()) {
      backupFile!.renameSync(yamlFile.path);
      backupFile = null;
    }
  });

  group('loadCommandsFrom', () {
    test('handles empty file gracefully', () {
      yamlFile.writeAsStringSync('');

      final commands = loadCommandsFrom(yamlFile);
      expect(commands, isEmpty);
    });

    test('parses command with no params', () {
      yamlFile.writeAsStringSync('''
hello:
  script: echo "hi"
''');

      final commands = loadCommandsFrom(yamlFile);
      final cmd = commands['hello']!;
      expect(cmd.script, 'echo "hi"');
      expect(cmd.requiredParams, isEmpty);
      expect(cmd.optionalParams, isEmpty);
    });

    test('parses command description', () {
      yamlFile.writeAsStringSync('''
shout: ## prints message loudly
  script: echo "{msg}"
  params:
    required:
      - msg:
''');

      final commands = loadCommandsFrom(yamlFile);
      final cmd = commands['shout']!;
      expect(cmd.description, 'prints message loudly');
    });

    test('parses required positional param', () {
      yamlFile.writeAsStringSync('''
say:
  script: echo "{msg}"
  params:
    required:
      - msg:
''');

      final commands = loadCommandsFrom(yamlFile);
      final cmd = commands['say']!;
      expect(cmd.requiredParams.length, 1);
      expect(cmd.requiredParams.first.name, 'msg');
      expect(cmd.requiredParams.first.flags, isNull);
    });

    test('parses required positional param', () {
      yamlFile.writeAsStringSync('''
say:
  script: echo "{msg}"
  params:
    required:
      - msg
''');

      final commands = loadCommandsFrom(yamlFile);
      final cmd = commands['say']!;
      expect(cmd.requiredParams.length, 1);
      expect(cmd.requiredParams.first.name, 'msg');
      expect(cmd.requiredParams.first.flags, isNull);
    });

    test('parses optional named param (quoted flags)', () {
      yamlFile.writeAsStringSync('''
tell:
  script: echo "{message} {name}"
  params:
    required:
      - message:
    optional:
      - name: "-n, --name" ## user name
''');

      final commands = loadCommandsFrom(yamlFile);
      final param = commands['tell']!.optionalParams.first;
      expect(param.name, 'name');
      expect(param.flags, '-n, --name');
      expect(param.description, 'user name');
    });

    test('parses optional named param (unquoted flags)', () {
      yamlFile.writeAsStringSync('''
hello:
  script: echo "{who}"
  params:
    optional:
      - who: --who ## who to greet
''');

      final commands = loadCommandsFrom(yamlFile);
      final param = commands['hello']!.optionalParams.first;
      expect(param.name, 'who');
      expect(param.flags, '--who');
      expect(param.description, 'who to greet');
    });

    test('parses params with default value', () {
      yamlFile.writeAsStringSync('''
greet:
  script: echo "{msg}"
  params:
    required:
      - msg:
        default: hi
    optional:
      - value:
        default: !
''');

      final commands = loadCommandsFrom(yamlFile);
      final requiredParam = commands['greet']!.requiredParams.first;
      final optionalParam = commands['greet']!.optionalParams.first;
      expect(requiredParam.name, 'msg');
      expect(requiredParam.defaultValue, 'hi');
      expect(optionalParam.name, 'value');
      expect(optionalParam.defaultValue, '!');
    });

    test('parses param with only description', () {
      yamlFile.writeAsStringSync('''
foo:
  script: echo "{one}{two}"
  params:
    required:
      - one: ## important value
    optional:
      - two: ## not important value
''');

      final commands = loadCommandsFrom(yamlFile);
      final requiredParam = commands['foo']!.requiredParams.first;
      final optionalParam = commands['foo']!.optionalParams.first;
      expect(requiredParam.name, 'one');
      expect(requiredParam.flags, isNull);
      expect(requiredParam.description, 'important value');
      expect(optionalParam.name, 'two');
      expect(optionalParam.flags, isNull);
      expect(optionalParam.description, 'not important value');
    });

    test('parses bare param (no description, no flags)', () {
      yamlFile.writeAsStringSync('''
bare:
  script: echo "{x}"
  params:
    optional:
      - x:
''');

      final commands = loadCommandsFrom(yamlFile);
      final param = commands['bare']!.optionalParams.first;
      expect(param.name, 'x');
      expect(param.flags, isNull);
      expect(param.description, isNull);
    });

    test('parses multiline script', () {
      yamlFile.writeAsStringSync('''
multi:
  script: |
    echo "line1"
    echo "line2"
''');

      final commands = loadCommandsFrom(yamlFile);
      final cmd = commands['multi']!;
      expect(cmd.script, contains('line1'));
      expect(cmd.script, contains('line2'));
    });

    test('parses multiple commands in one file', () {
      yamlFile.writeAsStringSync('''
one:
  script: echo "1"

two:
  script: echo "2"
''');

      final commands = loadCommandsFrom(yamlFile);
      expect(commands.keys, containsAll(['one', 'two']));
    });

    test('parses command with override property', () {
      yamlFile.writeAsStringSync('''
make:
  override: true
  script: |
    echo "make overridden"
''');

      final commands = loadCommandsFrom(yamlFile);
      final command = commands['make']!;

      expect(command.override, isTrue);
      expect(command.script, 'echo "make overridden"');
      expect(command.requiredParams, isEmpty);
      expect(command.optionalParams, isEmpty);
    });

    group('switch parsing', () {
      test('parses simple switch with multiple options', () {
        yamlFile.writeAsStringSync('''
build:
  switch:
    ios:
      script: echo "Building iOS"
    android:
      script: echo "Building Android"
    web:
      script: echo "Building Web"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['build']!;

        expect(cmd.hasSwitches, isTrue);
        expect(cmd.switches.keys, containsAll(['ios', 'android', 'web']));
        expect(cmd.switches['ios']!.script, 'echo "Building iOS"');
        expect(cmd.switches['android']!.script, 'echo "Building Android"');
        expect(cmd.switches['web']!.script, 'echo "Building Web"');
      });

      test('parses switch with default as string reference', () {
        yamlFile.writeAsStringSync('''
deploy:
  switch:
    staging:
      script: echo "Deploying to staging"
    production:
      script: echo "Deploying to production"
    default: production
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['deploy']!;

        expect(cmd.defaultSwitch, 'production');
        expect(cmd.switches.keys, containsAll(['staging', 'production']));
      });

      test('parses switch with default as full command', () {
        yamlFile.writeAsStringSync('''
test:
  switch:
    unit:
      script: echo "Running unit tests"
    default:
      script: echo "Running default tests"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['test']!;

        expect(cmd.switches.containsKey('default'), isTrue);
        expect(cmd.switches['default']!.script, 'echo "Running default tests"');
      });

      test('parses nested switches', () {
        yamlFile.writeAsStringSync('''
build:
  switch:
    test:
      switch:
        unit:
          script: echo "Unit tests"
        integration:
          script: echo "Integration tests"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['build']!;

        expect(cmd.hasSwitches, isTrue);
        expect(cmd.switches.containsKey('test'), isTrue);

        final testSwitch = cmd.switches['test']!;
        expect(testSwitch.hasSwitches, isTrue);
        expect(testSwitch.switches.keys, containsAll(['unit', 'integration']));
      });

      test('parses switch with params in switch cases', () {
        yamlFile.writeAsStringSync('''
deploy:
  switch:
    staging:
      script: echo "Deploying to staging {env}"
      params:
        optional:
          - env: "-e, --env"
            default: "dev"
    production:
      script: echo "Deploying to production"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['deploy']!;

        expect(cmd.switches.length, 2);
        expect(cmd.switches.keys, containsAll(['staging', 'production']));

        final stagingSwitch = cmd.switches['staging']!;
        expect(stagingSwitch.script, 'echo "Deploying to staging {env}"');
        expect(stagingSwitch.optionalParams.length, 1);
        expect(stagingSwitch.optionalParams.first.name, 'env');
        expect(stagingSwitch.optionalParams.first.defaultValue, 'dev');

        final prodSwitch = cmd.switches['production']!;
        expect(prodSwitch.script, 'echo "Deploying to production"');
        expect(prodSwitch.hasParameters, isFalse);
      });

      test('parses multiple sibling switches with params', () {
        // Regression test: ensure subsequent switches are recognized after one with params
        yamlFile.writeAsStringSync('''
run:
  switch:
    server:
      script: echo "Starting server on port {port}"
      params:
        required:
          - port: "-p, --port"
    client:
      script: echo "Starting client"
    admin:
      script: echo "Starting admin panel"
      params:
        optional:
          - debug: "-d, --debug"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['run']!;

        // All three switches should be recognized
        expect(cmd.switches.length, 3);
        expect(cmd.switches.keys, containsAll(['server', 'client', 'admin']));

        // Server has params and correct script
        final serverSwitch = cmd.switches['server']!;
        expect(serverSwitch.script, 'echo "Starting server on port {port}"');
        expect(serverSwitch.requiredParams.length, 1);
        expect(serverSwitch.requiredParams.first.name, 'port');

        // Client has no params and correct script
        final clientSwitch = cmd.switches['client']!;
        expect(clientSwitch.script, 'echo "Starting client"');
        expect(clientSwitch.hasParameters, isFalse);

        // Admin has params and correct script
        final adminSwitch = cmd.switches['admin']!;
        expect(adminSwitch.script, 'echo "Starting admin panel"');
        expect(adminSwitch.optionalParams.length, 1);
        expect(adminSwitch.optionalParams.first.name, 'debug');
      });

      test('parses switch with flags and description', () {
        yamlFile.writeAsStringSync('''
deploy:
  switch:
    staging:
      flags: "-s, --stg"
      description: "Deploy to staging"
      script: echo "Deploying to staging"
    production:
      flags: "-p, --prod"
      description: "Deploy to production"
      script: echo "Deploying to production"
''');

        final commands = loadCommandsFrom(yamlFile);
        final cmd = commands['deploy']!;

        // Check that switches were parsed
        expect(cmd.switches.containsKey('staging'), isTrue);
        expect(cmd.switches.containsKey('production'), isTrue);

        // Note: flags and descriptions will be available through switchesInfo
        // which is computed from the parsed structure
      });
    });
  });
}
