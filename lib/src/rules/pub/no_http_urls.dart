// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/lint/pub.dart'; // ignore: implementation_imports

import '../../analyzer.dart';

const _desc = r"Don't use http urls.";

const _details = r'''
**DON'T** use http urls in `pubspec.yaml`.

Use https instead.
''';

class PubspecNoHttpUrls extends LintRule {
  PubspecNoHttpUrls()
      : super(
            name: 'pubspec_no_http_urls',
            description: _desc,
            details: _details,
            group: Group.pub);

  @override
  PubspecVisitor getPubspecVisitor() => Visitor(this);
}

class Visitor extends PubspecVisitor<void> {
  final LintRule rule;

  Visitor(this.rule);

  _checkUrl(PSNode? node) {
    if (node == null) return;
    try {
      var text = node.text;
      if (text != null && Uri.parse(text).scheme == 'http') {
        rule.reportPubLint(node);
      }
    } on FormatException {
      // Do nothing.
    }
  }

  @override
  void visitPackageDocumentation(PSEntry documentation) {
    _checkUrl(documentation.value);
  }

  @override
  void visitPackageHomepage(PSEntry homepage) {
    _checkUrl(homepage.value);
  }

  @override
  void visitPackageDependencies(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  @override
  void visitPackageDevDependencies(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  @override
  void visitPackageDependencyOverrides(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  void _visitDeps(PSDependencyList dependencies) {
    for (var dep in dependencies) {
      _checkUrl(dep.git?.url?.value);
      _checkUrl(dep.host?.url?.value);
    }
  }
}
