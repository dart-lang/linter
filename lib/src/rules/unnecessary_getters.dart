// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../ast.dart';

const _desc =
    r'Prefer using a public final field instead of a private field with a public'
    r'getter.';

const _details = r'''

From the [style guide](https://dart.dev/guides/language/effective-dart/style/):

**PREFER** using a public final field instead of a private field with a public
getter.

If you have a field that outside code should be able to see but not assign to
(and you don't need to set it outside of the constructor), a simple solution
that works in many cases is to just mark it `final`.

**GOOD:**
```dart
class Box {
  final contents = [];
}
```

**BAD:**
```dart
class Box {
  var _contents;
  get contents => _contents;
}
```

''';

class UnnecessaryGetters extends LintRule {
  UnnecessaryGetters()
      : super(
            name: 'unnecessary_getters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var getters = <String, MethodDeclaration>{};
    var setters = <String, MethodDeclaration>{};

    // Filter on public methods
    var members = node.members.where(isPublicMethod);

    // Build getter/setter maps
    for (var member in members) {
      var method = member as MethodDeclaration;
      if (method.isGetter) {
        getters[method.name2.lexeme] = method;
      } else if (method.isSetter) {
        setters[method.name2.lexeme] = method;
      }
    }

    // Only select getters without setters
    var candidates = getters.keys.where((id) => !setters.keys.contains(id));
    candidates.map((n) => getters[n]).forEach(_visitGetter);
  }

  void _visitGetter(MethodDeclaration? getter) {
    if (getter != null && isSimpleGetter(getter)) {
      rule.reportLintForToken(getter.name2);
    }
  }
}
