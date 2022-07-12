// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r'Avoid overriding a final field to return '
    'different values if called multiple times';

const _details = r'''

**AVOID** overriding or implementing a final field as a getter which could
return different values if it is invoked multiple times on the same receiver.
This could occur because the getter is an implicitly induced getter of a
non-final field, or it could be an explicitly declared getter with a body
that isn't known to return the same value each time it is called.

The underlying motivation for this rule is that if it is followed then a final
field is an immutable property of an object. This is important for correctness
because it is then safe to assume that the value does not change during the
execution of an algorithm. In contrast, it may be necessary to re-check any
other getter repeatedly if it is not known to have this property. Similarly,
it is safe to cache the immutable property in a local variable and promote it,
but for any other property it is necessary to check repeatedly that the
underlying property hasn't changed since it was promoted.

**BAD:**
```dart
class A {
  final int i;
  A(this.i);
}

var j = 0;

class B1 extends A {
  int get i => ++j + super.i; // LINT.
}

class B2 implements A {
  int i; // LINT.
  B2(this.i);
}
```

**GOOD:**
```dart
class A {
  final int i;
  A(this.i);
}

class B1 implements A {
  late final int i = someExpression; // OK.
}

class B2 extends A {
  int get i => super.i + 1; // OK.
}
```

''';

class AvoidUnstableFinalFields extends LintRule {
  AvoidUnstableFinalFields()
      : super(
            name: 'avoid_unstable_final_fields',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addSimpleIdentifier(this, visitor);
  }
}

bool _requiresStability(Element element) {
  // In this first approximation of 'final getters', no other situation
  // can make a getter stable than being the implicitly induced getter
  // of a final instance variable.
  if (element is! FieldElement) return false;
  return element.isFinal;
}

abstract class _AbstractVisitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  // Initialized in `visitMethodDeclaration` if a lint might be emitted.
  // It is then guaranteed that `declaration.isGetter` is true.
  late final MethodDeclaration declaration;

  _AbstractVisitor(this.rule, this.context);

  // The following visitor methods will only be executed in the situation
  // where `declaration` is a getter which must be stable, and the
  // traversal is visiting the body of said getter. Hence, a lint must
  // be emitted whenever the given body is not known to be appropriate
  // for a stable getter.

  @override
  void visitBlock(Block node) {
    // TODO(eernst): Check that only one return statement exists, and it is
    // the last statement in the body, and it returns a stable expression.
    if (node.statements.length == 1) {
      node.statements.first.accept(this);
    }
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    visitBlock(node.block);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    node.expression.accept(this);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    node.expression.accept(this);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    node.unParenthesized.accept(this);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    node.expression?.accept(this);
  }

  @override
  void visitSuperExpression(SuperExpression node) {
    rule.reportLint(declaration.name);
  }
}

class _MethodVisitor extends _AbstractVisitor {
  late MethodDeclaration declaration;

  _MethodVisitor(super.rule, super.context);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isGetter) return;
    declaration = node;
    var declaredElement = node.declaredElement;
    if (declaredElement != null) {
      if (!_requiresStability(declaredElement)) return;
      node.body.accept(this);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    assert(!node.isStatic);
    Uri? libraryUri;
    Name? name;
    ClassElement? classElement;
    for (var variable in node.fields.variables) {
      var declaredElement = variable.declaredElement;
      if (declaredElement is FieldElement) {
        // A final instance variable can never violate stability.
        if (declaredElement.isFinal) continue;
        // A non-final instance variable is always a violation of stability.
        // Check if stability is required.
        if (classElement == null) {
          classElement = declaredElement.enclosingElement as ClassElement;
        }
        if (libraryUri == null) {
          libraryUri = declaredElement.library.source.uri;
        }
        if (name == null) {
          name = Name(libraryUri, declaredElement.name);
        }
        var overriddenList =
        context.inheritanceManager.getOverridden2(classElement, name);
        if (overriddenList == null) continue;
        for (var overridden in overriddenList) {
          if (_requiresStability(overridden)) {
            rule.reportLint(variable.name);
          }
        }
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isStatic && node.isGetter) {
      var visitor = _MethodVisitor(rule, context);
      visitor.visitMethodDeclaration(node);
    }
  }
}
