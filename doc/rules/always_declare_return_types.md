# Rule always_declare_return_types

`style` `stable` 

## Description

**DO** declare method return types.

When declaring a method or function *always* specify a return type.
Declaring return types for functions helps improve your codebase by allowing the
analyzer to more adequately check your code for errors that could occur during
runtime.

**BAD:**
```dart
main() { }

_bar() => _Foo();

class _Foo {
  _foo() => 42;
}
```

**GOOD:**
```dart
void main() { }

_Foo _bar() => _Foo();

class _Foo {
  int _foo() => 42;
}

typedef predicate = bool Function(Object o);
```
