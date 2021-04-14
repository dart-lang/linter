// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'''Don't return a Widget outside the build method of '
    'a StatelessWidget or a StatefulWidget''';

const _details = r'''
**DON'T** return a Widget outside the build method of a StatelesWidget or a 
StatefulWidget

It is considered a good practice to create a new class every time you need to 
reuse a new widget, instead of creating a field, method or function.

**BAD:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return myWidget();
  }

  Widget myWidget() => Row(children: [Container()]);
}
```

**GOOD:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomWidget();
  }
}

class CustomWidget extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container()]);
  }}
```
''';

class AvoidReturningWidgets extends LintRule implements NodeLintRule {
  AvoidReturningWidgets()
      : super(
            name: 'avoid_returning_widgets',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
    registry.addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final LintRule rule;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_isReturningWidget(node.returnType) && !_isBuildMethodOfWidget(node)) {
      rule.reportLint(node);
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (_isReturningWidget(node.returnType)) {
      rule.reportLint(node);
    }
  }

  bool _isReturningWidget(TypeAnnotation? typeAnnotation) =>
      typeAnnotation != null && isWidgetType(typeAnnotation.type);

  bool _isBuildMethod(ExecutableElement? element) => element?.name == 'build';

  bool _isBuildMethodOfWidget(MethodDeclaration node) {
    if (_isBuildMethod(node.declaredElement)) {
      return _isStatelessWidgetOrState(node);
    }
    return false;
  }

  bool _isStatelessWidgetOrState(MethodDeclaration node) {
    var parent = node.thisOrAncestorOfType<ClassDeclaration>();
    var element = parent?.declaredElement;
    return isStatelessWidget(element) || isState(element);
  }
}
