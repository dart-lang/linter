// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_expression_function_bodies

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/src/lint/state.dart';
import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/rules.dart';
import 'package:markdown/markdown.dart';
import 'package:yaml/yaml.dart';

import 'machine.dart';
import 'since.dart' show getSinceMap, SinceInfo;

/// Generates lint rule docs for publishing to https://dart-lang.github.io/
void main(List<String> args) async {
  var parser = ArgParser()
    ..addOption('out', abbr: 'o', help: 'Specifies output directory.')
    ..addOption('token', abbr: 't', help: 'Specifies a GitHub auth token.')
    ..addFlag('create-dirs',
        abbr: 'd', help: 'Enables creation of necessary directories.')
    ..addFlag(
      'html',
      help: 'Enables generation of the html docs.',
      defaultsTo: true,
    )
    ..addFlag(
      'json',
      help: 'Enables generation of the json machine file.',
      defaultsTo: true,
    )
    ..addFlag(
      'markdown',
      help: 'Enables generation of the markdown docs.',
      defaultsTo: true,
    );

  ArgResults options;
  try {
    options = parser.parse(args);
  } on FormatException catch (err) {
    printUsage(parser, err.message);
    return;
  }

  var outDir = options['out'] as String?;

  var token = options['token'];
  var auth = token is String ? Authentication.withToken(token) : null;

  var createDirectories = options['create-dirs'] == true;
  var emitHtml = options['html'] == true;
  var emitJson = options['json'] == true;
  var emitMarkdown = options['markdown'] == true;

  await generateDocs(
    outDir,
    auth: auth,
    createDirectories: createDirectories,
    emitHtml: emitHtml,
    emitJson: emitJson,
    emitMarkdown: emitMarkdown,
  );
}

const ruleFootMatterHtml = '''
In addition, rules can be further distinguished by *maturity*.  Unqualified
rules are considered stable, while others may be marked **experimental**
to indicate that they are under review.  Lints that are marked as **deprecated**
should not be used and are subject to removal in future Linter releases.

Rules can be selectively enabled in the analyzer using
[analysis options](https://pub.dev/packages/analyzer)
or through an
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file).

* **An auto-generated list enabling all options is provided [here](options/options.html).**

As some lints may contradict each other, only a subset of these will be
enabled in practice, but this list should provide a convenient jumping-off point.

Many lints are included in various predefined rulesets:

* [core](https://github.com/dart-lang/lints) for official "core" Dart team lint rules.
* [recommended](https://github.com/dart-lang/lints) for additional lint rules "recommended" by the Dart team.
* [flutter](https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml) for rules recommended for Flutter projects (`flutter create` enables these by default).

Rules included in these rulesets are badged in the documentation below.

These rules are under active development.  Feedback is
[welcome](https://github.com/dart-lang/linter/issues)!''';

const ruleLeadMatter = 'Rules are organized into familiar rule groups.';

final coreRules = <String?>[];
final flutterRules = <String?>[];
final recommendedRules = <String?>[];

