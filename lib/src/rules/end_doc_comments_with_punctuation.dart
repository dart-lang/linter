// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const Set<String> _allowedEndings = {'.', '?', '!'};
const String _endingsConcat = '".", "?", or "!"';

const _desc =
    'DO end documentation comment blocks with terminating punctuation: $_endingsConcat.';

const _details = '''

**DO** end all documentation comment blocks with one of the following: $_endingsConcat

**BAD:**
```
/// This sentence doesn't have any terminating punctuation at the end
void a() => null;

/// This is a long documentation comment composed of multiple sentences.
/// However, it looks like we forgot to terminate the last one, which is bad
void b() => null;
```

**GOOD:**
```
/// This sentence is properly terminated with a period.
void c() => null;

/// This is a very long sentence spread across multiple lines of a documentation
/// comment, but it still ends with terminating punctuation!
void d() => null;

/// A question mark works too, would you like to see?
void e() => null;
```

''';

class EndDocCommentsWithPunctuation extends LintRule implements NodeLintRule {
  EndDocCommentsWithPunctuation()
      : super(
            name: 'end_doc_comments_with_punctuation',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addComment(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitComment(Comment node) {
    var comment = node.endToken.lexeme;
    if (comment.startsWith('/**') && comment.endsWith('*/')) {
      comment = comment.substring(0, comment.length - 2);
      comment = comment.trimRight();
    }

    final endChar = comment[comment.length - 1];
    if (!_allowedEndings.contains(endChar)) {
      rule.reportLintForOffset(node.endToken.charOffset + comment.length, 1);
    }
  }
}
