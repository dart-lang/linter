// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../analyzer.dart';

const _desc = r'Avoid method calls and property access on a "dynamic" target.';

const _details = r'''

**DO** avoid method calls or accessing properties on an object that is either
explicitly or implicitly statically typed "dynamic". Dynamic calls are treated
slightly different in every runtime environment and compiler, but most
production modes (and even some development modes) have both compile size and
runtime performance penalties associated with dynamic calls.

Additionally, targets typed "dynamic" disables most static analysis, meaning it
is easier to lead to a runtime "NoSuchMethodError" or "NullError" than properly
statically typed Dart code.

Note, that despite "Function" being a type, the semantics are close to identical
to "dynamic", and calls to an object that is typed "Function" will also trigger
this lint.

**BAD:**
```
void explicitDynamicType(dynamic object) {
  print(object.foo());
}

void implicitDynamicType(object) {
  print(object.foo());
}

abstract class SomeWrapper {
  T doSomething<T>();
}

void inferredDynamicType(SomeWrapper wrapper) {
  var object = wrapper.doSomething();
  print(object.foo());
}

void callDynamic(dynamic function) {
  function();
}

void functionType(Function function) {
  function();
}
```

**GOOD:**
```
void explicitType(Fooable object) {
  object.foo();
}

void castedType(dynamic object) {
  (object as Fooable).foo();
}

abstract class SomeWrapper {
  T doSomething<T>();
}

void inferredType(SomeWrapper wrapper) {
  var object = wrapper.doSomething<Fooable>();
  object.foo();
}

void functionTypeWithParameters(Function() function) {
  function();
}
```

''';

class AvoidDynamicCalls extends LintRule implements NodeLintRule {
  AvoidDynamicCalls()
      : super(
          name: 'avoid_dynamic_calls',
          description: _desc,
          details: _details,
          group: Group.errors,
          maturity: Maturity.experimental,
        );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    assert(context != null);
    final visitor = _Visitor(this);
    registry
      ..addAssignmentExpression(this, visitor)
      ..addBinaryExpression(this, visitor)
      ..addFunctionExpressionInvocation(this, visitor)
      ..addIndexExpression(this, visitor)
      ..addMethodInvocation(this, visitor)
      ..addPostfixExpression(this, visitor)
      ..addPrefixExpression(this, visitor)
      ..addPrefixedIdentifier(this, visitor)
      ..addPropertyAccess(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  bool _lintIfDynamic(Expression node) {
    if (node?.staticType?.isDynamic == true) {
      rule.reportLint(node);
      return true;
    } else {
      return false;
    }
  }

  void _lintIfDynamicOrFunction(Expression node) {
    final staticType = node?.staticType;
    if (staticType == null) {
      return;
    }
    if (staticType.isDynamic) {
      rule.reportLint(node);
    }
    if (staticType.isDartCoreFunction) {
      rule.reportLint(node);
    }
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.readType?.isDynamic != true) {
      // An assignment expression can only be a dynamic call if it is a
      // "compound assignment" (i.e. such as `x += 1`); so if `readType` is not
      // dynamic, we don't need to check further.
      return;
    }
    if (node.operator.type == TokenType.QUESTION_QUESTION_EQ) {
      // x ??= foo is not a dynamic call.
      return;
    }
    rule.reportLint(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (!node.operator.isUserDefinableOperator) {
      // As of 2021-01-13, the only non-virtual operator that has impact on
      // dynamic calls is "!=", as "a != b" is processed something like
      // !(a == b), invoking operator== on a (virtual-call).
      if (node.operator.type != TokenType.BANG_EQ) {
        return;
      }
    }
    switch (node.operator.type) {
      case TokenType.EQ_EQ:
      case TokenType.BANG_EQ:
        if (node.rightOperand is NullLiteral) {
          // == and != are special-cased in the dart language to be guaranteed
          // non-virtual calls iff the RHS is a "null" literal. This allows fast
          // comparisons, such as "a == null", without invoking a user-defined
          // operator.
          return;
        }
        break;
    }
    _lintIfDynamic(node.leftOperand);
    // We don't check node.rightOperand, because that is an implicit cast, not a
    // dynamic call (the call itself is based on leftOperand). While it would be
    // useful to do so, it is better solved by other more specific lints to
    // disallow implicit casts from dynamic.
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (node.function != null) {
      _lintIfDynamicOrFunction(node.function);
    }
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _lintIfDynamic(node.realTarget);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final receiverWasDynamic = _lintIfDynamic(node.realTarget);
    if (!receiverWasDynamic && node.target == null) {
      _lintIfDynamicOrFunction(node.function);
    }
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (_lintIfDynamic(node.operand)) {
      return;
    }
    switch (node.operator.type) {
      case TokenType.PLUS_PLUS:
      case TokenType.MINUS_MINUS:
        // The ++ and -- operator expressions don't resolve a static type.
        if (node.staticType?.isDynamic == true) {
          rule.reportLint(node.operand);
        }
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _lintIfDynamic(node.prefix);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      // x! is not a dynamic call, even if "x" is dynamic.
      return;
    }
    if (_lintIfDynamic(node.operand)) {
      return;
    }
    switch (node.operator.type) {
      case TokenType.PLUS_PLUS:
      case TokenType.MINUS_MINUS:
        // The ++ and -- operator expressions don't resolve a static type.
        if (node.staticType?.isDynamic == true) {
          rule.reportLint(node.operand);
        }
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess astNode) {
    _lintIfDynamic(astNode.realTarget);
  }
}
