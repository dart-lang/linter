// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = 'Unreachable top-level members in executable libraries.';

const _details = r'''

Top-level members in an executable library should be used directly inside this
library.  Executable libraries are usually never imported and it's better to
avoid defining unused members.

This rule assumes that an executable library isn't imported by other files
except to execute its `main` function.

**BAD:**

```dart
main() {}
void f() {}
```

**GOOD:**

```dart
main() {
  f();
}
void f() {}
```

''';

class UnreachableFromMain extends LintRule {
  UnreachableFromMain()
      : super(
          name: 'unreachable_from_main',
          description: _desc,
          details: _details,
          group: Group.style,
          maturity: Maturity.experimental,
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
    // TODO(a14n): add support of libs with parts
    if (node.directives.whereType<PartOfDirective>().isNotEmpty) return;
    if (node.directives.whereType<PartDirective>().isNotEmpty) return;

    var topDeclarations = node.declarations
        .expand((e) => [
              if (e is TopLevelVariableDeclaration)
                ...e.variables.variables
              else
                e,
            ])
        .toSet();

    var entryPoints = topDeclarations.where(_isEntryPoint).toList();
    if (entryPoints.isEmpty) return;

    var declarationByElement = <Element, Declaration>{};
    for (var declaration in topDeclarations) {
      var element = declaration.declaredElement;
      if (element != null) {
        if (element is TopLevelVariableElement) {
          declarationByElement[element] = declaration;
          var getter = element.getter;
          if (getter != null) declarationByElement[getter] = declaration;
          var setter = element.setter;
          if (setter != null) declarationByElement[setter] = declaration;
        } else {
          declarationByElement[element] = declaration;
        }
      }
    }

    var dependencies = Map<Declaration, Set<Declaration>>.fromIterable(
      topDeclarations,
      value: (declaration) =>
          DartTypeUtilities.traverseNodesInDFS(declaration as Declaration)
              .expand((e) => [
                    if (e is SimpleIdentifier) e.staticElement,
                    // with `id++` staticElement of `id` is null
                    if (e is CompoundAssignmentExpression) ...[
                      e.readElement,
                      e.writeElement,
                    ],
                  ])
              .whereNotNull()
              .map((e) {
                while (e.enclosingElement2 != null &&
                    e.enclosingElement2 is! CompilationUnitElement) {
                  e = e.enclosingElement2!;
                }
                return e;
              })
              .map((e) => declarationByElement[e])
              .whereNotNull()
              .where((e) => e != declaration)
              .toSet(),
    );

    var usedMembers = entryPoints.toSet();
    var toTraverse = Queue.from(usedMembers);
    while (toTraverse.isNotEmpty) {
      var declaration = toTraverse.removeLast();
      for (var dep in dependencies[declaration]!) {
        if (usedMembers.add(dep)) {
          toTraverse.add(dep);
        }
      }
    }

    var unusedMembers = topDeclarations.difference(usedMembers).where((e) {
      var element = e.declaredElement;
      return element != null &&
          element.isPublic &&
          !element.hasVisibleForTesting;
    });
    unusedMembers.forEach(rule.reportLint);
  }

  bool _isEntryPoint(Declaration e) =>
      e is FunctionDeclaration &&
      (e.name.name == 'main' || e.metadata.any(_isPragmaVmEntry));

  bool _isPragmaVmEntry(Annotation annotation) {
    var elementAnnotation = annotation.elementAnnotation;
    if (elementAnnotation != null) {
      var value = elementAnnotation.computeConstantValue();
      if (value != null) {
        var type = value.type;
        if (type != null) {
          var element = type.element;
          if (element != null) {
            var library = element.library;
            if (library != null && library.isDartCore ||
                element.name == 'pragma') {
              var name = value.getField('name');
              return name != null &&
                  name.hasKnownValue &&
                  name.toStringValue() == 'vm:entry-point';
            }
          }
        }
      }
    }
    return false;
  }
}
