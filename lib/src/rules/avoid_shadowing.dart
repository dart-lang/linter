// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.avoid_shadowing;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const desc = r'Do not use a name already visible.';

const details = r'''

**DO** Do not use a name already visible as getter or variable.

**BAD:**
```
var k = null;

class A {
  var a;
}

class B extends A {
  get b => null;

  m() {
    var a; // LINT
    var b; // LINT
    var k; // LINT
  }
}
```

**GOOD:**
```
var k = null;

class A {
  var a;
}

class B extends A {
  get b => null;

  m() {
    var c; // OK
    var d; // OK
    var e; // OK
  }
}
```
''';

class AvoidShadowing extends LintRule implements NodeLintRule {
  AvoidShadowing()
      : super(
            name: 'avoid_shadowing',
            description: desc,
            details: details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addVariableDeclarationStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final variables = node.variables.variables.toList();
    final library = variables.first.declaredElement.library;

    // exclude pattern : var name = this.name;
    variables.removeWhere((variable) {
      final initializer = variable.initializer;
      return initializer is PropertyAccess &&
          initializer.propertyName.name == variable.name.name &&
          (initializer.target is ThisExpression ||
              initializer.target is SuperExpression);
    });

    // exclude pattern : same name as current getter name
    var currentGetter = _getCurrentGetter(node);
    if (currentGetter != null) {
      variables.removeWhere(
          (variable) => currentGetter.name.name == variable.name.name);
    }

    bool skipInstanceMembers = false;
    AstNode current = node;
    while (current != null) {
      if (current is ClassDeclaration) {
        _checkClass(current, variables, onlyStatics: skipInstanceMembers);
      } else if (current is ConstructorDeclaration) {
        _checkParameters(current.parameters, variables);
        if (current.factoryKeyword != null) {
          skipInstanceMembers = true;
        }
      } else if (current is MethodDeclaration) {
        _checkParameters(current.parameters, variables);
        if (current.isStatic) {
          skipInstanceMembers = true;
        }
      } else if (current is FunctionExpression) {
        _checkParameters(current.parameters, variables);
      } else if (current is FunctionDeclaration) {
        _checkParameters(current.functionExpression.parameters, variables);
      } else if (current is FunctionDeclarationStatement) {
        _checkParameters(
            current.functionDeclaration.functionExpression.parameters,
            variables);
      }

      if (current.parent is Block) {
        _checkParentBlock(current, variables);
      }

      current = current.parent;
    }
    _checkLibrary(library, variables);
  }

  void _checkClass(
    ClassDeclaration clazz,
    List<VariableDeclaration> variables, {
    bool onlyStatics,
  }) {
    for (final variable in variables) {
      final name = variable.name.name;
      final getter = clazz.declaredElement
          .lookUpGetter(name, clazz.declaredElement.library);
      if (getter != null && (!onlyStatics || getter.isStatic))
        rule.reportLint(variable);
    }
  }

  void _checkLibrary(
      LibraryElement library, List<VariableDeclaration> variables) {
    final topLevelVariableNames = library.units
        .expand((u) => u.topLevelVariables)
        .map((e) => e.name)
        .toList();
    for (final variable in variables) {
      final name = variable.name.name;
      if (topLevelVariableNames.contains(name)) {
        rule.reportLint(variable);
      }
    }
  }

  void _checkParameters(
      FormalParameterList parameters, List<VariableDeclaration> variables) {
    if (parameters == null) return;

    final parameterNames =
        parameters.parameterElements.map((e) => e.name).toList();

    for (final variable in variables) {
      final name = variable.name.name;
      if (parameterNames.contains(name)) {
        rule.reportLint(variable);
      }
    }
  }

  void _checkParentBlock(AstNode node, List<VariableDeclaration> variables) {
    final block = node.parent as Block;
    final names = <String>[];
    for (final statement in block.statements.takeWhile((n) => n != node)) {
      if (statement is VariableDeclarationStatement) {
        names.addAll(statement.variables.variables.map((e) => e.name.name));
      }
    }
    for (final variable in variables) {
      final name = variable.name.name;
      if (names.contains(name)) {
        rule.reportLint(variable);
      }
    }
  }

  MethodDeclaration _getCurrentGetter(VariableDeclarationStatement node) {
    AstNode current = node.parent;
    while (current != null) {
      if (current is Block || current is FunctionBody) {
        current = current.parent;
      } else if (current is MethodDeclaration && current.isGetter) {
        return current;
      } else {
        break;
      }
    }
    return null;
  }
}
