// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid function type aliases.';

const _details = r'''

**AVOID** function type aliases.

**BAD:**
```
typedef void F();
```

**GOOD:**
```
typedef F = void Function();
```

''';

class AvoidFunctionTypeAliases extends LintRule {
  AvoidFunctionTypeAliases()
      : super(
            name: 'avoid_function_type_aliases',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  Visitor(this.rule);

  final LintRule rule;

  @override
  visitFunctionTypeAlias(FunctionTypeAlias node) {
    rule.reportLint(node);
  }
}
