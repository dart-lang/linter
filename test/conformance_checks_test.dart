// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:linter/src/analyzer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'conformance/test_rules/banned_property_write/disallow_set_foo_bar.dart';
import 'conformance/test_rules/banned_property_write/disallow_set_htmldocument_title.dart';
import 'conformance/test_rules/banned_property_write/disallow_set_htmlinputelement_webkitdirectory.dart';
import 'conformance/test_rules/banned_property_write/disallow_set_window_name.dart';
import 'rule_test.dart';
import 'test_constants.dart';

/// All the test rules registered for these tests.
List<LintRule> get conformanceTestRules => _bannedPropertyWriteTestRules;

List<LintRule> _bannedPropertyWriteTestRules = [
  DisallowSetFooBar(),
  DisallowSetHtmlDocumentTitle(),
  DisallowSetHTMLInputElementWebkitDirectory(),
  DisallowSetWindowName(),
];

void main() {
  void register(LintRule rule) => Analyzer.facade.register(rule);
  group('banned_property_write', () {
    // Register all the test rules for this check.
    _bannedPropertyWriteTestRules.forEach(register);
    for (var entry in Directory(p.join(
            p.join(conformanceTestsDir, 'test_data'), 'banned_property_write'))
        .listSync()) {
      if (entry is! File) continue;

      var ruleName = p.basenameWithoutExtension(entry.path);
      testRule(ruleName, entry, useMockSdk: false);
    }
  });
}