/// Sorted list of contributed lint rules.
final List<LintRule> rules =
    List<LintRule>.of(Registry.ruleRegistry, growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

late Map<String, SinceInfo> sinceInfo;

final Map<String, String> _fixStatusMap = <String, String>{};

String describeState(LintRule r) =>
    r.state.isStable ? '' : ' (${r.state.label})';

Future<void> fetchBadgeInfo() async {
  var core = await fetchConfig(package: 'lints', file: 'core.yaml');
  if (core != null) {
    for (var ruleConfig in core.ruleConfigs) {
      coreRules.add(ruleConfig.name);
    }
  }

  var recommended =
      await fetchConfig(package: 'lints', file: 'recommended.yaml');
  if (recommended != null) {
    recommendedRules.addAll(coreRules);
    for (var ruleConfig in recommended.ruleConfigs) {
      recommendedRules.add(ruleConfig.name);
    }
  }

  var flutter =
      await fetchConfig(package: 'flutter_lints', file: 'flutter.yaml');
  if (flutter != null) {
    flutterRules.addAll(recommendedRules);
    for (var ruleConfig in flutter.ruleConfigs) {
      flutterRules.add(ruleConfig.name);
    }
  }
}

Future<LintConfig?> fetchConfig({
  required String package,
  required String file,
}) async {
  var uri =
      await Isolate.resolvePackageUri(Uri.parse('package:$package/$file'));
  var contents = File.fromUri(uri!).readAsStringSync();
  return processAnalysisOptionsFile(contents);
}

Future<Map<String, String>> fetchFixStatusMap() async {
  if (_fixStatusMap.isNotEmpty) return _fixStatusMap;
  var url =
      'https://raw.githubusercontent.com/dart-lang/sdk/main/pkg/analysis_server/lib/src/services/correction/error_fix_status.yaml';
  var client = http.Client();
  print('loading $url...');
  var req = await client.get(Uri.parse(url));
  var yaml = loadYamlNode(req.body) as YamlMap;
  for (var entry in yaml.entries) {
    var code = entry.key as String;
    if (code.startsWith('LintCode.')) {
      _fixStatusMap[code.substring(9)] =
          (entry.value as YamlMap)['status'] as String;
    }
  }
  return _fixStatusMap;
}

Future<void> fetchSinceInfo(Authentication? auth) async {
  sinceInfo = await getSinceMap(auth);
}

Future<void> generateDocs(
  String? dir, {
  required bool emitHtml,
  required bool emitJson,
  required bool emitMarkdown,
  Authentication? auth,
  bool createDirectories = false,
}) async {
  var outDir = dir;

  if (outDir != null) {
    var d = Directory(outDir);
    if (createDirectories) {
      d.createSync();
    }

    if (!d.existsSync()) {
      print("Directory '${d.path}' does not exist.");
      return;
    }

    if (!File('$outDir/options').existsSync()) {
      var lintsChildDir = Directory('$outDir/lints');
      if (lintsChildDir.existsSync()) {
        outDir = lintsChildDir.path;
      }
    }

    if (createDirectories) {
      Directory('$outDir/options').createSync();
      Directory('$outDir/machine').createSync();
    }
  }

  var markdownDir = 'doc';
  Directory('$markdownDir/rules').createSync();

  registerLintRules();

  // Generate lint count badge.
  if (emitHtml) {
    await CountBadger(Registry.ruleRegistry).generate(outDir);
  }

  // Fetch info for lint group/style badge generation.
  await fetchBadgeInfo();

  // Fetch since info.
  if (emitHtml || emitJson) {
    await fetchSinceInfo(auth);
  }

  late Map<String, String> fixStatusMap;

  if (emitHtml) {
    fixStatusMap = await fetchFixStatusMap();
  }

  // Generate rule files.
  for (var rule in rules) {
    if (emitHtml) {
      var fixStatus = getFixStatus(rule, fixStatusMap);

      RuleHtmlGenerator(rule, fixStatus).generate(outDir);
    }
    if (emitMarkdown) {
      RuleMarkdownGenerator(rule).generate(filePath: '$markdownDir/rules');
    }
  }

  // Generate index.
  if (emitHtml) {
    HtmlIndexer(rules, fixStatusMap).generate(outDir);
  }

  if (emitMarkdown) {
    MarkdownIndexer(rules).generate(filePath: markdownDir);
  }

  // Generate options samples.
  if (emitHtml) {
    OptionsSample(rules).generate(outDir);
  }

  // Generate a machine-readable summary of rules.
  if (emitJson) {
    MachineSummaryGenerator(Registry.ruleRegistry, fixStatusMap)
        .generate(outDir);
  }
}

String getBadges(String rule, [String? fixStatus]) {
  var sb = StringBuffer();
  if (coreRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="https://github.com/dart-lang/lints/blob/main/lib/core.yaml">'
        '<!--suppress HtmlUnknownTarget --><img alt="core" src="style-core.svg"></a>');
  }
  if (recommendedRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="https://github.com/dart-lang/lints/blob/main/lib/recommended.yaml">'
        '<!--suppress HtmlUnknownTarget --><img alt="recommended" src="style-recommended.svg"></a>');
  }
  if (flutterRules.contains(rule)) {
    sb.write(
        '<a class="style-type" href="https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml">'
        '<!--suppress HtmlUnknownTarget --><img alt="flutter" src="style-flutter.svg"></a>');
  }
  if (fixStatus == 'hasFix') {
    sb.write(
        '<a class="style-type" href="https://medium.com/dartlang/quick-fixes-for-analysis-issues-c10df084971a">'
        '<!--suppress HtmlUnknownTarget --><img alt="has-fix" src="has-fix.svg"></a>');
  }
  return sb.toString();
}

