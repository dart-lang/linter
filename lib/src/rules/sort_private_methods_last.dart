// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Define private methods below public methods.';

const _details = r'''
**DO** define private methods below public methods.

This makes the code uniform across multiple classes
and it makes it faster to find specific methods in a class. 

**BAD:**
```dart
class A {
  int a() => 0;
  int _b() => 0;
  int c() => 0;
}
```

**GOOD:**
```dart
class A {
  int a() => 0;
  int c() => 0;
  int _b() => 0;
}
```

''';

class SortPrivateMethodsLast extends LintRule {
  SortPrivateMethodsLast()
      : super(
            name: 'sort_private_methods_last',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
    registry.addEnumDeclaration(this, visitor);
    registry.addMixinDeclaration(this, visitor);
    registry.addExtensionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  void check(NodeList<ClassMember> members) {
    bool foundPrivateMethod = false;
    // Members are sorted by source position in the AST.
    for (var member in members) {
      if (member is MethodDeclaration &&
          member.modifierKeyword?.keyword != Keyword.STATIC) {
        if (foundPrivateMethod && !_isPrivateName(member: member)) {
          rule.reportLint(member.parent);
          return;
        }
        if (_isPrivateName(member: member)) {
          foundPrivateMethod = true;
        }
      }
    }
  }

  bool _isPrivateName({required MethodDeclaration member}) =>
      Identifier.isPrivateName(member.name.toString());

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    check(node.members);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    check(node.members);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    check(node.members);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    check(node.members);
  }
}
