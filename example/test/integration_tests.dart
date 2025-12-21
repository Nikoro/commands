import 'dart:io';

import 'package:meta/meta.dart' show isTestGroup;
import 'package:test/test.dart';

final _commandsYaml = File('commands.yaml');

@isTestGroup
void integrationTests(String description, dynamic Function() body) => group(description, () {
      late String originalContent;

      setUpAll(() {
        originalContent = _commandsYaml.readAsStringSync();
        _commandsYaml.writeAsStringSync(description);
      });

      tearDownAll(() => _commandsYaml.writeAsStringSync(originalContent));

      body();
    });
