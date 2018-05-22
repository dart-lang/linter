// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/flutter.dart';

const _desc = r'Avoid using final fields of @immutable type in Flutter State.';

const _details = r'''

**AVOID** using final fields of @immutable type in Flutter State.

When the field is final, and it has the type which is marked as @immutable,
so neither the reference, nor the referenced object changes, it is a good
signal that this field does not belong to a State.  Moreover, Dart VM can
hot reload only constant fields, and during hot reload State object instances
are often kept the same, so thier final fields are not reinitialized.  OTOH,
widgets are rebuilt, so their final fields are reinitialized.  Ideally values
that don't ever change, e.g. styling related, should be constants, but this is
not always possible.

**BAD:**
```
import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  @override
  MyWidgetState createState() {
    return new MyWidgetState();
  }
}

class MyWidgetState extends State<MyWidget> {
  final biggerFont = TextStyle(fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return new Text('Text', style: biggerFont);
  }
}
```

**GOOD:**
```
import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  final biggerFont = TextStyle(fontSize: 20.0);

  @override
  MyWidgetState createState() {
    return new MyWidgetState();
  }
}

class MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return new Text('Text', style: widget.biggerFont);
  }
}
```

''';

bool _isImmutable(DartType type) =>
    type is InterfaceType && type.element.metadata.any((a) => a.isImmutable);

class AvoidFinalImmutableInFlutterState extends LintRule
    implements NodeLintRule {
  AvoidFinalImmutableInFlutterState()
      : super(
            name: 'avoid_final_immutable_in_flutter_state',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (!node.fields.isFinal) return;

    ClassDeclaration enclosingClass = node.parent;
    if (!isState(enclosingClass.element)) return;

    for (var field in node.fields.variables) {
      var initializer = field.initializer;
      if (initializer == null) continue;

      DartType type = field.element.type;
      if (_isImmutable(type)) {
        rule.reportLint(field);
      }
    }
  }
}
