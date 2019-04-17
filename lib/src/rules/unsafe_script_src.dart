// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Avoid unsafe ScriptElement src=.';

const _details = r'''

**AVOID** assigning directly to the src field of a ScriptElement.


**BAD:**
```
var script = ScriptElement()..src = 'foo.js';
```
''';

class UnsafeScriptSrc extends LintRule implements NodeLintRule {
  UnsafeScriptSrc()
      : super(
            name: 'unsafe_script_src',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = new _Visitor(this);
    registry.addPropertyAccess(this, visitor);
    registry.addAssignmentExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    final parent = node.parent;
    final leftPart = node.leftHandSide.unParenthesized;
    if (parent is CascadeExpression) {
      _checkAssignment(
          parent.target, (leftPart as PropertyAccess).propertyName, node);
    } else if (leftPart is PropertyAccess) {
      _checkAssignment(leftPart.target, leftPart.propertyName, node);
    } else if (leftPart is PrefixedIdentifier) {
      _checkAssignment(leftPart.prefix, leftPart.identifier, node);
    }
  }

  void _checkAssignment(Expression target, SimpleIdentifier property,
      AssignmentExpression assignment) {
    DartType type = target?.staticType;
    // It is more efficient to first check if `src` is being assigned, _then_
    // check if the target is ScriptElement or dynamic.
    if (property?.name == 'src') {
      if (DartTypeUtilities.extendsClass(
              type, 'ScriptElement', 'dart.dom.html') ||
          type.isDynamic) {
        rule.reportLint(assignment);
      }
    }
  }
}
