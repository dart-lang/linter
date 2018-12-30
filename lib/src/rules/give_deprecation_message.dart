// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Give a deprecation message, via `Deprecation("message")`.';

const _details = r'''

**DO** specify a deprecation message (with migration instructions and/or a
removal schedule) in the Deprecation constructor.

**BAD:**
```
@deprecated
void oldFunction(arg1, arg2) {}
```

**GOOD:**
```
@Deprecated("""
[oldFunction] is being deprecated in favor of [newFunction] (with slightly
different parameters; see [newFunction] for more information). [oldFunction]
will be removed on or after the 4.0.0 release.
""")
void oldFunction(arg1, arg2) {}
```

''';

class GiveDeprecationMessage extends LintRule implements NodeLintRule {
  GiveDeprecationMessage()
      : super(
            name: 'give_deprecation_message',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = new _Visitor(this);
    registry.addAnnotation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitAnnotation(Annotation node) {
    if (node.elementAnnotation.isDeprecated && node.arguments == null)
          rule.reportLint(node);
  }
}
