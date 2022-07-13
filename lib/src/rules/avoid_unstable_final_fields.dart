// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

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
  B1(super.i);
}

class B2 implements A {
  int i; // LINT.
  B2(this.i);
}
```

**GOOD:**
```dart
class C {
  final int i;
  C(this.i);
}

class D1 implements C {
  late final int i = someExpression; // OK.
}

class D2 extends C {
  int get i => super.i + 1; // OK.
  D2(super.i);
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
    registry.addFieldDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

bool _isLocallyStable(Element element) {
  if (element is PropertyAccessorElement &&
      element.isSynthetic &&
      element.correspondingSetter == null) {
    // This is a final, non-local variable, and they are stable.
    return true;
  } else if (element is FunctionElement) {
    // A tear-off of a top-level function or static method is stable,
    // local functions and function literals are not.
    return element.isStatic;
  } else if (element is ClassElement) {
    // A reified type of a class is stable.
    return true;
  } else if (element is MethodElement) {
    // An instance method tear-off is never stable.
    return false;
  }
  // TODO(eernst): Any cases still missing?
  return false;
}

bool _inheritsStability(
    ClassElement classElement, Name name, LinterContext context) {
  var overriddenList =
      context.inheritanceManager.getOverridden2(classElement, name);
  if (overriddenList == null) return false;
  for (var overridden in overriddenList) {
    if (_isLocallyStable(overridden)) return true;
  }
  return false;
}

bool _isStable(Element? element, LinterContext context) {
  if (element == null) return false; // This would be an error in the program.
  var enclosingElement = element.enclosingElement;
  if (_isLocallyStable(element)) return true;
  if (element is PropertyAccessorElement) {
    if (element.isStatic) return false;
    if (enclosingElement is! ClassElement) {
      // This should not happen, a top-level variable `isStatic`.
      // TODO(eernst): Do something like `throw Unhandled(...)`.
      return false;
    }
    var libraryUri = element.library.source.uri;
    var name = Name(libraryUri, element.name);
    return _inheritsStability(enclosingElement, name, context);
  }
  return false;
}

abstract class _AbstractVisitor extends ThrowingAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  // Will be true initially when a getter body is traversed. Will be made
  // true if the getter body turns out to be unstable. Is checked after the
  // traversal of the body, ot emit a lint if it is still false at that time.
  bool isStable = true;

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
  void visitAsExpression(AsExpression node) {
    node.expression.accept(this);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    var operator = node.operator;
    if (operator.type != TokenType.EQ) {
      // TODO(eernst): Could a compound assignment be stable?
      isStable = false;
    } else {
      // A regular assignment is stable iff its right hand side is stable.
      node.rightHandSide.accept(this);
    }
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    // We cannot predict the outcome of awaiting a future.
    isStable = false;
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    node.leftOperand.accept(this);
    node.rightOperand.accept(this);
    if (isStable) {
      // So far no problems! Only a few cases are working,
      // see if we have one of those.
      var operatorType = node.operator.type;
      var leftType = node.leftOperand.staticType;
      if (leftType == null) {
        isStable = false; // Presumably a wrong program. Be safe.
        return;
      }
      if (operatorType == TokenType.PLUS) {
        if (leftType.isDartCoreInt ||
            leftType.isDartCoreDouble ||
            leftType.isDartCoreString) {
          // These are all stable.
          return;
        } else {
          // A user-defined `+` cannot be assumed to be stable.
          isStable = false;
        }
      } else if (operatorType == TokenType.EQ_EQ || operatorType == TokenType.BANG_EQ) {
        // Equality/inequality of two stable expressions is stable.
        return;
      } else if (operatorType == TokenType.AMPERSAND_AMPERSAND || operatorType == TokenType.BAR_BAR) {
        // Logical and/or cannot be user-defined, is stable.
        return;
      } else if (operatorType == TokenType.MINUS ||
          operatorType == TokenType.STAR ||
          operatorType == TokenType.SLASH ||
          operatorType == TokenType.PERCENT ||
          operatorType == TokenType.LT ||
          operatorType == TokenType.LT_EQ ||
          operatorType == TokenType.GT ||
          operatorType == TokenType.GT_EQ) {
        if (leftType.isDartCoreInt || leftType.isDartCoreDouble) {
          // Primitive arithmetic operations and relations are stable.
          return;
        } else {
          // A user-defined operator can not be assumed to be stable.
          isStable = false;
        }
      } else if (operatorType == TokenType.QUESTION_QUESTION) {
        // An if-null expression with stable operands is stable.
        return;
      }
      // TODO(eernst): Add support for missing cases, if any.
      isStable = false;
    }
  }

