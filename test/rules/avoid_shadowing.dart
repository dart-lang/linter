// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_shadowing`

var top = null;

m() {
  f() {
    var top; // LINT
    var a; // OK
  }

  var a; // OK
  var b; // OK
  var top; // LINT

  g() {
    var a; // LINT
    var c; // OK
  }
}

class A {
  var a;
  get b => null;

  ma() {
    var a; // LINT
    var b; // LINT
    var top; // LINT
  }

  static sm() {
    var a; // OK
    var b; // OK
    var c; // OK
  }
}

class B extends A {
  mb() {
    var a; // LINT
    var b; // LINT
    var c; // OK
  }
}

class C extends Object with A {
  mc() {
    var a; // LINT
    var b; // LINT
    var c; // OK
  }
}

// special case for factory and static
class D {
  var a;
  get b => null;
  static get c => null;

  static sm() {
    var a; // OK
    var b; // OK
    var c; // LINT
  }

  factory D() {
    var a; // OK
    var b; // OK
    var c; // LINT
  }
}
