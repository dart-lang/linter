// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.unnecessary_this;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/environment_visitors.dart';

const _desc = r'Don’t use this. when not needed to avoid shadowing.';

const _details = r'''

**DON’T** use this. when not needed to avoid shadowing.

**BAD:**
```
class Box {
  var value;

  void update(new_value) {
    this.value = new_value;
  }
}
```

**GOOD:**
```
class Box {
  var value;

  void update(new_value) {
    value = new_value;
  }
}
```

**GOOD:**
```
class Box {
  var value;

  void update(value) {
    this.value = value;
  }
}
```

''';

class UnnecessaryThis extends LintRule {
  _Visitor _visitor;
  UnnecessaryThis()
      : super(
            name: 'unnecessary_this',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor.getVisitor();
}

class _Visitor extends LookUpVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitThisExpression(ThisExpression node) {
    final parent = node.parent;
    if (parent is PropertyAccess) {
      Element element = parent.propertyName?.name != null
          ? lookUp(parent.propertyName.name)
          : null;
      final localAccessor = parent.propertyName.bestElement;
      if (localAccessor is PropertyAccessorElement &&
          element == localAccessor.variable) {
        rule.reportLint(parent);
      }
    } else if (parent is MethodInvocation) {
      Element element = parent.methodName?.name != null
          ? lookUp(parent.methodName.name)
          : null;
      final localAccessor = parent.methodName.bestElement;
      if (localAccessor is MethodElement && element == localAccessor) {
        rule.reportLint(parent);
      }
    }
  }
}
