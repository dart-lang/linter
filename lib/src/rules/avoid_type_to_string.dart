// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r'Avoid <Type>.toString() in production code since results may be minified.';

const _details = r'''

**DO** avoid calls to <Type>.toString() in production code, since it does not
contractually return the user-defined name of the Type (or underlying class).
Development-mode compilers where code size is not a concern use the full name,
but release-mode compilers often choose to minify these symbols.

**BAD:**
```
void bar(Object other) {
  if (other.runtimeType.toString() == 'Bar') {
    doThing();
  }
}

Object baz(Thing myThing) {
  return getThingFromDatabase(key: myThing.runtimeType.toString());
}
```

**GOOD:**
```
void bar(Object other) {
  if (other is Bar) {
    doThing();
  }
}

class Thing {
  String get thingTypeKey => ...
}

Object baz(Thing myThing) {
  return getThingFromDatabase(key: myThing.thingTypeKey);
}
```

''';

// TODO: handle local toString lambda declared in scope
class AvoidTypeToString extends LintRule implements NodeLintRule {
  AvoidTypeToString() 
      : super(
            name: 'avoid_type_to_string',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry, [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
    registry.addMixinDeclaration(this, visitor);
    registry.addExtensionDeclaration(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  InterfaceType thisType;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Nodes visited in DFS, so this will be set before each visitMethodInvocation.
    thisType = node.declaredElement.thisType;
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    // Nodes visited in DFS, so this will be set before each visitMethodInvocation.
    thisType = node.declaredElement.thisType;
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    // Nodes visited in DFS, so this will be set before each visitMethodInvocation.
    thisType = node.declaredElement.extendedType as InterfaceType;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    final targetType = (node.realTarget?.staticType is InterfaceType)
        ?  node.realTarget.staticType as InterfaceType : thisType;
    final library = node.methodName.staticElement?.library;
    if (_isToStringOnCoreTypeClass(methodName, targetType, library)) {
      rule.reportLint(node);
    }

    node.argumentList.arguments.forEach(_validateArgument);
  }

  void _validateArgument(Expression expression) {
    String methodName;
    InterfaceType targetType;
    LibraryElement library;
    if (expression is PropertyAccess) {
      methodName = expression.propertyName.name;
      targetType = (expression.realTarget?.staticType is InterfaceType) 
          ? expression.realTarget?.staticType as InterfaceType : thisType;
      library = expression.propertyName.staticElement?.library;
    }
    else if (expression is SimpleIdentifier) {
      methodName = expression.name;
      targetType = thisType;
      library = expression.staticElement?.library;
    }
    else {
      return;
    }
    
    if (_isToStringOnCoreTypeClass(methodName, targetType, library)) {
      rule.reportLint(expression);
    }
  }

  bool _isToStringOnCoreTypeClass(String methodName, InterfaceType targetType, LibraryElement library) =>
      methodName == 'toString'
      && _coreTypeClassInAncestors(targetType)
      && _rootMethodIsCoreToString(targetType, library);

  bool _coreTypeClassInAncestors(InterfaceType targetType) {
    for (final iType in [targetType].followedBy(targetType.allSupertypes)) {
      if (iType.element?.name == 'Type' && iType.element?.library?.isDartCore == true) {
        return true;
      }
    }
    return false;
  }

  bool _rootMethodIsCoreToString(InterfaceType targetType, LibraryElement library) {
    final rootMethod = targetType.lookUpMethod2('toString', library);
    return rootMethod.library?.isDartCore == true
        && rootMethod.enclosingElement?.name == 'Object';
  }
}
