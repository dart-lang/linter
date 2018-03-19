// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/ast.dart';

const _desc = r'Avoid private typedef functions.';

const _details = r'''

**AVOID** private typedef functions used only once. Prefer inline function
syntax.

**BAD:**
```
typedef void _F();
m(_F f);
```

**GOOD:**
```
m(void Function() f);
```

''';

class AvoidPrivateTypedefFunctions extends LintRule {
  AvoidPrivateTypedefFunctions()
      : super(
            name: 'avoid_private_typedef_functions',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  Visitor(this.rule);

  final LintRule rule;

  @override
  visitFunctionTypeAlias(FunctionTypeAlias node) {
    if (node.element.isPrivate) {
      _countAndReport(node.name.name, node);
    }
  }

  @override
  visitGenericTypeAlias(GenericTypeAlias node) {
    if (node.element.isPrivate) {
      _countAndReport(node.name.name, node);
    }
  }

  _countAndReport(String name, AstNode node) {
    final visitor = new _CountVisitor(name);
    getCompilationUnit(node).root.visitChildren(visitor);
    if (visitor.count <= 1) {
      rule.reportLint(node);
    }
  }
}

class _CountVisitor extends RecursiveAstVisitor {
  _CountVisitor(this.type);
  String type;
  int count = 0;

  @override
  visitTypeName(TypeName node) {
    if (node.name.name == type) count++;
  }
}