String getFixStatus(LintRule rule, Map<String, String> fixStatusMap) {
  var fallback = 'unregistered';
  for (var code in rule.lintCodes) {
    var status = fixStatusMap[code.uniqueName.substring(9)];
    if (status == null) continue;
    if (status == 'hasFix') return status;
    fallback = status;
  }
  return fallback;
}

void printUsage(ArgParser parser, [String? error]) {
  var message = 'Generates lint docs.';
  if (error != null) {
    message = error;
  }

  stdout.write('''$message
Usage: doc
${parser.usage}
''');
}

String qualify(LintRule r) {
  var name = r.name;
  var label = r.state.isRemoved ? '<s>$name</s>' : name;
  return label + describeState(r);
}

class CountBadger {
  Iterable<LintRule> rules;

  CountBadger(this.rules);

  Future<void> generate(String? dirPath) async {
    var lintCount = rules.length;

    var client = http.Client();
    var req = await client.get(
        Uri.parse('https://img.shields.io/badge/lints-$lintCount-blue.svg'));
    var bytes = req.bodyBytes;
    await File('$dirPath/count-badge.svg').writeAsBytes(bytes);
  }
}

class HtmlIndexer {
  final Iterable<LintRule> rules;
  final Map<String, String> fixStatusMap;
  HtmlIndexer(this.rules, this.fixStatusMap);

  String get enumerateErrorRules => rules
      .where((r) => r.group == Group.errors)
      .map(toDescription)
      .join('\n\n');

  String get enumerateGroups => Group.builtin
      .map((Group g) =>
          '<li><strong>${g.name} -</strong> ${markdownToHtml(g.description)}</li>')
      .join('\n');

  String get enumeratePubRules =>
      rules.where((r) => r.group == Group.pub).map(toDescription).join('\n\n');

  String get enumerateStyleRules => rules
      .where((r) => r.group == Group.style)
      .map(toDescription)
      .join('\n\n');

