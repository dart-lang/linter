// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer/src/lint/state.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:linter/src/rules.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_data/rules/experiments/experiments.dart';
import 'integration/always_require_non_null_named_parameters.dart'
    as always_require_non_null_named_parameters;
import 'integration/avoid_relative_lib_imports.dart'
    as avoid_relative_lib_imports;
import 'integration/avoid_renaming_method_parameters.dart'
    as avoid_renaming_method_parameters;
import 'integration/avoid_web_libraries_in_flutter.dart'
    as avoid_web_libraries_in_flutter;
import 'integration/cancel_subscriptions.dart' as cancel_subscriptions;
import 'integration/close_sinks.dart' as close_sinks;
import 'integration/depend_on_referenced_packages.dart'
    as depend_on_referenced_packages;
import 'integration/directives_ordering.dart' as directives_ordering;
import 'integration/exhaustive_cases.dart' as exhaustive_cases;
import 'integration/flutter_style_todos.dart' as flutter_style_todos;
import 'integration/lines_longer_than_80_chars.dart'
    as lines_longer_than_80_chars;
import 'integration/only_throw_errors.dart' as only_throw_errors;
import 'integration/prefer_const_constructors_in_immutables.dart'
    as prefer_const_constructors_in_immutables;
import 'integration/prefer_mixin.dart' as prefer_mixin;
import 'integration/prefer_relative_imports.dart' as prefer_relative_imports;
import 'integration/public_member_api_docs.dart' as public_member_api_docs;
import 'integration/secure_pubspec_urls.dart' as secure_pubspec_urls;
import 'integration/sort_pub_dependencies.dart' as sort_pub_dependencies;
import 'integration/unnecessary_lambdas.dart' as unnecessary_lambdas;
import 'integration/unnecessary_library_directive.dart'
    as unnecessary_library_directive;
import 'integration/unnecessary_string_escapes.dart'
    as unnecessary_string_escapes;
import 'integration/use_build_context_synchronously.dart'
    as use_build_context_synchronously;
import 'mocks.dart';
import 'test_constants.dart';

void main() {
  group('integration', () {
    ruleTests();
    coreTests();
  });
}

void coreTests() {
  group('core', () {
    group('config', () {
      var currentOut = outSink;
      var collectingOut = CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });
      test('excludes', () async {
        await cli.run([
          '$integrationTestDir/p2',
          '-c',
          '$integrationTestDir/p2/lintconfig.yaml'
        ]);
        expect(
            collectingOut.trim(),
            stringContainsInOrder(
                ['4 files analyzed, 1 issue found (2 filtered), in']));
        expect(exitCode, 1);
      });
      test('overrides', () async {
        await cli.run([
          '$integrationTestDir/p2',
          '-c',
          '$integrationTestDir/p2/lintconfig2.yaml'
        ]);
        expect(collectingOut.trim(),
            stringContainsInOrder(['4 files analyzed, 0 issues found, in']));
        expect(exitCode, 0);
      });
      test('default', () async {
        await cli.run(['$integrationTestDir/p2']);
        expect(collectingOut.trim(),
            stringContainsInOrder(['4 files analyzed, 3 issues found, in']));
        expect(exitCode, 1);
      });
    });

    group('pubspec', () {
      var currentOut = outSink;
      var collectingOut = CollectingSink();
      setUp(() => outSink = collectingOut);
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
      });
      test('bad pubspec', () async {
        await cli.run([
          '$integrationTestDir/p3',
          '$integrationTestDir/p3/_pubpspec.yaml'
        ]);
        expect(collectingOut.trim(),
            startsWith('1 file analyzed, 0 issues found, in'));
      });
    });

    group('canonicalization', () {
      var currentOut = outSink;
      var collectingOut = CollectingSink();
      setUp(() => outSink = collectingOut);
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
      });
      test('no warnings due to bad canonicalization', () async {
        await cli.runLinter(['$integrationTestDir/p4'], LinterOptions([]));
        expect(collectingOut.trim(),
            startsWith('3 files analyzed, 0 issues found, in'));
      });
    });

    group('examples', () {
      test('all.yaml', () {
        var src = readFile('example/all.yaml');

        var options = _getOptionsFromString(src);
        var configuredLints =
            // ignore: cast_nullable_to_non_nullable
            (options['linter'] as YamlMap)['rules'] as YamlList;

        // rules are sorted
        expect(
            configuredLints, orderedEquals(configuredLints.toList()..sort()));

        registerLintRules();

        var registered = Analyzer.facade.registeredRules
            .where((r) =>
                !r.state.isDeprecated &&
                !r.state.isRemoved &&
                !experiments.contains(r))
            .map((r) => r.name);

        for (var l in configuredLints) {
          if (!registered.contains(l)) {
            print(l);
          }
        }

        expect(configuredLints, unorderedEquals(registered));
      });
    });
  });
}

void ruleTests() {
  group('rule', () {
    unnecessary_lambdas.main();
    exhaustive_cases.main();
    avoid_web_libraries_in_flutter.main();
    close_sinks.main();
    cancel_subscriptions.main();
    depend_on_referenced_packages.main();
    directives_ordering.main();
    flutter_style_todos.main();
    lines_longer_than_80_chars.main();
    only_throw_errors.main();
    always_require_non_null_named_parameters.main();
    prefer_const_constructors_in_immutables.main();
    avoid_relative_lib_imports.main();
    prefer_relative_imports.main();
    public_member_api_docs.main();
    secure_pubspec_urls.main();
    avoid_renaming_method_parameters.main();
    sort_pub_dependencies.main();
    unnecessary_string_escapes.main();
    prefer_mixin.main();
    use_build_context_synchronously.main();
    unnecessary_library_directive.main();
  });
}

/// Provide the options found in [optionsSource].
Map<String, YamlNode> _getOptionsFromString(String optionsSource) {
  var options = <String, YamlNode>{};
  var doc = loadYamlNode(optionsSource);

  // Empty options.
  if (doc is YamlScalar && doc.value == null) {
    return options;
  }
  if (doc is! YamlMap) {
    throw Exception(
        'Bad options file format (expected map, got ${doc.runtimeType})');
  }
  doc.nodes.forEach((k, YamlNode v) {
    Object? key;
    if (k is YamlScalar) {
      key = k.value;
    }
    if (key is! String) {
      throw Exception('Bad options file format (expected String scope key, '
          'got ${k.runtimeType})');
    }
    options[key] = v;
  });
  return options;
}
