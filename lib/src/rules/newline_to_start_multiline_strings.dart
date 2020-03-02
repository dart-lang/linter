// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Start multiline strings with a newline.';

const _details = r'''

Multiline strings are easier to read when they start with a newline (a newline
starting a multiline string is ignored).

**BAD:**
```
var s1 = """{
  "a": 1,
  "b": 2
}""";
```

**GOOD:**
```
var s1 = """
{
  "a": 1,
  "b": 2
}""";

var s2 = """This onliner multiline string is ok. It usually allows to escape both ' and " in the string.""";
```

''';

class NewlineToStartMultilineStrings extends LintRule implements NodeLintRule {
  NewlineToStartMultilineStrings()
      : super(
            name: 'newline_to_start_multiline_strings',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  _Visitor(this.rule);

  final LintRule rule;

  LineInfo lineInfo;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    lineInfo = node.lineInfo;
    super.visitCompilationUnit(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _visitSingleStringLiteral(node, node.literal.lexeme);
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _visitSingleStringLiteral(
        node, (node.elements.first as InterpolationString).contents.lexeme);
    super.visitStringInterpolation(node);
  }

  void _visitSingleStringLiteral(SingleStringLiteral node, String lexeme) {
    if (node.isMultiline &&
        lineInfo.getLocation(node.offset).lineNumber !=
            lineInfo.getLocation(node.end).lineNumber) {
      var index = 3;
      if (node.isRaw) index += 1;
      if (['\n', '\r'].every((e) => e != lexeme[index])) {
        rule.reportLint(node);
      }
    }
  }
}
