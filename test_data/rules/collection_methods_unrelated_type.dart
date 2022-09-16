// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N collection_methods_unrelated_type`

// [Iterable.contains] tests.

void f1() {
  var list = <num>[];
  list.contains('1'); // LINT
  list.contains(1); // OK
  list.contains(null); // OK
  list.contains(Object()); // OK
}

abstract class Base {}

class DerivedClass1 extends Base {}

class DerivedClass2 extends Base with Mixin {}

void f2() {
  var list = <Base>[];
  list.contains(Object()); // OK
  list.contains(DerivedClass1()); // OK
}

void f3() {
  var list = <Mixin>[];
  list.contains(DerivedClass2()); // OK
}

abstract class Mixin {}

class MixedIn with Mixin {}

void f4() {
  var list = <DerivedClass2>[];
  Mixin instance = MixedIn();
  list.contains(instance); // OK
}

abstract class Abstract {
  factory Abstract() {
    return new Implementation();
  }

  Abstract._internal();
}

class Implementation extends Abstract {
  Implementation() : super._internal();
}

void f8() {
  var list = <Implementation>[];
  list.contains(Abstract()); // OK
}

void f9() {
  var list = [];
  list.contains(1); // OK
}

void f11(dynamic list) {
  list.contains('1'); // OK
}

bool takesList(List<int> list) => list.contains('a'); // LINT

bool takesList2(List<String> list) => list.contains('a'); // OK

bool takesList3(List list) => list.contains('a'); // OK

abstract class A implements List<int> {}

abstract class B extends A {}

bool takesB(B b) => b.contains('a'); // LINT

abstract class A1 implements List<String> {}

abstract class B1 extends A1 {}

bool takesB1(B1 b) => b.contains('a'); // OK

abstract class A3 implements List {}

abstract class B3 extends A3 {}

bool takesB3(B3 b) => b.contains('a'); // OK

abstract class A2 implements List<String> {}

abstract class B2 extends A2 {}

bool takesB2(B2 b) => b.contains('a'); // OK

abstract class MyList<E> implements List<E> {}

abstract class MyClass implements MyList<int> {
  bool badMethod(String thing) => this.contains(thing); // LINT
  bool badMethod1(String thing) => contains(thing); // LINT
}

abstract class MyDerivedClass extends MyClass {
  bool myConcreteBadMethod(String thing) => this.contains(thing); // LINT
  bool myConcreteBadMethod1(String thing) => contains(thing); // LINT
}

abstract class MyMixedClass extends Object with MyClass {
  bool myConcreteBadMethod(String thing) => this.contains(thing); // LINT
  bool myConcreteBadMethod1(String thing) => contains(thing); // LINT
}

// [Map.containsKey] tests.

void map1(Map<int, int> map) {
  map.containsKey(1);
  map.containsKey('string'); // LINT
  map.containsKey(null); // OK
  map.containsKey(Object()); // OK
}

abstract class MyMap implements Map<String, int> {
  void map2() {
    containsKey(1); // LINT
    containsKey(null); // OK
  }
}

mixin MyMapMixin on Map<String, int> {
  void map3() {
    containsKey(1); // LINT
    containsKey(2); // OK
  }
}

// [Set.remove] tests.

// TODO(srawlins): Add tests for `Set.containsAll`, `Set.difference`,
// `Set.intersection`, `Set.removeAll`, and `Set.retainAll` when
// https://dart-review.googlesource.com/c/sdk/+/259506 is available in linter.
