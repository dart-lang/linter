// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc =
    r"Prefer relative paths when importing libraries within your own package's lib directory.";

const _details = r'''

When referencing a library inside your package’s `lib` directory from another library in that same package, prefer use relative URI.

For example, say your directory structure looks like:

```
my_package
└─ lib
   ├─ src
   │  └─ utils.dart
   └─ api.dart
```

If `api.dart` wants to import utils.dart:

**GOOD:**
```
import 'src/utils.dart';
```

**BAD:**
```
import 'package:my_package/src/utils.dart';
```

''';

bool isPackage(Uri uri) => uri?.scheme == 'package';

bool isProjectLibrary({Uri libraryUri, String projectName}) {
  var segments = libraryUri.pathSegments;
  if (segments.isEmpty) {
    return false;
  }
  return segments[0] == projectName;
}

class PreferRelativeImports extends LintRule
    implements ProjectVisitor, NodeLintRule {
  DartProject project;

  PreferRelativeImports()
      : super(
            name: 'prefer_relative_imports',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  visit(DartProject project) {
    this.project = project;
  }

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferRelativeImports rule;

  _Visitor(this.rule);

  DartProject get project => rule.project;

  @override
  void visitImportDirective(ImportDirective node) {
    Uri importUri = node?.uriSource?.uri;

    // If the import URI is not a `package` URI bail out.
    if (!isPackage(importUri)) {
      return;
    }

    if (isProjectLibrary(libraryUri: importUri, projectName: project.name)) {
      rule.reportLint(node.uri);
    }
  }
}
