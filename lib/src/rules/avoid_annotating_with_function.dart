// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.avoid_annotating_parameters_with_function;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Avoid annotating parameters with Function.';

const _details = r'''

**AVOID** annotating parameters with Function.

**BAD:**
```
bool isValidString(String value, Function predicate) {
  ...
}
```

**GOOD:**
```
bool isValidString(String value, bool predicate(String string)) {
  ...
}
```

''';

SimpleIdentifier _getIdentifier(FormalParameter node) => node.identifier;

bool _isFunction(FormalParameter node) =>
    DartTypeUtilities.isClass(node.element.type, 'Function', 'dart.core');

class AvoidAnnotatingWithFunction extends LintRule {
  _Visitor _visitor;
  AvoidAnnotatingWithFunction()
      : super(
            name: 'avoid_annotating_with_function',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitFunctionExpression(FunctionExpression node) {
    final functionParameters = node.parameters.parameters
        .where(_isFunction)
        .map(_getIdentifier)
        .map(DartTypeUtilities.getCanonicalElementFromIdentifier);

  }
}
