// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as path;

import '../analyzer.dart';
import '../ast.dart';
import '../rules/implementation_imports.dart';

const _desc = r'Prefer relative imports for files in `lib/`.';

const _details = r'''Prefer relative imports for files in `lib/`.

When mixing relative and absolute imports it's possible to create confusion
where the same member gets imported in two different ways. One way to avoid
that is to ensure you consistently use relative imports for files withing the
`lib/` directory.

**GOOD:**

```
import 'bar.dart';
```

**BAD:**

```
import 'package:my_package/bar.dart';
```

''';

class PreferRelativeImports extends LintRule implements NodeLintRule {
  PreferRelativeImports()
      : super(
            name: 'prefer_relative_imports',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferRelativeImports rule;
  final LinterContext context;

  bool isInLibFolder;

  _Visitor(this.rule, this.context);

  bool isPackageSelfReference(ImportDirective node) {
    // Ignore this compilation unit if it's not in the lib/ folder.
    if (!isInLibFolder) return false;

    // Is it a package: import?
    String importUri = node?.uri?.stringValue;
    if (importUri == null) return false;

    // todo (pq): is there a better way to do this?
    Uri uri;
    try {
      uri = Uri.parse(importUri);
      if (!isPackage(uri)) return false;
    } on FormatException catch (_) {
      return false;
    }

    final source = node.uriElement?.library?.source;
    if (source == null) return false;
    // todo (pq): should context.package.contains(source)work?
    return path.isWithin(context.package.root, source.fullName);
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    isInLibFolder = isInLibDir(node, context.package);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    if (isPackageSelfReference(node)) {
      rule.reportLint(node.uri);
    }
  }
}
