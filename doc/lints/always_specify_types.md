# Rule always_specify_types

**Group**: style\
**Maturity**: stable\
**Since**: Dart SDK: >= 2.0.0 • (Linter v0.1.4)\


## Description

From the [flutter style guide](https://flutter.dev/style-guide/):

**DO** specify type annotations.

Avoid `var` when specifying that a type is unknown and short-hands that elide
type annotations.  Use `dynamic` if you are being explicit that the type is
unknown.  Use `Object` if you are being explicit that you want an object that
implements `==` and `hashCode`.

**GOOD:**
```
int foo = 10;
final Bar bar = Bar();
String baz = 'hello';
const int quux = 20;
```

**BAD:**
```
var foo = 10;
final bar = Bar();
const quux = 20;
```

NOTE: Using the the `@optionalTypeArgs` annotation in the `meta` package, API
authors can special-case type variables whose type needs to by dynamic but whose
declaration should be treated as optional.  For example, suppose you have a
`Key` object whose type parameter you'd like to treat as optional.  Using the
`@optionalTypeArgs` would look like this:

```
import 'package:meta/meta.dart';

@optionalTypeArgs
class Key<T> {
 ...
}

main() {
  Key s = Key(); // OK!
}
```
## Incompatible With

- [omit_local_variable_types](omit_local_variable_types.md)

