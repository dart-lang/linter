// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/lint/pub.dart'; // ignore: implementation_imports

import '../../analyzer.dart';

const _desc = r'Sort pub dependencies.';

const _details = r'''
**DO** sort pub dependencies in `pubspec.yaml`.

Sorting list of pub dependencies makes maintenance easier.
''';

class SortPubDependencies extends LintRule {
  SortPubDependencies()
      : super(
            name: 'sort_pub_dependencies',
            description: _desc,
            details: _details,
            group: Group.pub);

  @override
  PubspecVisitor getPubspecVisitor() => Visitor(this);
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

  @override
  void visitPackageDependencyOverrides(PSDependencyList dependencies) {
    _visitDeps(dependencies);
  }

  void _visitDeps(PSDependencyList dependencies) {
    final depsByLocation = dependencies.toList()
      ..sort((d1, d2) {
        // names should really not be null but handling to be safe.
        // todo (pq): consider pulling out support for nulls
        var span1 = d1.name?.span.start;
        var span2 = d2.name?.span.start;
        if (span1 == null) {
          return -1;
        }
        if (span2 == null) {
          return 1;
        }
        return span1.compareTo(span2);
      });
    var previousName = '';
    for (final dep in depsByLocation) {
      final name = dep.name?.text;
      if (name != null) {
        if (name.compareTo(previousName) < 0) {
          rule.reportPubLint(dep.name!);
          return;
        }
        previousName = name;
      }
    }
  }
}
