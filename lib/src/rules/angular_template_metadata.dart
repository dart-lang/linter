// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.angular_template_metadata;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/linter.dart';

const _desc =
    r'In `@Component` annotations specify one and only one of `template` and `templateUrl`.';

const _details = r'''

**DO NOT** Annontate an angular component without specifying any of `template` or `templateUrl` also do not specify both.

**BAD:**
```
@Component(templateUrl: 'someUrl', template: '<some-node></some-node>') // LINT
class TemplateAndTemplateUrlComponent { ... }
```

**BAD:**
```
@Component() // LINT
class Component { ... }
```

**GOOD:**
```
@Component(templateUrl: 'someUrl')
class TemplateUrlComponent { ... }
```

**GOOD:**
```
@Component(template: '<some-node> ... </some-node>')
class TemplateComponent { ... }
```
''';

class AngularTemplateMetadata extends LintRule {
  _Visitor _visitor;

  AngularTemplateMetadata()
      : super(
            name: 'angular_template_metadata',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  void visitAnnotation(Annotation node) {
    if (node.element is! ConstructorElement) {
      return;
    }

    ConstructorElement constructorElement = node.element;
    if (node == null ||
        node.name.name != 'Component' ||
        node.parent is! ClassDeclaration ||
        node.atSign == null ||
        node.element is! ConstructorElement ||
        !constructorElement.isConst ||
        !constructorElement.location.components
            .contains('package:angular2/src/core/metadata.dart') ||
        node.arguments.arguments.any((a) =>
                a is NamedExpression && a.name.label.name == 'templateUrl') !=
            node.arguments.arguments.any((a) =>
                a is NamedExpression && a.name.label.name == 'template')) {
      return;
    }

    rule.reportLint(node);
  }
}
