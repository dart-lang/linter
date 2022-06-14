// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = 'No top public members in executable libraries.';

const _details = r'''

Top-level members in an executable library should be private (or relocated to
within main), to prevent unused members.

**BAD:**

```dart
main() {}
void f() {}
```

**GOOD:**

```dart
main() {}
void _f() {}
``

''';

class NoTopPublicMembersInExecutableLibraries extends LintRule {
  NoTopPublicMembersInExecutableLibraries()
      : super(
          name: 'no_top_public_members_in_executable_libraries',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    var visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final LintRule rule;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (!_isInsideExecutableLibrary(node)) return;
    for (var member in node.declarations) {
      if (member is FunctionDeclaration && member.name.name == 'main') continue;
      if (member is TopLevelVariableDeclaration) {
        member.variables.variables.forEach(_visitDeclaration);
      } else {
        _visitDeclaration(member);
      }
    }
  }

  void _visitDeclaration(Declaration node) {
    var element = node.declaredElement;
    if (element != null && element.isPublic && !element.hasVisibleForTesting) {
      rule.reportLint(node);
    }
  }

  bool _isInsideExecutableLibrary(AstNode node) {
    var root = node.root;
    if (root is! CompilationUnit) return false;
    var library = root.declaredElement?.library;
    return library != null &&
        library.exportNamespace.definedNames.containsKey('main');
  }
}
