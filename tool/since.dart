// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:github/github.dart';
import 'package:linter/src/utils.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'crawl.dart';

final Version earliestLinterInDart2 = Version.parse('0.1.58');

Map<String, String>? _dartSdkMap;

Map<String, SinceInfo>? _sinceMap;

Future<Map<String, String>> getDartSdkMap([Authentication? auth]) async {
  var dartSdkMap = _dartSdkMap;
  if (dartSdkMap == null) {
    var dartSdkCache = File('tool/since/dart_sdk.yaml').readAsStringSync();
    var yamlMap = loadYamlNode(dartSdkCache) as YamlMap;
    dartSdkMap = yamlMap.map((k, v) => MapEntry(k.toString(), v.toString()));

    var sdks = await getSdkTags(auth, onlyStable: true);
    for (var sdk in sdks) {
      if (!dartSdkMap.containsKey(sdk)) {
        var linterVersion = await linterForDartSdk(sdk);
        if (linterVersion != null) {
          dartSdkMap[sdk] = linterVersion;
          printToConsole('fetched...');
          printToConsole('$sdk : $linterVersion');
          printToConsole('(consider caching in tool/since/dart_sdk.yaml)');
        }
      }
    }

    _dartSdkMap = dartSdkMap;
  }
  return dartSdkMap;
}

Future<Map<String, SinceInfo>> getSinceMap([Authentication? auth]) async =>
    _sinceMap ??= await _getSinceInfo(auth);

Future<Map<String, SinceInfo>> _getSinceInfo(Authentication? auth) async {
  var linterCache = File('tool/since/linter.yaml').readAsStringSync();
  var linterVersionCache = loadYamlNode(linterCache) as YamlMap;

  var sinceMap = <String, SinceInfo>{};
  for (var lint in registeredLints.map((l) => l.name)) {
    var linterVersion = linterVersionCache[lint] as String?;
    if (linterVersion == null) {
      linterVersion = await findSinceLinter(lint, auth);
      if (linterVersion != null) {
        printToConsole('fetched...');
        printToConsole('$lint : $linterVersion');
        printToConsole('(consider caching in tool/since/linter.yaml)');
      }
    }
    sinceMap[lint] = SinceInfo(
      sinceLinter: linterVersion,
      sinceDartSdk: await _sinceSdkForLinter(linterVersion, auth),
    );
  }
  return sinceMap;
}

Future<String?> _nextLinterVersion(
    Version linterVersion, Authentication? auth) async {
  var versions = await getLinterReleases(auth);
  for (var version in versions) {
    if (Version.parse(version) > linterVersion) {
      return version;
    }
  }
  return null;
}

Future<String?> _sinceSdkForLinter(
    String? linterVersionString, Authentication? auth) async {
  if (linterVersionString == null) {
    return null;
  }

  try {
    var linterVersion = Version.parse(linterVersionString);
    if (linterVersion.compareTo(earliestLinterInDart2) < 0) {
      return bottomDartSdk.toString();
    }

    var sdkVersions = <String>[];
    var sdkCache = await getDartSdkMap(auth);
    for (var sdkEntry in sdkCache.entries) {
      if (Version.parse(sdkEntry.value) == linterVersion) {
        sdkVersions.add(sdkEntry.key);
      }
    }
    if (sdkVersions.isEmpty) {
      var nextLinter = await _nextLinterVersion(linterVersion, auth);
      return _sinceSdkForLinter(nextLinter, auth);
    }

    sdkVersions.sort();
    return sdkVersions.first;
  } on FormatException {
    return null;
  }
}

class SinceInfo {
  final String? sinceLinter;
  final String? sinceDartSdk;

  SinceInfo({this.sinceLinter, this.sinceDartSdk});

  @override
  String toString() => 'linter: $sinceLinter | sdk: $sinceDartSdk';
}
