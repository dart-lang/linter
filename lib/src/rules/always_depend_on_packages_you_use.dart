// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../ast.dart';

const _desc = r'Depend on packages you use.';

const _details = r'''

**DO** depend on packages you use.

When importing a package, *always* add a dependency on it to your pubspec.

Depending explicitly on packages that you use ensures they will always exist
and allows you to put a dependency constraint on them to guard you against
breaking changes.

Whether this should be a regular dependency or dev_dependency depends on if it
is imported from a public file (one under either `lib` or `bin`), or some other
file.

**BAD:**
```dart
import 'package:a/a.dart';
```

```yaml
dependencies:
```

**GOOD:**
```dart
import 'package:a/a.dart';
```

```yaml
dependencies:
  a: ^1.0.0
```

''';

class AlwaysDependOnPackagesYouUse extends LintRule implements NodeLintRule {
  AlwaysDependOnPackagesYouUse()
      : super(
            name: 'always_depend_on_packages_you_use',
            description: _desc,
            details: _details,
            group: Group.pub);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    // Only lint if we have a pubspec.
    var package = context.package;
    if (package is! PubWorkspacePackage) return;
    var pubspec = package.pubspec;
    if (pubspec == null) return;

    var dependencies = pubspec.dependencies;
    var devDependencies = pubspec.devDependencies;
    var availableDeps = [
      if (dependencies != null)
        for (var dep in dependencies)
          if (dep.name?.text != null) dep.name!.text!,
      if (devDependencies != null &&
          !isInPublicDir(context.currentUnit.unit, context.package))
        for (var dep in devDependencies)
          if (dep.name?.text != null) dep.name!.text!,
    ];

    var visitor = _Visitor(this, context, availableDeps);
    registry.addImportDirective(this, visitor);
    registry.addExportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final AlwaysDependOnPackagesYouUse rule;
  final LinterContext context;
  final List<String> availableDeps;

  _Visitor(this.rule, this.context, this.availableDeps);

  void _checkDirective(UriBasedDirective node) {
    // Is it a package: uri?
    var uriContent = node.uriContent;
    if (uriContent == null) return;
    if (!uriContent.startsWith('package:')) return;

    try {
      var firstSlash = uriContent.indexOf('/');
      var packageName = uriContent.substring(8, firstSlash);
      if (availableDeps.contains(packageName)) return;
      rule.reportLint(node.uri);
    } on FormatException catch (_) {}
  }

  @override
  void visitImportDirective(ImportDirective node) => _checkDirective(node);

  @override
  void visitExportDirective(ExportDirective node) => _checkDirective(node);
}
