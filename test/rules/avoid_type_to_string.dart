// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_type_to_string`


// SHARED

class A {
  String toString() {}
}

class TypeChildWithOverride extends Type {
  @override
  String toString() {}
}
class TypeGrandChildWithOverride extends TypeChildWithOverride {}

class TypeChildNoOverride extends Type {}
class TypeGrandChildNoOverride extends TypeChildNoOverride {}

mixin ToStringMixin {
  String toString() {}
}


// BAD

class Bad {
  void doBad() {
    A().runtimeType.toString(); // LINT
    TypeChildNoOverride().toString(); // LINT
    TypeGrandChildNoOverride().toString(); // LINT
  }
}

class BadWithType extends Type {
  void doBad() {
    toString(); // LINT
    this.toString(); // LINT

    Future.value('hello').whenComplete(toString); // LINT
    Future.value('hello').whenComplete(this.toString); // LINT
    Future.value('hello').whenComplete(BadWithType().toString); // LINT
  }
}

mixin callToStringOnBadWithType on BadWithType {
  void mixedBad() {
    toString(); // LINT
    this.toString(); // LINT
  }
}

extension ExtensionOnBadWithType on BadWithType {
  void extendedBad() {
    toString(); // LINT
    this.toString(); // LINT
  }
}


// GOOD

class Good {
  void doGood() {
    toString(); // OK
    A().toString(); // OK
    TypeChildWithOverride().toString(); // OK
    TypeGrandChildWithOverride().toString(); // OK

    final refToString = toString;
    refToString(); // OK?
    Future.value('hello').whenComplete(refToString); // OK
  }
}

// TODO: this currently throws a false positive.
// class GoodWithType extends Type {
//   void good() {
//     String toString() => null;
//     toString(); // OK
//   }
// }

class GoodWithTypeAndMixin extends Type with ToStringMixin {
  void doGood() {
    toString(); // OK
    this.toString(); // OK

    Future.value('hello').whenComplete(toString); // OK
    Future.value('hello').whenComplete(this.toString); // OK
    Future.value('hello').whenComplete(GoodWithTypeAndMixin().toString); // OK
  }
}

mixin CallToStringOnGoodWithType on GoodWithTypeAndMixin {
  void mixedGood() {
    toString(); // OK
    this.toString(); // OK
  }
}

extension ExtensionOnGoodWithTypeAndMixin on GoodWithTypeAndMixin {
  void extendedGood() {
    toString(); // OK
    this.toString(); // OK
  }
}
