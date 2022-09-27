// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import '../analyzer.dart';
import '../extensions.dart';
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
        .where((e) => isExactStatefulWidget(e.declaredElement?.supertype))) {
      // if Stateful is used in name, we ignore it
      if (statefulWidget.name.lexeme.contains('Stateful')) continue;

      var createState = statefulWidget.members
          .whereType<MethodDeclaration>()
          .firstWhereOrNull((e) => e.name.lexeme == 'createState');
      if (createState == null) continue;
      var createStateBody = createState.body;
      if (createStateBody is! ExpressionFunctionBody) continue;
      var stateElement = createStateBody.expression.staticType?.element2;
      if (stateElement is! ClassElement) continue;
      var stateName = stateElement.name;

      var stateDeclaration =
          classes.where((e) => e.name.lexeme == stateName).singleOrNull;
      if (stateDeclaration == null) continue;
      if (stateDeclaration.withClause != null) continue;
      // check state is private
      if (stateDeclaration.declaredElement?.isPublic ?? true) continue;
      // check `extends State`
      var extendsClause = stateDeclaration.extendsClause;
      if (extendsClause == null) continue;
      var parent = extendsClause.superclass.name.staticElement;
      if (parent is! ClassElement || !isExactState(parent)) continue;
      // check no field
      if (stateDeclaration.fields.isNotEmpty) continue;
      // check no overriden methods except `build`
      for (var method in stateDeclaration.methods) {
        if (method.name.lexeme == 'build') continue;
        if (method.declaredElement?.hasOverride ?? false) {
          continue widgetLoop;
        }
      }
      // check no `State` usage
      var visitor = _StateUsageVisitor();
      stateDeclaration.accept(visitor);
      if (visitor.hasStateUsage) continue;

      rule.reportLintForToken(statefulWidget.name);
    }
  }
}

class _StateUsageVisitor extends RecursiveAstVisitor<void> {
  bool hasStateUsage = false;

  late ClassElement _stateElement;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var stateElement = node.declaredElement;
    if (stateElement == null) return;
    _stateElement = stateElement;
    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!_visit(node.canonicalElement)) {
      super.visitMethodInvocation(node);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'widget' || !_visit(node.canonicalElement)) {
      super.visitSimpleIdentifier(node);
    }
  }

  bool _visit(Element? methodElement) {
    if (methodElement is ClassMemberElement &&
        _stateElement.allSupertypes
            .whereNot((type) => type == _stateElement.thisType)
            .any((type) => type.element2 == methodElement.enclosingElement3)) {
      hasStateUsage = true;
      return true;
    }
    return false;
  }
}

extension on ClassDeclaration {
  Iterable<FieldDeclaration> get fields =>
      members.whereType<FieldDeclaration>();
  Iterable<MethodDeclaration> get methods =>
      members.whereType<MethodDeclaration>();
}
