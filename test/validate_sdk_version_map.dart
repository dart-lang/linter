// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/rules.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('check to ensure all lints have versions in `sdk.yaml`', () {
    var sinceFile = File('tool/since/sdk.yaml').readAsStringSync();
    var versionMap = loadYamlNode(sinceFile) as YamlMap;
    registerLintRules();
    for (var rule in Analyzer.facade.registeredRules) {
      var name = rule.name;
      test(name, () async {
        expect(versionMap.keys, contains(name),
            reason: 'To fix, add an entry for $name to `tool/since/sdk.yaml`.');
      });
    }
  });
}
