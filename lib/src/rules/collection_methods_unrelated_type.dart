// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../analyzer.dart';
import '../util/unrelated_types_visitor.dart';

const _desc = 'Invocation of various collection methods with arguments of '
    'unrelated types.';

const _details = r'''

**DON'T** invoke `contains` on `Iterable` with an instance of different type
than the parameter type.

Doing this will invoke `==` on its elements and most likely will return `false`.

**BAD:**
```dart
void someFunction() {
  var list = <int>[];
  if (list.contains('1')) print('someFunction'); // LINT
}
```

**BAD:**
```dart
void someFunction3() {
  List<int> list = <int>[];
  if (list.contains('1')) print('someFunction3'); // LINT
}
```

**BAD:**
```dart
void someFunction8() {
  List<DerivedClass2> list = <DerivedClass2>[];
  DerivedClass3 instance;
  if (list.contains(instance)) print('someFunction8'); // LINT
}
```

**BAD:**
```dart
abstract class SomeIterable<E> implements Iterable<E> {}

abstract class MyClass implements SomeIterable<int> {
  bool badMethod(String thing) => this.contains(thing); // LINT
}
```

**GOOD:**
```dart
void someFunction10() {
  var list = [];
  if (list.contains(1)) print('someFunction10'); // OK
}
```

**GOOD:**
```dart
void someFunction1() {
  var list = <int>[];
  if (list.contains(1)) print('someFunction1'); // OK
}
```

**GOOD:**
```dart
void someFunction4() {
  List<int> list = <int>[];
  if (list.contains(1)) print('someFunction4'); // OK
}
```

**GOOD:**
```dart
void someFunction5() {
  List<ClassBase> list = <ClassBase>[];
  DerivedClass1 instance;
  if (list.contains(instance)) print('someFunction5'); // OK
}

abstract class ClassBase {}

class DerivedClass1 extends ClassBase {}
```

**GOOD:**
```dart
void someFunction6() {
  List<Mixin> list = <Mixin>[];
  DerivedClass2 instance;
  if (list.contains(instance)) print('someFunction6'); // OK
}

abstract class ClassBase {}

abstract class Mixin {}

class DerivedClass2 extends ClassBase with Mixin {}
```

**GOOD:**
```dart
void someFunction7() {
  List<Mixin> list = <Mixin>[];
  DerivedClass3 instance;
  if (list.contains(instance)) print('someFunction7'); // OK
}

abstract class ClassBase {}

abstract class Mixin {}

class DerivedClass3 extends ClassBase implements Mixin {}
```

''';

class CollectionMethodsUnrelatedType extends LintRule {
  static const LintCode code = LintCode('collection_methods_unrelated_type',
      "The type of the argument of 'Iterable<{0}>.contains' isn't a subtype of '{0}'.");

  CollectionMethodsUnrelatedType()
      : super(
            name: 'collection_methods_unrelated_type',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context.typeSystem, context.typeProvider);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends UnrelatedTypesProcessors {
  _Visitor(super.rule, super.typeSystem, super.typeProvider);

  @override
  List<MethodDefinition> get methods => [
        // Argument to `Iterable<E>.contains` should be assignable to `E`.
        MethodDefinition(
          typeProvider.iterableElement,
          'contains',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `List<E>.remove` should be assignable to `E`.
        MethodDefinition(
          typeProvider.listElement,
          'remove',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `Map<K, V>.containsKey` should be assignable to `K`.
        MethodDefinition(
          typeProvider.mapElement,
          'containsKey',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `Map<K, V>.containsValue` should be assignable to `V`.
        MethodDefinition(
          typeProvider.mapElement,
          'containsValue',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
          typeArgumentIndex: 1,
        ),
        // Argument to `Map<K, V>.remove` should be assignable to `K`.
        MethodDefinition(
          typeProvider.mapElement,
          'remove',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // TODO(srawlins): Queue? It's not in mock SDK or [TypeProvider].
        // Argument to `Queue<E>.remove` should be assignable to `E`.
        /*MethodDefinition(
          typeProvider.queueElement,
          'remove',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),*/
        // Argument to `Set<E>.containsAll` should be assignable to `Set<E>`.
        MethodDefinition(
          typeProvider.setElement,
          'containsAll',
          ExpectedArgumentKind.assignableToCollection,
        ),
        // Argument to `Set<E>.difference` should be assignable to `Set<E>`.
        MethodDefinition(
          typeProvider.setElement,
          'difference',
          ExpectedArgumentKind.assignableToCollection,
        ),
        // Argument to `Set<E>.intersection` should be assignable to `Set<E>`.
        MethodDefinition(
          typeProvider.setElement,
          'intersection',
          ExpectedArgumentKind.assignableToCollection,
        ),
        // Argument to `Set<E>.lookup` should be assignable to `E`.
        MethodDefinition(
          typeProvider.setElement,
          'lookup',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `Set<E>.remove` should be assignable to `E`.
        MethodDefinition(
          typeProvider.setElement,
          'remove',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `Set<E>.removeAll` should be assignable to `Set<E>`.
        MethodDefinition(
          typeProvider.setElement,
          'removeAll',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
        // Argument to `Set<E>.retainAll` should be assignable to `Set<E>`.
        MethodDefinition(
          typeProvider.setElement,
          'retainAll',
          ExpectedArgumentKind.assignableToCollectionTypeArgument,
        ),
      ];
}
