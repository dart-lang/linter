// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N declare_const_constructor_when_possible`

class Bad1 {
  Bad1(); // LINT
  Bad1.bad(); // LINT
  Bad1.ok() : this.bad(); // OK
}

class Bad2 {
  final int foo;

  Bad2() : foo = 1; // LINT
}

class Bad3 extends Good1 {
  Bad3() : super(); // LINT
}

class Good1 {
  const Good1(); // OK
}

class Good2 {
  final int foo;

  const Good2() : foo = 1; // OK
}

class Good3 {
  int foo;

  Good3() : foo = 1; // OK
}

// The implicit superCall is not const. // TODO: this must be OK, not LINT
class Good4 extends Good3 {
  Good4(); // LINT
}

class Good5 extends Bad1 {
  Good5() : super.bad(); // OK
}
