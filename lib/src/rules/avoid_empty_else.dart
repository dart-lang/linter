// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Avoid empty else statements.';

const _details = r'''
**AVOID** empty else statements.

**BAD:**
```dart
if (x > y)
  print("1");
else ;
  print("2");
```

''';

class AvoidEmptyElse extends LintRule {
  static const LintCode code = LintCode('avoid_empty_else',
      "Empty statements are not allowed in an 'else' clause.",
      correctionMessage:
          'Try removing the empty statement or removing the else clause.');

  @override
  LintCode get lintCode => code;

  AvoidEmptyElse()
      : super(
            name: 'avoid_empty_else',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitIfStatement(IfStatement node) {
    var elseStatement = node.elseStatement;
    if (elseStatement is EmptyStatement &&
        !elseStatement.semicolon.isSynthetic) {
      rule.reportLint(elseStatement);
    }
  }
}
