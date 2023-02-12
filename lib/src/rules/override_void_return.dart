// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Non-void return overriding void return.';

const _details = r'''
Do not override a `void`-returning method with a non-`void`-returning method.

**BAD:**
```dart
abstract class One {
  void m();
}

class One extends Two {
  Future<void> m() async {
    return Future.delayed(Duration(seconds: 3), () => print('Hello'));
  }
}
```

**GOOD:**
```dart
abstract class One {
  void m();
}

class One extends Two {
  void m() async {
    return Future.delayed(Duration(seconds: 3), () => print('Hello'));
  }
}
```

''';

class OverrideVoidReturn extends LintRule {
  static const LintCode code = LintCode(
      'override_void_return',
      "The member '{0}' specifies a non-void return type, but overrides a "
          'member with a void return type.',
      correctionMessage: 'Try using a void return type.');

  OverrideVoidReturn()
      : super(
            name: 'override_void_return',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  Element? getOverriddenMember(Element element) {
    var classElement = element.thisOrAncestorOfType<InterfaceElement>();
    if (classElement == null) {
      return null;
    }
    var name = element.name;
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
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isStatic) return;
    var element = node.declaredElement;
    if (element == null) return;
    if (!element.returnType.isVoid) {
      var overriddenMember = getOverriddenMember(element);
      if (overriddenMember is! MethodElement) return;
      if (overriddenMember.returnType.isVoid) {
        rule.reportLintForToken(node.name, arguments: [overriddenMember.name]);
      }
    }
  }
}
