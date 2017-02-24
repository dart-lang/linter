// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.null_closures;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Do not pass `null` as an argument where a closure is expected.';

const _details = r'''

**DO NOT** pass null as an argument where a closure is expected.

Often a closure that is passed to a method will only be called conditionally,
so that tests and "happy path" production calls do not reveal that `null` will
result in an exception being thrown.

This rule only catches null literals being passed where closures are expected.

**BAD:**
```
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: null);
```

**GOOD:**
```
[1, 3, 5].firstWhere((e) => e.isOdd, orElse: () => null);
```

''';

class NullClosures extends LintRule {
  NullClosures()
      : super(
            name: 'null_closures',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  final LintRule rule;
  Visitor(this.rule);

  @override
  void visitArgumentList(ArgumentList node) {
    _checkNullArgForClosure(node);
    return;
  }

  void _checkNullArgForClosure(ArgumentList node) {
    NodeList<Expression> args = node.arguments;
    List<ParameterElement> params = node.correspondingStaticParameters;
    if (params == null) {
      return;
    }
    for (int i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg is NamedExpression) {
        arg = arg.expression;
      }
      if (arg is NullLiteral && params[i].type is FunctionType) {
        rule.reportLint(arg);
      }
    }
  }
}
