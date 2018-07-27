// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

const _desc =
    r"Don't use the Null type, unless you are positive that you don't want void.";

const _details = r'''

**DO NOT** use the type Null where void would work.

**BAD:**
```
Null f() {}
Future<Null> f() {}
Stream<Null> f() {}
f(Null x) {}
```

**GOOD:**
```
void f() {}
Future<void> f() {}
Stream<void> f() {}
f(void x) {}
```
''';

class PreferVoidToNull extends LintRule implements NodeLintRule {
  PreferVoidToNull()
      : super(
            name: 'prefer_void_to_null',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addSimpleIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitSimpleIdentifier(SimpleIdentifier id) {
    final element = id.staticElement;
    if (element is ClassElement && element.type.isDartCoreNull) {
      rule.reportLintForToken(id.token);
    }
  }
}
