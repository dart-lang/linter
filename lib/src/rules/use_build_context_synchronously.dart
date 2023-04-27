// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'Do not use BuildContexts across async gaps.';

const _details = r'''
**DON'T** use BuildContext across asynchronous gaps.

Storing `BuildContext` for later usage can easily lead to difficult to diagnose
crashes. Asynchronous gaps are implicitly storing `BuildContext` and are some of
the easiest to overlook when writing code.

When a `BuildContext` is used, its `mounted` property must be checked after an
asynchronous gap.

**BAD:**
```dart
void onButtonTapped(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 1));
  Navigator.of(context).pop();
}
```

**GOOD:**
```dart
void onButtonTapped(BuildContext context) {
  Navigator.of(context).pop();
}
```

**GOOD:**
```dart
void onButtonTapped() async {
  await Future.delayed(const Duration(seconds: 1));

  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```
''';

class UseBuildContextSynchronously extends LintRule {
  static const LintCode code = LintCode('use_build_context_synchronously',
      "Don't use 'BuildContext's across async gaps.",
      correctionMessage:
          "Try rewriting the code to not reference the 'BuildContext'.");

  /// Flag to short-circuit `inTestDir` checking when running tests.
  final bool inTestMode;

  UseBuildContextSynchronously({this.inTestMode = false})
      : super(
          name: 'use_build_context_synchronously',
          description: _desc,
          details: _details,
          group: Group.errors,
          state: State.experimental(),
        );

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var unit = context.currentUnit.unit;
    if (inTestMode || !context.inTestDir(unit)) {
      var visitor = _Visitor(this);
      registry.addMethodInvocation(this, visitor);
      registry.addInstanceCreationExpression(this, visitor);
      registry.addFunctionExpressionInvocation(this, visitor);
      registry.addPrefixedIdentifier(this, visitor);
    }
  }
}

class _AwaitVisitor extends RecursiveAstVisitor {
  bool hasAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    hasAwait = true;
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    // Stop visiting when we arrive at a function body.
    // Awaits inside it don't matter.
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    // Stop visiting when we arrive at a function body.
    // Awaits inside it don't matter.
  }
}

enum _MountedCheck {
  positive,
  negative;

  _MountedCheck get negate => switch (this) {
        _MountedCheck.positive => _MountedCheck.negative,
        _MountedCheck.negative => _MountedCheck.positive,
      };
}

class _MountedCheckVisitor extends SimpleAstVisitor<_MountedCheck> {
  static const mountedName = 'mounted';

  final AstNode child;

  _MountedCheckVisitor({required this.child});

  @override
  _MountedCheck? visitBinaryExpression(BinaryExpression node) {
    if (node.isAnd) {
      return node.leftOperand.accept(this) ?? node.rightOperand.accept(this);
    } else if (node.isOr) {
      return node.leftOperand.accept(this) ?? node.rightOperand.accept(this);
    } else {
      // TODO(srawlins): What about `??`?
      return null;
    }
  }

  @override
  _MountedCheck? visitBlock(Block node) {
    for (var statement in node.statements) {
      var mountedCheck = statement.accept(this);
      if (mountedCheck != null) {
        return mountedCheck;
      }
    }
    return null;
  }

  @override
  _MountedCheck? visitConditionalExpression(ConditionalExpression node) {
    if (child == node.condition) return null;

    var conditionMountedCheck = node.condition.accept(this);
    if (conditionMountedCheck == null) return null;

    if (child == node.thenExpression) {
      return conditionMountedCheck == _MountedCheck.positive
          ? _MountedCheck.positive
          : null;
    } else if (child == node.elseExpression) {
      return conditionMountedCheck == _MountedCheck.negative
          ? _MountedCheck.positive
          : null;
    } else {
      // `child` is (or is a child of) a statement that comes after `node`
      // in a NodeList.

      // TODO(srawlins): What if `thenExpression` has an `await`?
      if (conditionMountedCheck == _MountedCheck.negative &&
          node.thenExpression.terminatesControl) {
        return _MountedCheck.positive;
      } else if (conditionMountedCheck == _MountedCheck.positive &&
          node.elseExpression.terminatesControl) {
        return _MountedCheck.positive;
      }
      return null;
    }
  }

