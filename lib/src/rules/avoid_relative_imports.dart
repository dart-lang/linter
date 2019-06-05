// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid relative imports for all files`.';

const _details = r'''*DO* avoid relative imports for files in `lib/`.

Mixing relative and absolute imports makes it complicated to refactor across
multiple packages.

This is a more strict version of 'avoid_relative_lib_imports'.

**GOOD:**

```
import 'package:foo/bar.dart';

import 'package:foo/baz.dart';

import 'package:foo/src/baz.dart';
...
```

**BAD:**

```
import 'baz.dart';

import 'src/bag.dart'

import '../lib/baz.dart';

...
```

''';

class AvoidRelativeImports extends LintRule implements NodeLintRule {
  AvoidRelativeImports()
      : super(
            name: 'avoid_relative_imports',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = new _Visitor(this);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  bool isRelativeImport(ImportDirective node) {
    try {
      Uri uri = Uri.parse(node.uriContent);
      return uri.scheme.isEmpty;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Ignore.
    }
    return false;
  }

  @override
  void visitImportDirective(ImportDirective node) {
    if (isRelativeImport(node)) {
      rule.reportLint(node.uri);
    }
  }
}
