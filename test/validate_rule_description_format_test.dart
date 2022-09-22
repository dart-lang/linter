// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:linter/src/rules.dart';
import 'package:test/test.dart';
import 'package:analyzer/src/lint/registry.dart';

void main() {
  group('rule doc format', () {
    group('description - trailing periods', () {
      for (var rule in Registry.ruleRegistry.rules) {
        test('`${rule.name}` description', () {
          expect(rule.description.endsWith('.'), isTrue,
              reason:
                  "Rule description for ${rule.name} should end with a '.'");
        });
      }
    });
    group('details - no leading whitespace', () {
      for (var rule in Registry.ruleRegistry.rules) {
        test('`${rule.name}` details', () {
          expect(rule.details.startsWith(RegExp(r'\s+')), isFalse,
              reason:
              'Rule details for ${rule.name} should not have leading whitespace.');
        });
      }
    });

  });
}
