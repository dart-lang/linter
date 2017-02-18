// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.package_imports_before_relative;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r"Place '*package:*' imports before relative imports.";
const _details = r'''**DO** place “*package:*” imports before relative imports.

**BAD:**
```
import 'a.dart';
import 'b.dart';

import 'package:bar/bar.dart';  // LINT
import 'package:foo/foo.dart';  // LINT
```
**BAD:**
```
import 'package:bar/bar.dart';  // OK
import 'a.dart';

import 'package:foo/foo.dart';  // LINT
import 'b.dart';
```

**GOOD:**
```
import 'package:bar/bar.dart';  // OK
import 'package:foo/foo.dart';  // OK

import 'a.dart';
import 'b.dart';
```

''';

bool _isImportDirective(Directive node) => node is ImportDirective;

bool _isNotDartImport(Directive node) =>
    !(node as ImportDirective).uriContent.startsWith("dart:");

bool _isPackageImport(Directive node) =>
    (node as ImportDirective).uriContent.startsWith("package:");

class PackageImportsBeforeRelative extends LintRule {
  _Visitor _visitor;

  PackageImportsBeforeRelative()
      : super(
            name: 'package_imports_before_relative',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    node.directives
        .where(_isImportDirective)
        .where(_isNotDartImport)
        .skipWhile(_isPackageImport)
        .where(_isPackageImport)
        .forEach(rule.reportLint);
  }
}
