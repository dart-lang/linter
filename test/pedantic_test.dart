// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/lint/config.dart';
import 'package:github/server.dart';
import 'package:http/http.dart' as http;
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/pedantic.dart';
import 'package:linter/src/rules.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

main() {
  group('pedantic rules', () {
    test('validate pedantic version matches latest', () async {
      var latestPedantic = await getLatestPedantic();
      expect(Version.parse(Pedantic.version), latestPedantic);
    });

    test('validate cached rules match latest', () async {
      var rules = await fetchLatestPedanticRules();
      expect(Pedantic.rules, unorderedEquals(rules));
    });

    test('validate defaults match pedantic', () async {
      registerLintRules();
      expect(Pedantic.rules,
          unorderedEquals(Analyzer.facade.defaultRules.map((r) => r.name)));
    });
  });
}

Future<List<String>> fetchLatestPedanticRules() async {
  var version = await getLatestPedantic();
  return fetchRules(
      'https://raw.githubusercontent.com/dart-lang/pedantic/v${version.toString()}/lib/analysis_options.yaml');
}

Future<Version> getLatestPedantic() async {
  var tags = await fetchPedanticTags();
  return (tags..sort((v1, v2) => v1.compareTo(v2))).last;
}

Future<List<Version>> fetchPedanticTags() => createGitHubClient()
    .repositories
    .listTags(new RepositorySlug('dart-lang', 'pedantic'))
    // v1.4.0 => 1.4.0
    .map((t) => Version.parse(t.name.substring(1)))
    .toList();

Future<List<String>> fetchRules(String optionsUrl) async {
  var client = new http.Client();
  var req = await client.get(optionsUrl);
  var config = processAnalysisOptionsFile(req.body);
  return config.ruleConfigs.map((c) => c.name).toList();
}