  @override
  _MountedCheck? visitIfStatement(IfStatement node) {
    if (child == node.expression) {
      // In this situation, any possible mounted check would be a _descendent_
      // of `child`; it would not be a valid mounted check for `child`.
      return null;
    }
    var conditionMountedCheck = node.expression.accept(this);

    if (conditionMountedCheck == null) return null;
    if (child == node.thenStatement) {
      return conditionMountedCheck == _MountedCheck.positive
          ? _MountedCheck.positive
          : null;
    } else if (child == node.elseStatement) {
      return conditionMountedCheck == _MountedCheck.negative
          ? _MountedCheck.positive
          : null;
    } else {
      if (conditionMountedCheck == _MountedCheck.positive) {
        // `child` is (or is a child of) a statement that comes after `node`
        // in a NodeList.

        var elseStatement = node.elseStatement;
        if (elseStatement == null) {
          // The mounted check in the if-condition does not guard `child`.
          return null;
        }

        // TODO(srawlins): If `thenStatement` has an `await`, then we don't
        // have a valid mounted check, unless the `await` is followed by
        // another mounted check...
        return elseStatement.terminatesControl ? _MountedCheck.positive : null;
      } else {
        // `child` is (or is a child of) a statement that comes after `node`
        // in a NodeList.

        // TODO(srawlins): If `elseStatement` has an `await`, then we don't
        // have a valid mounted check, unless the `await` is followed by
        // another mounted check...
        return node.thenStatement.terminatesControl
            ? _MountedCheck.negative
            : null;
      }
    }
  }

  @override
  _MountedCheck? visitPrefixedIdentifier(PrefixedIdentifier node) =>
      node.identifier.name == mountedName ? _MountedCheck.positive : null;

  @override
  _MountedCheck? visitPrefixExpression(PrefixExpression node) {
    if (node.isNot) {
      var mountedCheck = node.operand.accept(this);
      return mountedCheck?.negate;
    } else {
      return null;
    }
  }

  @override
  _MountedCheck? visitSimpleIdentifier(SimpleIdentifier node) =>
      node.name == mountedName ? _MountedCheck.positive : null;

  @override
  _MountedCheck? visitTryStatement(TryStatement node) {
    // No statement in the `try` section of a try should be considered
    // sufficient; only statements in the `finally` section.
    var statements = node.finallyBlock?.statements;
    if (statements == null) {
      return null;
    }
    for (var statement in statements) {
      var mountedCheck = statement.accept(this);
      if (mountedCheck == _MountedCheck.negative) return _MountedCheck.negative;
    }
    return null;
  }
}

class _Visitor extends SimpleAstVisitor {
  static const mountedName = 'mounted';

  final LintRule rule;

  _Visitor(this.rule);

  bool accessesContext(ArgumentList argumentList) {
    for (var argument in argumentList.arguments) {
      if (argument is NamedExpression) {
        argument = argument.expression;
      }
      if (argument is PropertyAccess) {
        argument = argument.propertyName;
      }
      if (argument is Identifier) {
        var element = argument.staticElement;
        if (element == null) {
          return false;
        }

        // Get the declaration to ensure checks from un-migrated libraries work.
        DartType? argType;
        var declaration = element.declaration;
        if (declaration is ExecutableElement) {
          argType = declaration.returnType;
        } else if (declaration is VariableElement) {
          argType = declaration.type;
        }

        var isGetter = element is PropertyAccessorElement;
        if (isBuildContext(argType, skipNullable: isGetter)) {
          return true;
        }
      }
    }
    return false;
  }

