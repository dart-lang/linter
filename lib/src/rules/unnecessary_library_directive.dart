// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _name = 'unnecessary_library_directive';

const _desc =
    'Avoid library directives unless that have documentation comments or '
    'annotations.';

const _details = r'''
**DO** use library directives if you want to document a library and/or annotate 
a library.

**GOOD:**
```dart
/// This library does important things
library;
```

```dart
@TestOn('js')
library;
```

**BAD:**
```dart
library;
```
''';

class UnnecessaryLibraryDirective extends LintRule {
  static const LintCode code = LintCode(
    _name,
    'Library directives without comments or annotations should be avoided.',
    correctionMessage: 'Try deleting the library directive.',
  );

  UnnecessaryLibraryDirective()
      : super(
          name: _name,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    var visitor = _Visitor(this);
    registry.addLibraryDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitLibraryDirective(LibraryDirective node) {
    if (node.sortedCommentAndAnnotations.isEmpty) {
      rule.reportLint(node);
    }
  }
}
