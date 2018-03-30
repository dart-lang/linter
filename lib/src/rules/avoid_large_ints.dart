// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid large integers.';

const _details = r'''

**AVOID** too large integers.

When a program is compiled to javascript `int` and `double` become JS Numbers.
Too large integers (`value < Number.MIN_SAFE_INTEGER` or
`value > Number.MAX_SAFE_INTEGER`) will be rounded to the closest Number value.

**BAD:**
```
int value = 9007199254740995;
```

**GOOD:**
```
BigInt value = BigInt.parse('9007199254740995');
```

''';

class AvoidLargeInts extends LintRule {
  AvoidLargeInts()
      : super(
            name: 'avoid_large_ints',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  Visitor(this.rule);

  final LintRule rule;

  @override
  visitIntegerLiteral(IntegerLiteral node) {
    if (node.value > 9007199254740991 || node.value < -9007199254740991) {
      rule.reportLint(node);
    }
  }
}
