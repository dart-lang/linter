// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/analyzer.dart';
import 'package:analyzer/src/lint/pub.dart'; // ignore: implementation_imports

const _desc = r'Sort dependencies.';

const _details = r'''
**DO** sort dependencies in `pubspec.yaml`.

Sorting list of dependencies makes maintenance easier.
''';

class SortDependencies extends LintRule {
  SortDependencies()
      : super(
            name: 'sort_dependencies',
            description: _desc,
            details: _details,
            group: Group.pub);

  @override
  PubspecVisitor getPubspecVisitor() => new Visitor(this);
}

class Visitor extends PubspecVisitor<void> {
  final LintRule rule;

  Visitor(this.rule);

  @override
  void visitPackageDependencies(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  @override
  void visitPackageDevDependencies(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  void _visitDeps(PSDependencyList dependencies) {
    final depsByLocation = dependencies.toList()
      ..sort((d1, d2) => d1.name.span.start.compareTo(d2.name.span.start));
    var previousName = '';
    for (final dep in depsByLocation) {
      final name = dep.name.text;
      if (name.compareTo(previousName) < 0) {
        rule.reportPubLint(dep.name);
      }
      previousName = name;
    }
  }
}
