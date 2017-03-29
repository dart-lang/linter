// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.use_getters_to_access_properties;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc =
    r'Use getters for operations that conceptually access properties.';

const _details = r'''

**DO** use getters for operations that conceptually access properties.

**BAD:**
```
rectangle.getWidth()
collection.isEmpty()
button.canShow()
```

**GOOD:**
```
rectangle.width
collection.isEmpty
button.canShow
```

''';

bool _beginsWithAsOrTo(String name) {
  final regExp = new RegExp(r"(to|as|_to|_as)[A-Z]", caseSensitive: true);
  return regExp.matchAsPrefix(name) != null;
}

bool _containsReturn(BlockFunctionBody body) {
  final visitor = new _ContainsReturnVisitor();
  body.accept(visitor);
  return visitor.containsReturn;
}

bool _hasInheritedMethod(MethodDeclaration node) =>
    DartTypeUtilities.lookUpInheritedMethod(node) != null;

bool _hasSideEffect(FunctionBody node) {
  final visitor = new _SideEffectVisitor();
  node.accept(visitor);
  return visitor.hasSideEffect;
}

bool _returnsSomething(FunctionBody body) {
  final visitor = new _ReturnSomethingVisitor();
  body.accept(visitor);
  return visitor.returnsSomething;
}

class UseGettersToAccessProperties extends LintRule {
  _Visitor _visitor;
  UseGettersToAccessProperties()
      : super(
            name: 'use_getters_to_access_properties',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _ContainsReturnVisitor extends RecursiveAstVisitor {
  var containsReturn = false;

  @override
  visitReturnStatement(ReturnStatement node) {
    if (node.expression != null) {
      containsReturn = true;
    }
  }
}

class _ReturnSomethingVisitor extends SimpleAstVisitor {
  var returnsSomething = false;
  @override
  visitBlockFunctionBody(BlockFunctionBody node) {
    returnsSomething = _containsReturn(node);
  }

  @override
  visitExpressionFunctionBody(ExpressionFunctionBody node) {
    returnsSomething = true;
  }
}

class _SideEffectVisitor extends UnifyingAstVisitor {
  var hasSideEffect = false;

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    hasSideEffect = true;
  }

  @override
  visitBinaryExpression(BinaryExpression node) {
    if (hasSideEffect) {
      return;
    }
    if (node.operator.type == TokenType.EQ_EQ ||
        node.operator.type == TokenType.BANG_EQ) {
      if (DartTypeUtilities.isNullLiteral(node.leftOperand)) {
        node.rightOperand.accept(this);
      } else if (DartTypeUtilities.isNullLiteral(node.rightOperand)) {
        node.leftOperand.accept(this);
      } else {
        hasSideEffect = true;
      }
    } else if (node.operator.isUserDefinableOperator) {
      hasSideEffect = true;
    } else {
      visitNode(node);
    }
  }

  @override
  visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    hasSideEffect = true;
  }

  @override
  visitIndexExpression(IndexExpression node) {
    hasSideEffect = true;
  }

  @override
  visitInstanceCreationExpression(InstanceCreationExpression node) {
    hasSideEffect = true;
  }

  @override
  visitListLiteral(ListLiteral node) {
    hasSideEffect = true;
  }

  @override
  visitMapLiteral(MapLiteral node) {
    hasSideEffect = true;
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    hasSideEffect = true;
  }

  @override
  visitNativeClause(NativeClause node) {
    hasSideEffect = true;
  }

  @override
  visitNode(AstNode node) {
    if (!hasSideEffect) {
      node.visitChildren(this);
    }
  }

  @override
  visitPostfixExpression(PostfixExpression node) {
    hasSideEffect = true;
  }

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) {
    hasSideEffect = true;
  }

  @override
  visitPrefixExpression(PrefixExpression node) {
    hasSideEffect = true;
  }

  @override
  visitPropertyAccess(PropertyAccess node) {
    hasSideEffect = true;
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    final body = node.body;
    if (!node.isGetter &&
        !node.isSetter &&
        node.parameters?.parameters?.isEmpty == true &&
        node.returnType?.type?.name != 'void' &&
        node.operatorKeyword == null &&
        !_beginsWithAsOrTo(node.name.name) &&
        !_hasInheritedMethod(node) &&
        _returnsSomething(body) &&
        !_hasSideEffect(body)) {
      rule.reportLint(node.name);
    }
  }
}
