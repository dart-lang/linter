// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc = r'Avoid positional boolean parameters.';

const _details = r'''
**AVOID** positional boolean parameters.

Positional boolean parameters are a bad practice because they are very
ambiguous.  Using named boolean parameters is much more readable because it
inherently describes what the boolean value represents.

**BAD:**
```dart
Task(true);
Task(false);
ListBox(false, true, true);
Button(false);
```

**GOOD:**
```dart
Task.oneShot();
Task.repeating();
ListBox(scroll: true, showScrollbars: true);
Button(ButtonState.enabled);
```

''';

class AvoidPositionalBooleanParameters extends LintRule {
  AvoidPositionalBooleanParameters()
      : super(
            name: 'avoid_positional_boolean_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addConstructorDeclaration(this, visitor);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    var declaredElement = node.declaredElement2;
    if (declaredElement != null && !declaredElement.isPrivate) {
      var parametersToLint =
          node.parameters.parameters.where(_isFormalParameterToLint);
      if (parametersToLint.isNotEmpty) {
        rule.reportLint(parametersToLint.first);
      }
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    var declaredElement = node.declaredElement2;
    if (declaredElement != null && !declaredElement.isPrivate) {
      var parametersToLint = node.functionExpression.parameters?.parameters
          .where(_isFormalParameterToLint);
      if (parametersToLint != null && parametersToLint.isNotEmpty) {
        rule.reportLint(parametersToLint.first);
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    var declaredElement = node.declaredElement2;
    if (declaredElement != null &&
        !node.isSetter &&
        !declaredElement.isPrivate &&
        !node.isOperator &&
        !node.hasInheritedMethod &&
        !_isOverridingMember(declaredElement)) {
      var parametersToLint =
          node.parameters?.parameters.where(_isFormalParameterToLint);
      if (parametersToLint != null && parametersToLint.isNotEmpty) {
        rule.reportLint(parametersToLint.first);
      }
    }
  }

  bool _isFormalParameterToLint(FormalParameter node) {
    var type = node.declaredElement?.type;
    return !node.isNamed && type is InterfaceType && type.isDartCoreBool;
  }

  bool _isOverridingMember(Element member) {
    var classElement = member.thisOrAncestorOfType<ClassElement>();
    if (classElement == null) {
      return false;
    }
    var name = member.name;
    if (name == null) {
      return false;
    }
    var libraryUri = classElement.library.source.uri;
    return context.inheritanceManager
            .getInherited(classElement.thisType, Name(libraryUri, name)) !=
        null;
  }
}
