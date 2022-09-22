// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'Unnecessary StatefulWidget.';

const _details = r'''

Don't use `StatefulWidget` when a `StatelessWidget` is sufficient. Using a
`StatelessWidget` where appropriate leads to more compact, concise, and readable
code and is more idiomatic.

**BAD:**

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**GOOD:**

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

''';

class UnnecessaryStatefulWidgets extends LintRule {
  UnnecessaryStatefulWidgets()
      : super(
          name: 'unnecessary_stateful_widgets',
          description: _desc,
          details: _details,
          group: Group.style,
          maturity: Maturity.experimental,
        );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    var visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final LintRule rule;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    var classes = node.declarations.whereType<ClassDeclaration>().toList();
    widgetLoop:
    for (var statefulWidget in classes
        .where((e) => isExactStatefulWidget(e.declaredElement2?.supertype))) {
      var createState = statefulWidget.members
          .whereType<MethodDeclaration>()
          .firstWhereOrNull((e) => e.name2.lexeme == 'createState');
      if (createState == null) continue;
      var createStateBody = createState.body;
      if (createStateBody is! ExpressionFunctionBody) continue;
      var stateElement = createStateBody.expression.staticType?.element2;
      if (stateElement is! ClassElement) continue;
      var stateName = stateElement.name;

      var stateDeclaration =
          classes.where((e) => e.name2.lexeme == stateName).singleOrNull;
      if (stateDeclaration == null) continue;
      if (stateDeclaration.withClause != null) continue;
      // check state is private
      if (stateDeclaration.declaredElement2?.isPublic ?? true) continue;
      // check `extends State`
      var extendsClause = stateDeclaration.extendsClause;
      if (extendsClause == null) continue;
      var parent = extendsClause.superclass.name.staticElement;
      if (parent is! ClassElement || !isExactState(parent)) continue;
      // check no field
      if (stateDeclaration.fields.isNotEmpty) continue;
      // check no overriden methods except `build`
      for (var method in stateDeclaration.methods) {
        if (method.name2.lexeme == 'build') continue;
        if (method.declaredElement2?.hasOverride ?? false) {
          continue widgetLoop;
        }
      }
      // check no `setState` usage
      var visitor = _StateUsageVisitor();
      stateDeclaration.accept(visitor);
      if (visitor.usedSetState) continue;

      rule.reportLintForToken(statefulWidget.name2);
    }
  }
}

class _StateUsageVisitor extends RecursiveAstVisitor<void> {
  bool usedSetState = false;
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.realTarget == null && node.methodName.name == 'setState') {
      usedSetState = true;
    }
    super.visitMethodInvocation(node);
  }
}

extension on ClassDeclaration {
  Iterable<FieldDeclaration> get fields =>
      members.whereType<FieldDeclaration>();
  Iterable<MethodDeclaration> get methods =>
      members.whereType<MethodDeclaration>();
}
