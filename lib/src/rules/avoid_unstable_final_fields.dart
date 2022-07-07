// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'';

const _details = r'''

**DO** ...

**BAD:**
```dart

```

**GOOD:**
```dart

```

''';

class AvoidUnstableFinalFields extends LintRule {
  AvoidUnstableFinalFields()
      : super(
            name: 'avoid_unstable_final_fields',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addSimpleIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // TODO: implement
  }
}