  void generate(String? filePath) {
    var generated = _generate();
    if (filePath != null) {
      var outPath = '$filePath/index.html';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String toDescription(LintRule r) =>
      '<!--suppress HtmlUnknownTarget --><strong><a href = "${r.name}.html">${qualify(r)}</a></strong><br/> ${getBadges(r.name, fixStatusMap[r.name])} ${markdownToHtml(r.description)}';

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <link rel="stylesheet" href="../styles.css">
      <title>Linter for Dart</title>
   </head>
   <body>
      <div class="wrapper">
         <header>
            <a href="../index.html">
               <h1>Linter for Dart</h1>
            </a>
            <p>Lint Rules</p>
            <ul>
              <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>

            <h1>Supported Lint Rules</h1>
            <p>
               This list is auto-generated from our sources.
            </p>
            ${markdownToHtml(ruleLeadMatter)}
            <ul>
               $enumerateGroups
            </ul>
            ${markdownToHtml(ruleFootMatterHtml)}

            <h2>Error Rules</h2>

               $enumerateErrorRules

            <h2>Style Rules</h2>

               $enumerateStyleRules

            <h2>Pub Rules</h2>

               $enumeratePubRules

         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="https://dart.dev/">Dart Team</a></p>
         <p>Visit us on <a href="https://github.com/dart-lang/linter">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class MachineSummaryGenerator {
  final Iterable<LintRule> rules;
  final Map<String, String> fixStatusMap;

  MachineSummaryGenerator(this.rules, this.fixStatusMap);

  void generate(String? filePath) {
    var generated = getMachineListing(rules,
        fixStatusMap: fixStatusMap, sinceInfo: sinceInfo);
    if (filePath != null) {
      var outPath = '$filePath/machine/rules.json';
      print('Writing to $outPath');
      var file = File(outPath);
      if (!file.parent.existsSync()) {
        file.parent.createSync();
      }
      file.writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }
}

class MarkdownIndexer {
  final Iterable<LintRule> rules;

  MarkdownIndexer(this.rules);

  void generate({required String filePath}) {
    var buffer = StringBuffer();

    buffer.writeln('''
# Linter for Dart

## Lint Rules

Welcome! For general information on using lint rules, see 
[Using the Linter](https://dart.dev/guides/language/analysis-options#enabling-linter-rules).
For information about configuring which lints are used, see the
[analysis options file](https://dart.dev/guides/language/analysis-options#the-analysis-options-file).
documentation.

Lints can also be used via predefined rulesets; common ones include:

* [core](https://github.com/dart-lang/lints) for official "core" Dart team lint
  rules.
* [recommended](https://github.com/dart-lang/lints) for additional lint rules
  "recommended" by the Dart team.
* [flutter](https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml)
  for rules recommended for Flutter projects (`flutter create` enables these by
  default).
''');

    void emitHeader() {
      buffer.writeln('| Rule | Description |');
      buffer.writeln('| --- | --- |');
    }

    void emitRule(LintRule rule) {
      buffer.write(
          '| **[${rule.name}](rules/${rule.name}.md)** | ${rule.description} ');
      if (!rule.state.isStable) buffer.write('`${rule.state.label}` ');
      buffer.writeln('|');
    }

    buffer.writeln('## package:lints Core Rules\n');
    buffer.writeln('''
The following rules are included in the "core" Dart team lint rules (see
[core](https://github.com/dart-lang/lints/blob/main/lib/core.yaml)). To use
these rules, add a pubspec dependency on `package:lints` and create an
analysis_options.yaml file with the line:

```
include: package:lints/core.yaml
```
''');
    emitHeader();
    _coreRules.forEach(emitRule);
    buffer.writeln();

    buffer.writeln('## package:lints Recommended Rules\n');
    buffer.writeln('''
The following rules additional lint rules are recommended by the Dart team (see
[recommended](https://github.com/dart-lang/lints/blob/main/lib/recommended.yaml)).
To use these rules, add a pubspec dependency on `package:lints` and create an
analysis_options.yaml file with the line:

```
include: package:lints/recommended.yaml
```
''');
    emitHeader();
    _recommendedRules.forEach(emitRule);
    buffer.writeln();

    buffer.writeln('## package:flutter_lints Rules\n');
    buffer.writeln('''
The following rules are recommended for Flutter projects (`flutter create`
enables these by default); see
[flutter_lints](https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml).
To use these rules, add a pubspec dependency on `package:flutter_lints` and
create an analysis_options.yaml file with the line:

```
include: package:flutter_lints/flutter.yaml
```
''');
    emitHeader();
    _flutterRules.forEach(emitRule);
    buffer.writeln();

    buffer.writeln('## Additional Rules\n');
    buffer.writeln('''
The following are additional rules that can optionally be enabled. To use these
rules, create an analysis_options.yaml file with the following info:

```
linter:
  rules:
    - <rule name 1>
    - <rule name 2>
```
''');
    emitHeader();
    _otherRules().forEach(emitRule);
    buffer.writeln();

    buffer.writeln('## Removed Rules\n');
    buffer.writeln('''
The following rules are no longer included in the linter.
''');
    emitHeader();
    _otherRules(removedRules: true).forEach(emitRule);
    buffer.writeln();

    var file = File('$filePath/index.md');
    file.writeAsStringSync('${buffer.toString().trim()}\n');
    print('wrote ${file.path}.');
  }
}

Iterable<LintRule> get _coreRules => rules.where((rule) {
      return coreRules.contains(rule.name);
    });

Iterable<LintRule> get _recommendedRules => rules.where((rule) {
      return recommendedRules.contains(rule.name) &&
          !coreRules.contains(rule.name);
    });

Iterable<LintRule> get _flutterRules => rules.where((rule) {
      return flutterRules.contains(rule.name) &&
          !recommendedRules.contains(rule.name) &&
          !coreRules.contains(rule.name);
    });

Iterable<LintRule> _otherRules({bool removedRules = false}) {
  var result = rules.where((rule) {
    return !flutterRules.contains(rule.name) &&
        !recommendedRules.contains(rule.name) &&
        !coreRules.contains(rule.name);
  });

  return removedRules
      ? result.where((r) => r.state.isRemoved)
      : result.where((r) => !r.state.isRemoved);
}

class OptionsSample {
  Iterable<LintRule> rules;

  OptionsSample(this.rules);

  void generate(String? filePath) {
    var generated = _generate();
    if (filePath != null) {
      var outPath = '$filePath/options/options.html';
      print('Writing to $outPath');
      var file = File(outPath);
      if (!file.parent.existsSync()) {
        file.parent.createSync();
      }
      file.writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String generateOptions() {
    var sb = StringBuffer('''
```
linter:
  rules:
''');

    var sortedRules = rules
        .where((r) => !r.state.isDeprecated)
        .map((r) => r.name)
        .toList()
      ..sort();
    for (var rule in sortedRules) {
      sb.write('    - $rule\n');
    }
    sb.write('```');

    return sb.toString();
  }

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <link rel="stylesheet" href="../../styles.css">
      <title>Analysis Options</title>
   </head>
  <body>
      <div class="wrapper">
         <header>
            <a href="../../index.html">
               <h1>Linter for Dart</h1>
            </a>
            <p>Analysis Options</p>
            <ul>
              <li><a href="../index.html">View all <strong>Lint Rules</strong></a></li>
              <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="../index.html">View all <strong>Lint Rules</strong></a></p>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>

            <h1 id="analysis-options">Analysis Options</h1>
            <p>
               Auto-generated options enabling all lints.
               Add these to your
               <a href="https://dart.dev/guides/language/analysis-options#the-analysis-options-file">analysis_options.yaml file</a>
               and tailor to fit!
            </p>

            ${markdownToHtml(generateOptions())}

         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="https://dart.dev/">Dart Team</a></p>
         <p>Visit us on <a href="https://github.com/dart-lang/linter">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class RuleHtmlGenerator {
  final LintRule rule;
  final String fixStatus;

  RuleHtmlGenerator(this.rule, this.fixStatus);

  String get details => rule.details;

  String get detailsHeader {
    if (state.isRemoved) {
      var version = state.since;
      var sinceDetail =
          version != null ? ' since Dart language version $version.' : '';
      return '<p style="font-size:30px"><strong>Unsupported$sinceDetail</strong></p>';
    }
    return '';
  }

  String get group => rule.group.name;

  String get humanReadableName => rule.name;

  String get incompatibleRuleDetails {
    var sb = StringBuffer();
    var incompatibleRules = rule.incompatibleRules;
    if (incompatibleRules.isNotEmpty) {
      sb.writeln('<p>');
      sb.write('Incompatible with: ');
      var rule = incompatibleRules.first;
      sb.write(
          '<!--suppress HtmlUnknownTarget --><a href = "$rule.html" >$rule</a>');
      for (var i = 1; i < incompatibleRules.length; ++i) {
        rule = incompatibleRules[i];
        sb.write(', <a href = "$rule.html" >$rule</a>');
      }
      sb.writeln('.');
      sb.writeln('</p>');
    }
    return sb.toString();
  }

  String get name => rule.name;

  String get since {
    var info = sinceInfo[name]!;
    var sdkVersion = info.sinceDartSdk != null
        ? '>= ${info.sinceDartSdk}'
        : '<strong>Unreleased</strong>';
    var linterVersion = info.sinceLinter != null
        ? 'v${info.sinceLinter}'
        : '<strong>Unreleased</strong>';
    return 'Dart SDK: $sdkVersion • <small>(Linter $linterVersion)</small>';
  }

  State get state => rule.state;

  String get stateString {
    if (state.isDeprecated) {
      return '<span style="color:orangered;font-weight:bold;" >${state.label}</span>';
    } else if (state.isRemoved) {
      return '<span style="color:darkgray;font-weight:bold;" >${state.label}</span>';
    } else if (state.isExperimental) {
      return '<span style="color:hotpink;font-weight:bold;" >${state.label}</span>';
    } else {
      return state.label;
    }
  }

  void generate([String? filePath]) {
    var generated = _generate();
    if (filePath != null) {
      var outPath = '$filePath/$name.html';
      print('Writing to $outPath');
      File(outPath).writeAsStringSync(generated);
    } else {
      print(generated);
    }
  }

  String _generate() => '''
<!DOCTYPE html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <link rel="shortcut icon" href="../dart-192.png">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
      <meta name="mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <title>$name</title>
      <link rel="stylesheet" href="../styles.css">
   </head>
   <body>
      <div class="wrapper">
         <header>
            <h1>$humanReadableName</h1>
            <p>Group: $group</p>
            <p>Maturity: $stateString</p>
            <div class="tooltip">
               <p>$since</p>
               <span class="tooltip-content">Since info is static, may be stale</span>
            </div>
            ${getBadges(name, fixStatus)}
            <ul>
               <li><a href="index.html">View all <strong>Lint Rules</strong></a></li>
               <li><a href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></li>
            </ul>
            <p><a class="overflow-link" href="index.html">View all <strong>Lint Rules</strong></a></p>
            <p><a class="overflow-link" href="https://dart.dev/guides/language/analysis-options#enabling-linter-rules">Using the <strong>Linter</strong></a></p>
         </header>
         <section>
            $detailsHeader
            ${markdownToHtml(details)}
            $incompatibleRuleDetails
         </section>
      </div>
      <footer>
         <p>Maintained by the <a href="https://dart.dev/">Dart Team</a></p>
         <p>Visit us on <a href="https://github.com/dart-lang/linter">GitHub</a></p>
      </footer>
   </body>
</html>
''';
}

class RuleMarkdownGenerator {
  final LintRule rule;

  RuleMarkdownGenerator(this.rule);

  String get details => rule.details;

  String get group => rule.group.name;

  String get name => rule.name;

  String? get since {
    return rule.state.since?.toString();
  }

  void generate({required String filePath}) {
    var buffer = StringBuffer();

    buffer.writeln('# Rule $name');
    buffer.writeln();
    // TODO: Use markdown badges here?
    if (flutterRules.contains(rule.name)) {
      buffer.write('`flutter` ');
    } else if (recommendedRules.contains(rule.name)) {
      buffer.write('`recommended` ');
    } else if (coreRules.contains(rule.name)) {
      buffer.write('`core` ');
    }
    buffer.write('`$group` ');
    buffer.write('`${rule.state.label}` ');
    if (since != null) buffer.write('`since $since`');
    buffer.writeln();
    buffer.writeln();

    buffer.writeln('## Description');
    buffer.writeln();
    buffer.writeln(details.trim());

    // incompatible rules
    var incompatibleRules = rule.incompatibleRules;
    if (incompatibleRules.isNotEmpty) {
      buffer.writeln('## Incompatible With');
      buffer.writeln();
      for (var rule in incompatibleRules) {
        buffer.writeln('- [$rule]($rule.md)');
      }
      buffer.writeln();
    }

    File('$filePath/$name.md').writeAsStringSync(buffer.toString());
  }
}
