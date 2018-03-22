// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid keyword to create instances.';

const _details = r'''

**AVOID** keyword to create instances. Use `new` only to force new instance when
a const could have been used.

**BAD:**
```
class A() { const A(); }
m(){
  const a = const A();
  final b = new A();
}
```

**GOOD:**
```
class A() { const A(); }
m(){
  const a = A(); // same as: const A();
  final b = A(); // same as: new A();
}
```

''';

class AvoidKeywordToCreateInstances extends LintRule implements NodeLintRule {
  AvoidKeywordToCreateInstances()
      : super(
            name: 'avoid_keyword_to_create_instances',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.keyword == null) return;

    // remove keyword and check if there's const error
    final oldKeyword = node.keyword;
    node.keyword = null;
    final isConstWithoutKeyword = node.isConst;
    node.keyword = oldKeyword;

    if (isConstWithoutKeyword && node.keyword.type == Keyword.CONST ||
        !isConstWithoutKeyword && node.keyword.type == Keyword.NEW) {
      rule.reportLint(node);
    }
  }
}
