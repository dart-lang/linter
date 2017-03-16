// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.unnecessary_this;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';
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
  AstVisitor getVisitor() => _visitor.mainCallVisitor;
}

class _Visitor extends ElementScopeVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitThisExpression(ThisExpression node) {
    final parent = node.parent;
    if (parent is PropertyAccess) {
      Element element = parent.propertyName?.name != null
          ? lookUp(parent.propertyName.name)
          : null;
      final localElement =
          DartTypeUtilities.getCanonicalElement(parent.propertyName.bestElement);
      if (element == localElement) {
        rule.reportLint(parent);
      }
    } else if (parent is MethodInvocation) {
      Element element = parent.methodName?.name != null
          ? lookUp(parent.methodName.name)
          : null;
      final localElement = parent.methodName.bestElement;
      if (localElement is MethodElement && element == localElement) {
        rule.reportLint(parent);
      }
    }
  }
}