  void check(AstNode node) {
    /// Checks each of the [statements] before [child] for a `mounted` check,
    /// and returns whether it did not find one (and the caller should keep
    /// looking).
    bool checkStatements(Statement child, NodeList<Statement> statements) {
      var index = statements.indexOf(child);
      for (var i = index - 1; i >= 0; i--) {
        var s = statements[i];
        // `s` is a sufficient mounted check if it causes control flow to exit
        // the current function body, so we specify [ _MountedCheck.negative].
        if (s.isMountedCheckFor(child, expected: _MountedCheck.negative)) {
          return false;
        } else if (s.isAsync) {
          rule.reportLint(node);
          return true;
        }
      }
      return true;
    }

    // Walk back and look for an async gap that is not guarded by a mounted
    // property check.
    AstNode? child = node;
    while (child != null && child is! FunctionBody) {
      var parent = child.parent;
      if (parent is Block) {
        var keepChecking =
            checkStatements(child as Statement, parent.statements);
        if (!keepChecking) {
          return;
        }
      } else if (parent is SwitchCase) {
        // Necessary for Dart 2.19 code.
        var keepChecking =
            checkStatements(child as Statement, parent.statements);
        if (!keepChecking) {
          return;
        }
      } else if (parent is SwitchPatternCase) {
        // Necessary for Dart 3.0 code.
        var keepChecking =
            checkStatements(child as Statement, parent.statements);
        if (!keepChecking) {
          return;
        }
      } else if (parent is ConditionalExpression) {
        if (child != parent.condition && parent.condition.hasAwait) {
          rule.reportLint(node);
          return;
        }

        // mounted ? ... : ...
        if (parent.isMountedCheckFor(child, expected: _MountedCheck.positive)) {
          return;
        }
      } else if (parent is IfStatement) {
        // Only check the actual statement(s), not the if condition.
        if (child is Statement && parent.expression.hasAwait) {
          rule.reportLint(node);
          return;
        }

        // if (mounted) { ... }
        if (parent.isMountedCheckFor(child, expected: _MountedCheck.positive)) {
          return;
        }
      }

      child = parent;
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (accessesContext(node.argumentList)) {
      check(node);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (accessesContext(node.argumentList)) {
      check(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (isBuildContext(node.target?.staticType, skipNullable: true) ||
        accessesContext(node.argumentList)) {
      check(node);
    }
  }

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.identifier.name == mountedName) {
      // Accessing `context.mounted` does not count as a "use" of a
      // `BuildContext` which needs to be guarded by a mounted check.
      return;
    }
    // Getter access.
    if (isBuildContext(node.prefix.staticType, skipNullable: true)) {
      check(node);
    }
  }
}

extension on AstNode {
  bool get terminatesControl {
    var self = this;
    if (self is Block) {
      return self.statements.last.terminatesControl;
    }
    // TODO(srawlins): Make ExitDetector 100% functional for our needs. The
    // basic (only?) difference is that it doesn't consider a `break` statement
    // to be exiting.
    if (self is ReturnStatement ||
        self is BreakStatement ||
        self is ContinueStatement) {
      return true;
    }
    return accept(ExitDetector()) ?? false;
  }

  /// Returns whether `this` is a node which guards [child] with a **mounted
  /// check**. [child] must be a direct child of `this`, or a sibling of `this`
  /// in a List of [Statement]s.
  ///
  /// A mounted check is a check of whether a bool-typed identifier, 'mounted',
  /// is checked to be `true` or `false`, in a position which affects control
  /// flow.
  ///
  /// [expected] specifies the polarity of any mounted check in order for it
  /// to be a sufficient, legitimate mounted check. The value given for
  /// [expected] is derived from the relationship between `this` and [child];
  /// see callers.
  bool isMountedCheckFor(AstNode child, {required _MountedCheck expected}) {
    var visitor = _MountedCheckVisitor(child: child);
    var mountedCheck = accept(visitor);
    return expected == mountedCheck;
  }
}

extension on PrefixExpression {
  bool get isNot => operator.type == TokenType.BANG;
}

extension on BinaryExpression {
  bool get isAnd => operator.type == TokenType.AMPERSAND_AMPERSAND;
  bool get isOr => operator.type == TokenType.BAR_BAR;
}

extension on Expression {
  /// Whether this has an [AwaitExpression] inside.
  bool get hasAwait {
    var visitor = _AwaitVisitor();
    accept(visitor);
    return visitor.hasAwait;
  }
}

extension on Statement {
  /// Whether this statement has an [AwaitExpression] inside.
  bool get isAsync {
    var self = this;
    if (self is IfStatement) {
      if (self.expression.hasAwait) return true;
      // If the then-statement definitely exits, and if there is no
      // else-statement or the else-statement also definitely exits, then any
      // `await`s inside do not count.
      if (self.thenStatement.terminatesControl) {
        var elseStatement = self.elseStatement;
        if (elseStatement == null || elseStatement.terminatesControl) {
          return false;
        }
      }
    }
    var visitor = _AwaitVisitor();
    accept(visitor);
    return visitor.hasAwait;
  }

  /// Whether this statement terminates control, via a [BreakStatement], a
  /// [ContinueStatement], or other definite exits, as determined by
  /// [ExitDetector].
  bool get terminatesControl {
    var self = this;
    if (self is Block) {
      // TODO(scheglov) Stop using package:collection when SDK 3.0.0
      var last = self.statements.lastOrNull;
      return last != null && last.terminatesControl;
    }
    // TODO(srawlins): Make ExitDetector 100% functional for our needs. The
    // basic (only?) difference is that it doesn't consider a `break` statement
    // to be exiting.
    if (self is BreakStatement || self is ContinueStatement) {
      return true;
    }
    return accept(ExitDetector()) ?? false;
  }
}
