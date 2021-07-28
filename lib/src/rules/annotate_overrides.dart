// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Annotate overridden members.';

const _details = r'''

**DO** annotate overridden methods and fields.

This practice improves code readability and helps protect against
unintentionally overriding superclass members.

**GOOD:**
```dart
abstract class Dog {
  String get breed;
  void bark() {}
}

class Husky extends Dog {
  @override
  final String breed = 'Husky';
  @override
  void bark() {}
}
```

**BAD:**
```dart
class Cat {
  int get lives => 9;
}

class Lucky extends Cat {
  final int lives = 14;
}
```

''';

class AnnotateOverrides extends LintRule implements NodeLintRule {
  AnnotateOverrides()
      : super(
            name: 'annotate_overrides',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);

    // Cache parent element.
    registry.addClassDeclaration(this, visitor);
    registry.addExtensionDeclaration(this, visitor);
    registry.addMixinDeclaration(this, visitor);

    // Do the work.
    registry.addFieldDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  ClassElement? classElement;

  _Visitor(this.rule, this.context);

  void check(Element? element, AstNode target) {
    if (element == null || element.hasOverride) return;

    var member = getOverriddenMember(element);
    if (member != null) {
      rule.reportLint(target);
    }
  }

  Element? getOverriddenMember(Element member) {
    var classElement = this.classElement;
    if (classElement == null) {
      return null;
    }

    var name = member.name;
    if (name == null) {
      return null;
    }

    var libraryUri = classElement.library.source.uri;
    return context.inheritanceManager.getInherited(
      classElement.thisType,
      Name(libraryUri, name),
    );
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Cache class element to speed up access to overridden member information.
    classElement = node.declaredElement;
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    // Clear the (possibly) cached element.
    classElement = null;
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.isStatic) return;

    for (var field in node.fields.variables) {
      check(field.declaredElement, field);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isStatic) return;

    check(node.declaredElement, node.name);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    // Clear the (possibly) cached element.
    classElement = null;
  }
}
