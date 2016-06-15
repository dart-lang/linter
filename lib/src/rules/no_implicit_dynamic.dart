// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.annotate_types;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/linter.dart';
import 'package:linter/src/util.dart';

const desc = 'Implicit use of dynamic.';

const details = '''
**AVOID** using "implicitly dynamic" values.

Untyped / dynamic invocations may fail or be slower at runtime, but dynamic
types often creep up unintentionally. Explicitly mark variables or return types
as `dynamic` (instead of `var`) to express your intent unequivocally.

Note: this works best with the --strong command-line flag and after disabling
both `always_specify_types` and `always_declare_return_types` lints.

**GOOD:**
```dart
String trim(String s) => s.trim();

main() {
  var s = trim(' a ').toUpperCase();

  dynamic x;
  x = ... ;
  x.reallyNotSureThisExists();
}
```

**BAD:**
```dart
trim(s) => s.trim();

main() {
  var s = trim(1).toUpperCase();

  var x;
  x = ... ;
  x.reallyNotSureThisExists();
}
```
''';

class NoImplicitDynamic extends LintRule {
  NoImplicitDynamic()
      : super(
            name: 'no_implicit_dynamic',
            description: desc,
            details: details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

// TODO(ochafik): Handle implicit return types of method declarations (vs. overrides).
class Visitor extends SimpleAstVisitor {
  final LintRule rule;
  Visitor(this.rule);

  Element _getBestElement(Expression node) {
    if (node is SimpleIdentifier) return node.bestElement;
    if (node is PrefixedIdentifier) return node.bestElement;
    if (node is PropertyAccess) return node.propertyName.bestElement;
    return null;
  }

  bool _isImplicitDynamic(Expression node) {
    if (node == null) return false;
    while (node is ParenthesizedExpression) {
      node = node.expression;
    }

    if (node is AsExpression || node is Literal) return false;
    var t = node.bestType;
    if (!t.isDynamic && !t.isObject) return false;

    var e = _getBestElement(node);
    if (e is PropertyAccessorElement) e = e.variable;
    if (e is VariableElement) return e.hasImplicitType;

    if (node is ConditionalExpression) {
      return !node.thenExpression.bestType.isDynamic ||
         !node.elseExpression.bestType.isDynamic;
    }
    if (node is MethodInvocation) {
      return node.methodName.bestElement?.hasImplicitReturnType != false;
    }

    return true;
  }

  void _checkTarget(Expression target, [token]) {
    if (_isImplicitDynamic(target)) {
      // Avoid double taxation (if `x` is dynamic, only lint `x.y.z` once).
      Expression subTarget;
      if (target is PropertyAccess) subTarget = target.realTarget;
      else if (target is MethodInvocation) subTarget = target.realTarget;
      else if (target is IndexExpression) subTarget = target.realTarget;
      else if (target is PrefixedIdentifier) subTarget = target.prefix;

      if (_isImplicitDynamic(subTarget)) return;

      _reportNodeOrToken(target, token);
    }
  }

  _reportNodeOrToken(AstNode node, token) {
    if (token != null) {
      rule.reportLintForToken(token);
    } else {
      rule.reportLint(node);
    }
  }

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isObjectProperty(node.identifier)) return;
    _checkTarget(node.prefix, node.period);
  }

  @override
  visitPropertyAccess(PropertyAccess node) {
    if (_isObjectProperty(node.propertyName)) return;
    _checkTarget(node.realTarget, node.operator);
  }

  bool _isObjectProperty(SimpleIdentifier node) {
    var name = node.name;
    return name == 'runtimeType' || name == 'hashCode';
  }

  @override
  visitIndexExpression(IndexExpression node) {
    _checkTarget(node.realTarget, node.leftBracket);
  }

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    var rhs = node.rightHandSide;
    _checkAssignment(rhs,
        rhs.bestParameterElement ?? _getBestElement(node.leftHandSide));
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    var methodName = node.methodName;
    _checkMethodInvocation(node.realTarget, methodName.bestElement, methodName.name, node.argumentList.arguments, node.operator);
  }

  _checkMethodInvocation(Expression target, ExecutableElement methodElement, String methodName, List<Expression> arguments, token) {
    for (var arg in arguments) {
      _checkAssignment(arg, arg.bestParameterElement);
    }

    if (methodElement != null) return;

    if (methodName == 'toString' && arguments.isEmpty ||
        methodName == 'noSuchMethod' && arguments.size == 1) {
      return;
    }
    _checkTarget(target, token);
  }

  @override
  visitBinaryExpression(BinaryExpression node) {
    _checkMethodInvocation(node.leftOperand, node.bestElement, node.operator.toString(), [node.rightOperand], node.operator);
  }

  _checkAssignment(Expression arg, Element toElement) {
    if (!_isImplicitDynamic(arg)) return;

    if (toElement == null) return;

    if (_isDynamicOrObject(toElement.type)) return;

    rule.reportLint(arg);
  }

  _isDynamicOrObject(DartType t) => t.isDynamic || t.isObject;

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _checkTarget(node.condition);
  }

  @override
  visitDeclaredIdentifier(DeclaredIdentifier node) {
    if (node.type == null && node.identifier.bestType.isDynamic && node.element.type.isDynamic) {
      rule.reportLintForToken(node.keyword);
    }
  }
}
