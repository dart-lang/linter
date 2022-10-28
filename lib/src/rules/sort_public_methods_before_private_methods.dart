// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Define public methods before private methods.';

const _details = r'''
**DO** define public methods before private methods.

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

class SortPublicMethodsBeforePrivateMethods extends LintRule {
  SortPublicMethodsBeforePrivateMethods()
      : super(
            name: 'sort_public_methods_before_private_methods',
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
      if (member is MethodDeclaration) {
        if (foundPrivateMethod && !_isPrivateName(member: member)) {
          rule.reportLint(member.returnType);
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
