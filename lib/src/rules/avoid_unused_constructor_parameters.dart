import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid defining unused paramters in constructors.';

const _details = r'''

**AVOID** defining unused parameters in constructors.

**BAD:**
```
class BadOne {
  BadOne(int unusedParameter, [String unusedPositional]);
}

class BadTwo {
  int c;

  BadTwo(int a, int b, int x) {
    c = a + b;
  }
}
```

''';

class AvoidUnusedConstructorParameters extends LintRule {
  _Visitor _visitor;
  AvoidUnusedConstructorParameters()
      : super(
            name: 'avoid_unused_constructor_parameters',
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
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final _constructorVisitor = new _ConstructorVisitor(rule, node);
    node?.body?.visitChildren(_constructorVisitor);
    node?.initializers?.forEach((i) => i.visitChildren(_constructorVisitor));

    final unusedParameters = _constructorVisitor.unusedParameters;
    if (unusedParameters.isNotEmpty) rule.reportLint(unusedParameters.first);
  }
}

class _ConstructorVisitor extends RecursiveAstVisitor {
  final LintRule rule;
  final ConstructorDeclaration element;
  final Set<FormalParameter> unusedParameters;

  _ConstructorVisitor(this.rule, this.element)
      : unusedParameters = element.parameters.parameters
            .where((p) => (p.element is! FieldFormalParameterElement))
            .toSet();

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    unusedParameters.removeWhere((p) => node.bestElement == p.element);
  }
}
