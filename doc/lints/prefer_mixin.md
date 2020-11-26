# Rule prefer_mixin

**Group**: style\
**Maturity**: stable\
**Since**: Dart SDK: >= 2.1.0-dev.5.0 • (Linter v0.1.62)\

[![effective dart](style-effective_dart.svg)](https://github.com/tenhobi/effective_dart)

## Description

Dart 2.1 introduced a new syntax for mixins that provides a safe way for a mixin
to invoke inherited members using `super`. The new style of mixins should always
be used for types that are to be mixed in. As a result, this lint will flag any
uses of a class in a `with` clause.

**BAD:**
```
class A {}
class B extends Object with A {}
```

**OK:**
```
mixin M {}
class C with M {}
```
