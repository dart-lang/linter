// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.declare_const_constructor_when_possible;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc =
    r'Consider making your constructor const if the class supports it.';

const _details = r'''

**CONSIDER** making your constructor const if the class supports it.

**BAD:**
```
class Bad {
  final int foo;

  Bad() : foo = 1;
}
```

**GOOD:**
```
class Good {
  final int foo;

  const Good() : foo = 1;
}
```

''';

ConstructorDeclaration _asConstructorDeclaration(ClassMember node) {
  if (node is ConstructorDeclaration) {
    return node;
  }
  return null;
}

bool _doesNotHaveNonConstInitializer(ConstructorDeclaration element) {
  return element.initializers.every(_isConstInitializer);
}

bool _hasEmptyBody(ConstructorDeclaration node) {
  final body = node.body;
  return body is EmptyFunctionBody ||
      (body is BlockFunctionBody && body.block.statements.length == 0);
}

bool _hasNonFinalFields(ClassElement classElement) =>
    classElement.fields.any((e) => !e.isFinal);

bool _isConstInitializer(ConstructorInitializer element) {
  if (element is RedirectingConstructorInvocation) {
    return element.staticElement?.isConst ?? false;
  } else if (element is SuperConstructorInvocation) {
    return element.staticElement?.isConst ?? false;
  }
  return true;
}

bool _isNotConst(ConstructorDeclaration element) => !element.element.isConst;

bool _isNotNull(Object o) => o != null;

class DeclareConstConstructorWhenPossible extends LintRule {
  _Visitor _visitor;
  DeclareConstConstructorWhenPossible()
      : super(
            name: 'declare_const_constructor_when_possible',
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
  visitClassDeclaration(ClassDeclaration node) {
    if (_hasNonFinalFields(node.element)) {
      return;
    }
    node.members
        .map(_asConstructorDeclaration)
        .where(_isNotNull)
        .where(_isNotConst)
        .where(_hasEmptyBody)
        .where(_doesNotHaveNonConstInitializer)
        .forEach(rule.reportLint);
  }
}
