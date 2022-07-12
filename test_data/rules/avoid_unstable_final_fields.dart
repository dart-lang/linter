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

class C {
  final int i;
  C(this.i);
}

class D1 implements C {
  late final int i = j++; //OK
}

class D2 extends C {
  int get i => super.i + 1; //OK
  D2(super.i);
}
