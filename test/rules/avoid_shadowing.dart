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

// 2 shadowing
class E {
  int x;
  m(int x) {
    int x; // LINT
  }
}

// exclude pattern : var x = this.x;
class F {
  int x;
  m() {
    var x = this.x; // OK
  }
}

// exclude pattern : var x = super.x;
class F2 extends F {
  m() {
    var x = super.x; // OK
  }
}

// exclude pattern : same name as current getter name
class G {
  var i;
  get g {
    var i = ''; // LINT
    var g = ''; // OK
    return g;
  }
}