// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = "Put spaces in wrapped strings on the beginning of new lines.";

const _details = '''

**DO** put your spaces between words in wrapped strings at the beginning of new
lines.

That means you should prefer '... foo' \\n ' bar' over '... foo ' \\n 'bar'.
This provides a few advantages:

- with this lint on, you can't accidentally do *both*.
- with this lint on, your project will at least be consistent in either way
- by preferring spaces at the beginning, it is easier for code reviewers to
  catch when they are missing entirely

Pretty much every exception to this is in raw strings, which is a solid
indicator of something that is not human text and does not conform to any
predictable spacing pattern.

**BAD:**
```
 'some amount of words that wrap around where the space is very '
 'easily missed'
```

**GOOD:**
```
 'some amount of words that wrap around where the space is very'
 ' easily recognized'
```

''';

class PreferStringSpacesAtBeginning extends LintRule {
  _Visitor _visitor;

  PreferStringSpacesAtBeginning()
      : super(
            name: 'prefer_string_spaces_at_beginning',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor<bool> {
  final LintRule rule;
  final Set<AstNode> visited = new HashSet<AstNode>();
  _Visitor(this.rule);

  bool isPlusOp(AstNode node) =>
      node is BinaryExpression && node.operator.lexeme == '+';

  @override
  bool visitAdjacentStrings(AdjacentStrings strings) {
    if (visited.contains(strings)) {
      return false;
    }

    visited.add(strings);

    strings.strings.getRange(0, strings.strings.length - 1).forEach((string) {
      string.accept(new _ReportIfEndsInSpace(this));
    });

    return true;
  }

  @override
  bool visitBinaryExpression(BinaryExpression expr) {
    if (!isPlusOp(expr)) {
      return false;
    }

    if (visited.contains(expr)) {
      return false;
    }

    visited.add(expr);

    // anything + notAString(), not concatted strings
    if (expr.rightOperand is! StringLiteral &&
        expr.rightOperand is! AdjacentStrings) {
      return false;
    }

    var leftOperand = expr.leftOperand;

    // 'a' + 'b', we've hit the depth of the concatenation, on the left side
    if (leftOperand is StringLiteral || leftOperand is AdjacentStrings) {
      // check A for trailing spaces
      leftOperand.accept(new _ReportIfEndsInSpace(this));
      // B is allowed to have them
      return true;
    }

    // use `== true`, because may be null, as in, not a concatenation
    if (leftOperand.accept(this) == true) {
      leftOperand.accept(new _ReportIfEndsInSpace(this));
      return true;
    }

    return false;
  }
}

class _ReportIfEndsInSpace extends SimpleAstVisitor {
  final _Visitor owningVisitor;
  _ReportIfEndsInSpace(this.owningVisitor);

  @override
  visitBinaryExpression(BinaryExpression expr) {
    expr.rightOperand.accept(this);
  }

  @override
  visitAdjacentStrings(AdjacentStrings strings) {
    strings.strings.last.accept(this);
  }

  @override
  visitSimpleStringLiteral(SimpleStringLiteral string) {
    if (!string.isRaw && string.value.endsWith(' ')) {
      owningVisitor.rule.reportLint(string);
    }
  }

  @override
  visitStringInterpolation(StringInterpolation string) {
    if (string.isRaw) {
      return;
    }

    final lastElem = string.elements.last;

    if (lastElem is InterpolationString && lastElem.value.endsWith(' ')) {
      owningVisitor.rule.reportLint(string);
    }
  }
}
