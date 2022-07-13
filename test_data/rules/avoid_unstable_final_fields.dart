// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_unstable_final_fields`

class A {
  final int i;
  A(this.i);
}

var j = 0;

class B1 extends A {
  int get i => ++j + super.i; //LINT
  B1(super.i);
}

class B2 implements A {
  int i; //LINT
  B2(this.i);
}

class B3 implements A {
  late final int i = j++; //OK
}

class B4 extends A {
  int get i => super.i + 1; //OK
  B4(super.i);
}

class B5 implements A {
  final int j;
  int get i => j; //OK
  B5(this.j);
}

class B6 implements A {
  int get i => 1; //OK
}

class C<X> {
  final C<X>? next;
  C(this.next);
}

C<Never> cNever = C<Never>(null);

class D1<X> implements C<X> {
  final C<X>? next => cNever;
}
