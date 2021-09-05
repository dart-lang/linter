// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../ast.dart';

const _desc = r"Don't rename parameters of overridden methods.";

const _details = r'''**DON'T** rename parameters of overridden methods.

Methods that override another method, but do not have their own documentation
comment, will inherit the overridden method's comment when dartdoc produces
documentation. If the inherited method contains the name of the parameter (in
square brackets), then dartdoc cannot link it correctly.

**BAD:**
```dart
abstract class A {
  m(a);
}

abstract class B extends A {
  m(b);
}
```

**GOOD:**
```dart
abstract class A {
  m(a);
}

abstract class B extends A {
  m(a);
}
```

''';

class AvoidRenamingMethodParameters extends LintRule {
  AvoidRenamingMethodParameters()
      : super(
            name: 'avoid_renaming_method_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    if (!isInLibDir(context.currentUnit.unit, context.package)) {
      return;
    }

    var visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  static const LintCode parameterCode = LintCode(
      "avoid_renaming_method_parameters", // ignore: prefer_single_quotes
      "The parameter '{0}' should have the name '{1}' to match the name used in the overridden method.",
      correction:
          "Try renaming the parameter."); // ignore: prefer_single_quotes

  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isStatic) return;
    if (node.documentationComment != null) return;

    var parentNode = node.parent;
    if (parentNode is! Declaration) {
      return;
    }
    var parentElement = parentNode.declaredElement;
    // Note: there are no override semantics with extension methods.
    if (parentElement is! ClassElement) {
      return;
    }

    var classElement = parentElement;

    if (classElement.isPrivate) return;

    var parentMethod = classElement.lookUpInheritedMethod(
        node.name.name, classElement.library);

    if (parentMethod == null) return;

    var nodeParams = node.parameters;
    if (nodeParams == null) {
      return;
    }

    var parameters = nodeParams.parameters.where((p) => !p.isNamed).toList();
    var parentParameters =
        parentMethod.parameters.where((p) => !p.isNamed).toList();
    var count = math.min(parameters.length, parentParameters.length);
    for (var i = 0; i < count; i++) {
      if (parentParameters.length <= i) break;
      var paramIdentifier = parameters[i].identifier;
      if (paramIdentifier != null &&
          paramIdentifier.name != parentParameters[i].name) {
        rule.reportLint(paramIdentifier,
            arguments: [paramIdentifier.name, parentParameters[i].name],
            errorCode: parameterCode);
      }
    }
  }
}