  @override
  void visitBlock(Block node) {
    // TODO(eernst): Check that only one return statement exists, and it is
    // the last statement in the body, and it returns a stable expression.
    if (node.statements.length == 1) {
      var statement = node.statements.first;
      if (statement is ReturnStatement) {
        statement.accept(this);
      } else {
        // TODO(eernst): Detect further cases where stability holds.
        isStable = false;
      }
    } else {
      // TODO(eernst): Allow multiple statements, just check returns.
      isStable = false;
    }
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    visitBlock(node.block);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    // Keep it stable!
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    // A cascade is stable if its target is stable.
    node.target.accept(this);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    node.condition.accept(this);
    node.thenExpression.accept(this);
    node.elseExpression.accept(this);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    // Keep it stable!
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
  void visitFunctionExpression(FunctionExpression node) {
    // We cannot expect the function literal to be the same function, only if
    // we introduce constant expressions that are function literals.
    isStable = false;
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // We cannot expect a function invocation to be stable.
    isStable = false;
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    // The type system does not recognize immutable lists or similar entities,
    // so we can never hope to detect that this is stable.
    isStable = false;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!node.isConst) isStable = false;
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    // Keep it stable!
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    node.expression.accept(this);
  }

  @override
  void visitIsExpression(IsExpression node) {
    // Testing `e is T` where `e` is stable depends on `T`. However, there is
    // no `<type>` that denotes two different types in the context of the same
    // receiver (so class type variables represent the same type each time this
    // getter is invoked, and we can't have member type variables in a getter).
    // Hence, we just need to check that `e` is stable.
    node.expression.accept(this);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    if (!node.isConst) isStable = false;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // We could have a notion of pure functions, but for now a
    // method invocation is never stable.
    isStable = false;
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    node.expression.accept(this);
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    // Keep it stable!
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    node.unParenthesized.accept(this);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    // `x.y?.z` is handled in [visitPropertyAccess], this is only about
    // `<assignableExpression> <postfixOperator>`, and they are not stable.
    isStable = false;
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node.operator.type == TokenType.MINUS) {
      node.operand.accept(this);
    } else {
      isStable = false;
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    var prefixDeclaration = node.prefix.staticElement?.declaration;
    if (prefixDeclaration is PrefixElement) {
      var declaredElement = node.identifier.staticElement?.declaration;
      if (!_isStable(declaredElement, context)) isStable = false;
    } else if (prefixDeclaration is ClassElement) {
      var declaredElement = node.identifier.staticElement?.declaration;
      if (!_isStable(declaredElement, context)) isStable = false;
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    node.realTarget.accept(this);
    if (isStable) {
      var element = node.propertyName.staticElement?.declaration;
      if (!_isStable(element, context)) isStable = false;
    }
  }

  @override
  void visitRethrowExpression(RethrowExpression node) {
    // Throws, cannot be unstable.
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    node.expression?.accept(this);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (!node.isConst) isStable = false;
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    var declaration = node.staticElement?.declaration;
    if (!_isStable(declaration, context)) {
      isStable = false;
    }
  }

  @override
  void visitSimplStringLiteral(SimpleStringLiteral node) {
    // No interpolations: Keep it stable!
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    var interpolationElements = node.elements;
    for (var interpolationElement in interpolationElements) {
      if (interpolationElement is InterpolationExpression) {
        interpolationElement.expression.accept(this);
      }
    }
  }

  @override
  void visitSuperExpression(SuperExpression node) {
    // This is simply the keyword `super`: Keep it stable!
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    // Keep it stable!
  }

  @override
  void visitThisExpression(ThisExpression node) {
    // Keep it stable!
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    // Keep it stable!
  }

  @override
  void visitTypeLiteral(TypeLiteral node) {
    // A type literal can contain a type parameter of the enclosing class
    // (in a getter it can't be a type parameter of the member). This means
    // that it denotes the same type each time it is evaluated on the same
    // receiver, but it may still be a different object. So we need to exclude
    // type literals that contain type variables.

    bool containsNonConstantType(TypeAnnotation? typeAnnotation) {
      if (typeAnnotation == null) return false;
      if (typeAnnotation is NamedType) {
        var typeArguments = typeAnnotation.typeArguments;
        if (typeArguments != null) {
          for (var typeArgument in typeArguments.arguments) {
            if (containsNonConstantType(typeArgument)) return true;
          }
        }
        var element = typeAnnotation.type?.element?.declaration;
        if (element is ClassElement) return false;
        if (element is TypeParameterElement) {
          var owner = element.enclosingElement;
          // A class type parameter is not constant, but it is stable.
          if (owner is ClassElement) return false;
          return true;
        }
        // TODO(eernst): Handle `typedef` and other missing cases.
        return true;
      } else if (typeAnnotation is GenericFunctionType) {
        // TODO(eernst): For now, just use the safe approximation.
        return true;
      } else {
        // TODO(eernst): Add missing cases. Be safe for now.
        return true;
      }
    }

    if (containsNonConstantType(node.type)) isStable = false;
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
      var classElement = declaredElement.enclosingElement as ClassElement;
      var libraryUri = declaredElement.library.source.uri;
      var name = Name(libraryUri, declaredElement.name);
      if (!_inheritsStability(classElement, name, context)) return;
      node.body.accept(this);
      if (!isStable) rule.reportLint(node.name);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
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
        classElement ??= declaredElement.enclosingElement as ClassElement;
        libraryUri ??= declaredElement.library.source.uri;
        name ??= Name(libraryUri, declaredElement.name);
        if (_inheritsStability(classElement, name, context)) {
          rule.reportLint(variable.name);
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
