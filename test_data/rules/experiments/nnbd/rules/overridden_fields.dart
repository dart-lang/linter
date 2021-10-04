// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N overridden_fields`

class Base {
  Object field = 'lorem';

  Object something = 'change';
}

class Bad1 extends Base {
  @override
  final x = 1, field = 'ipsum'; // LINT
}

class Bad2 extends Base {
  @override
  Object something = 'done'; // LINT
}

class Bad3 extends Object with Base {
  @override
  Object something = 'done'; // LINT
}

class Ok extends Base {
  Object newField = 0; // OK

  final Object newFinal = 'ignore'; // OK
}

class OK2 implements Base {
  @override
  Object something = 'done'; // OK

  @override
  Object field = 0;
}

abstract class OK3 implements Base {
  @override
  Object something = 'done'; // OK
}

class GC11 extends Bad1 {
  @override
  Object something = 'done'; // LINT

  Object gc33 = 'gc33';
}

abstract class GC12 implements Bad1 {
  @override
  Object something = 'done'; // OK
}

class GC13 extends Object with Bad1 {
  @override
  Object something = 'done'; // OK

  @override
  Object field = 'lint'; // LINT
}

abstract class GC21 extends GC11 {
  @override
  Object something = 'done'; // LINT
}

abstract class GC22 implements GC11 {
  @override
  Object something = 'done'; // OK
}

class GC23 extends Object with GC13 {
  @override
  Object something = 'done'; // LINT

  @override
  Object field = 'lint'; // LINT
}

class GC23_2 extends GC13 {
  @override
  var x = 7; // LINT
}

abstract class GC31 extends GC13 {
  @override
  Object something = 'done'; // LINT
}

abstract class GC32 implements GC13 {
  @override
  Object something = 'done'; // OK
}

class GC33 extends GC21 with GC13 {
  @override
  Object something = 'done'; // LINT

  @override
  Object gc33 = 'yada'; // LINT
}

class GC33_2 extends GC33 {
  @override
  var x = 3; // LINT

  @override
  Object gc33 = 'yada'; // LINT
}

class Super1 {}

class Sub1 extends Super1 {
  @override
  int y;
}

class Super2 {
  int x = 0, y = 0;
}

class Sub2 extends Super2 {
  @override
  int y; // LINT
}

class Super3 {
  int x = 0;
}

class Sub3 extends Super3 {
  int x  = 0; // LINT
}

class A1 {
  int f = 0;
}

class B1 extends A1 {}

abstract class C1 implements A1 {}

class D1 extends B1 implements C1 {
  @override
  int f = 0; // LINT
}

class A extends B {}
class B extends A {
  int field = 0;
}

class StaticsNo {
  static int a = 0;
}

class VerifyStatic extends StaticsNo {
  static int a = 0;
}

mixin M on A1 {
  @override
  int f = 0; // LINT

  int g = 0; // OK
}

abstract class BB {
  abstract String s;
}

class AA extends BB {
  /// Overriding abstracts in NNBD is OK.
  @override
  String s = ''; // OK
}

class AAA with BB {
  @override
  String s = ''; // OK
}

abstract class BBB {
  abstract final String s;
}

class AAA extends BBB {
  @override
  String s = ''; // OK
}
