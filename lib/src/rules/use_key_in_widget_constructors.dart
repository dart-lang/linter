// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';
import '../util/flutter_utils.dart';

const _desc = r'Use key in widget constructors.';

const _details = r'''
**DO** use key in widget constructors.

It's a good pratice to expose the ability to provide a key when creating public
widgets.

**BAD:**
```
class MyPublicWidget extends StatelessWidget {
}
```

**GOOD:**
```
class MyPublicWidget extends StatelessWidget {
  MyPublicWidget({Key key}) : super(key: key);
}
```
''';

class UseKeyInWidgetConstructors extends LintRule implements NodeLintRule {
  UseKeyInWidgetConstructors()
      : super(
            name: 'use_key_in_widget_constructors',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var classElement = node.declaredElement;
    if (classElement.isPublic &&
        !classElement.isAbstract &&
        isWidget(classElement) &&
        classElement.constructors.where((e) => !e.isSynthetic).isEmpty) {
      rule.reportLint(node.name);
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    var constructorElement = node.declaredElement;
    var classElement = constructorElement.enclosingElement;
    if (constructorElement.isPublic &&
        !constructorElement.isFactory &&
        classElement.isPublic &&
        isWidget(classElement) &&
        !constructorElement.parameters
            .any((e) => e.name == 'key' && e.isNamed && _isKeyType(e.type)) &&
        !node.initializers.any((e) =>
            e is SuperConstructorInvocation &&
                e.argumentList.arguments.any((a) =>
                    a.staticParameterElement.name == 'key' &&
                    _isKeyType(a.staticType)) ||
            e is RedirectingConstructorInvocation &&
                e.argumentList.arguments.any((a) =>
                    a.staticParameterElement.name == 'key' &&
                    _isKeyType(a.staticType)))) {
      rule.reportLintForToken(node.firstTokenAfterCommentAndMetadata);
    }
    super.visitConstructorDeclaration(node);
  }

  bool _isKeyType(DartType type) =>
      DartTypeUtilities.implementsInterface(type, 'Key', '');
}
