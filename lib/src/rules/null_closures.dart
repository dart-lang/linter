// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.null_closures;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Do not pass `null` as an argument where a closure is expected.';

const _details = r'''

**DO NOT** pass null as an argument where a closure is expected.

Often a closure that is passed to a method will only be called conditionally,
so that tests and "happy path" production calls do not reveal that `null` will
result in an exception being thrown.

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
  void visitMethodInvocation(MethodInvocation node) {
    _checkNullArgForClosure(node);
    return;
  }

  void _checkNullArgForClosure(MethodInvocation node) {
    ArgumentList argumentList = node.argumentList;
    NodeList<Expression> args = argumentList.arguments;
    List<ParameterElement> params = argumentList.correspondingStaticParameters;
    if (params == null) {
      return;}
    for (int i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg is NamedExpression) {
        arg = arg.expression;
      }
      if (arg is NullLiteral) {
        // [name] is null when the type represents the type of an unnamed
        // function.
        // https://www.dartdocs.org/documentation/analyzer/latest/analyzer.dart.element.type/DartType/name.html
        if (params[i].type.name == null) {
          rule.reportLint(arg);
        }
      }
    }
  }
}
