// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/utils.dart';

const _desc = r'DO name import prefixes using lowercase_with_underscores.';

const _details = r'''
**DO** name import prefixes using lowercase_with_underscores.

**BAD:**
```
import 'dart:math' as Math;
import 'package:angular_components/angular_components'
    as angularComponents;
import 'package:js/js.dart' as JS;
```

**GOOD:**
```
import 'dart:math' as math;
import 'package:angular_components/angular_components'
    as angular_components;
import 'package:js/js.dart' as js;
```
''';

class ImportPrefixNames extends LintRule implements NodeLintRule {
  ImportPrefixNames()
      : super(
            name: 'import_prefix_names',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitImportDirective(ImportDirective node) {
    if (node.prefix != null && !isLowerCaseUnderScore(node.prefix.toString())) {
      rule.reportLint(node.prefix);
    }
  }
}
