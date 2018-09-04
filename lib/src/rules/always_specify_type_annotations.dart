// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/utils.dart';

const _desc = r'Specify type annotations.';

const _details = r'''

**DO** specify type annotations.

**GOOD:**
```
int foo = 10;
final Bar bar = new Bar();
String baz = 'hello';
const int quux = 20;
```

**BAD:**
```
var foo = 10;
final bar = new Bar();
const quux = 20;
```
''';

class AlwaysSpecifyTypeAnnotations extends LintRule implements NodeLintRule {
  AlwaysSpecifyTypeAnnotations()
      : super(
            name: 'always_specify_type_annotations',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addDeclaredIdentifier(this, visitor);
    registry.addSimpleFormalParameter(this, visitor);
    registry.addVariableDeclarationList(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    if (node.type == null) {
      rule.reportLintForToken(node.keyword);
    }
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter param) {
    if (param.type == null &&
        param.identifier != null &&
        !isJustUnderscores(param.identifier.name)) {
      if (param.keyword != null) {
        rule.reportLintForToken(param.keyword);
      } else {
        rule.reportLint(param);
      }
    }
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList list) {
    if (list.type == null) {
      rule.reportLintForToken(list.keyword);
    }
  }
}
