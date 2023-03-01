// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r"Don't implicitly reopen classes or mixins";

/// todo(pq): link out to (upcoming) dart.dev docs.
const _details = r'''
Using the `interface`, `final`, `base`, `mixin`, and `sealed` class modifiers,
authors can control whether classes and mixins allow being implemented,
extended, and/or mixed in from outside of the library where they're defined.
In some cases, it's possible for an author to inadvertantly relax these controls
and implicitly "reopen" a class or mixin. 

This lint guards against unintentionally reopening a type by requiring such
cases to be made explicit with the 
[`@reopen`](https://pub.dev/documentation/meta/latest/meta/reopen-constant.html)
annotation in `package:meta`.

**BAD:**
```dart
interface class I {}

class C extends I {}
```

**GOOD:**
```dart
interface class I {}

final class C extends I {}
```

```dart
import 'package:meta/meta.dart';

interface class I {}

@reopen
class C extends I {}
```
''';

class ImplicitReopen extends LintRule {
  static const LintCode code = LintCode('implicit_reopen',
      "The class '{0}' reopens '{1}' because it is not marked '{2}'",
      correctionMessage:
          "Try marking '{0}' '{2}' or annotating it with '@reopen'");

  ImplicitReopen()
      : super(
            name: 'implicit_reopen',
            description: _desc,
            details: _details,
            state: State.experimental(),
            group: Group.errors);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  void reportLint(
    NamedCompilationUnitMember member, {
    required InterfaceElement target,
    required InterfaceElement other,
    required String reason,
  }) {
    rule.reportLintForToken(member.name,
        arguments: [target.name, other.name, reason]);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var classElement = node.declaredElement;
    if (classElement == null) return;
    if (classElement.hasReopen) return;

    var library = classElement.library;

    // | subtype          |  supertype   | `extends`/`with` |
    // | _none_ or `base` |  `interface` | lint             |
    // | `base`           |  `final`     | lint             |
    if (classElement.hasNoModifiers || classElement.isBase) {
      var supertype = classElement.superElement;
      if (supertype.library == library) {
        if (supertype.isInterface || supertype.isInducedInterface) {
          reportLint(node,
              target: classElement, other: supertype!, reason: 'interface');
          return;
        }
      }

      for (var m in classElement.mixins) {
        var mixin = m.element;
        if (mixin.library != library) continue;
        if (mixin.isInterface || mixin.isInducedInterface) {
          reportLint(node,
              target: classElement, other: mixin, reason: 'interface');
          return;
        }
      }
    }

    if (classElement.isBase) {
      var supertype = classElement.superElement;
      if (supertype.library == library) {
        if (supertype.isFinal || supertype.isInducedFinal) {
          reportLint(node,
              target: classElement, other: supertype!, reason: 'final');
          return;
        }
      }

      for (var m in classElement.mixins) {
        var mixin = m.element;
        if (mixin.library != library) continue;
        if (mixin.isFinal || mixin.isInducedFinal) {
          reportLint(node, target: classElement, other: mixin, reason: 'final');
          return;
        }
      }
    }
  }
}

extension on InterfaceElement? {
  List<InterfaceType> get interfaces => this?.interfaces ?? <InterfaceType>[];

  bool get isFinal {
    var self = this;
    return self != null && self.isFinal;
  }

  /// A sealed declaration `D` is considered final if it has a direct `extends` or
  /// `with` superinterface which is `final`, or it has a direct superinterface
  /// which is `base` as well as a direct `extends` or `with` superinterface
  /// which is `interface`.
  bool get isInducedFinal {
    if (!isSealed) return false;

    if (superElement.isFinal) return true;
    if (mixins.any((m) => m.element.isFinal)) return true;

    for (var i in interfaces) {
      if (i.element.isBase) {
        if (superElement.isInterface) return true;
        if (mixins.any((m) => m.element.isInterface)) return true;
      }
    }

    return false;
  }

  /// A sealed declaration `D` is considered interface if it has a direct
  /// `extends` or `with` superinterface which is `interface`.
  bool get isInducedInterface {
    if (!isSealed) return false;

    if (superElement.isInterface) return true;
    if (mixins.any((m) => m.element.isInterface)) return true;

    return false;
  }

  bool get isInterface {
    var self = this;
    return self != null && self.isInterface;
  }

  bool get isSealed {
    var self = this;
    return self != null && self.isSealed;
  }

  LibraryElement? get library => this?.library;

  List<InterfaceType> get mixins => this?.mixins ?? <InterfaceType>[];

  InterfaceElement? get superElement => this?.supertype?.element;
}

extension on InterfaceElement {
  bool get hasNoModifiers => !isInterface && !isBase && !isSealed && !isFinal;

  bool get isBase {
    var self = this;
    if (self is ClassElement) return self.isBase;
    if (self is MixinElement) return self.isBase;
    return false;
  }

  bool get isFinal {
    var self = this;
    if (self is ClassElement) return self.isFinal;
    if (self is MixinElement) return self.isFinal;
    return false;
  }

  bool get isInterface {
    var self = this;
    if (self is ClassElement) return self.isInterface;
    if (self is MixinElement) return self.isInterface;
    return false;
  }

  bool get isSealed {
    var self = this;
    if (self is ClassElement) return self.isSealed;
    if (self is MixinElement) return self.isSealed;
    return false;
  }
}
