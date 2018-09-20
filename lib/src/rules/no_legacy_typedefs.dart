// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r"Don't use the legacy typedef syntax.";

const _details = r'''
**DON'T** use the legacy typedef syntax.

**BAD:**
```
typedef int Comparison<T>(T a, T b);

typedef bool TestNumber(num);
```

**GOOD:**
```
typedef Comparison<T> = int Function(T, T);

typedef Comparison<T> = int Function(T a, T b);
```
''';

class NoLegacyTypedefs extends LintRule implements NodeLintRule {
  NoLegacyTypedefs()
      : super(
            name: 'no_legacy_typedefs',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addFunctionTypeAlias(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionTypeAlias(TypeAlias node) {
    if (node.typedefKeyword.next.isIdentifier) {
      rule.reportLint(node);
    }
  }
}
