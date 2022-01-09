// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_var_declarations`

const a = 1; // OK
const int b = 1; // OK
final c = 1; // OK
final int d = 1; // OK
int e = 1; // OK
int? f = null; // OK
var g; // LINT
var h = 1; // LINT
var i = null; // LINT
var j = []; // LINT
var k = {}; // LINT
var _; // LINT
var l = int; // LINT
var m = () {}; // LINT
var n = Thing(5); // LINT
late var o; // LINT
late int p; // OK
late int? q; // OK

f1(int i) {} // OK
f2(var i) {} // LINT
f3(int number, var i) {} // LINT
f4({var i}) {} // LINT
f5({required int i}) {} // OK
f6({required var i}) {} // LINT
f7([int? i]) {} // OK
f8([var i]) {} // LINT
f9() {
  var i; // LINT
}
f10() {
  int? i; // OK
}
f11() {
  final i = 'a'; // OK
}

void l1() {
  for (var i in [1, 2, 3]) { // LINT
    print(i);
  }

  for (final i in [1, 2, 3]) { // OK
    print(i);
  }

  for (int i in [1, 2, 3]) { // OK
    i += 1;
    print(i);
  }

  int j;
  for (j in [1, 2, 3]) { // OK
    print(j);
  }
}

void l2() {
  for (var i = 0; i < 3; i++) { // LINT
    print(i);
  }

  for (int i = 0; i < 3; i++) { // OK
    print(i);
  }
}

void listen(void Function(Object event) onData) {} // OK

f12() {
  listen((var _) {}); // LINT
}

class Thing{
  Thing(var x) { // LINT
    var u; // LINT
    listen((var _) {}); // LINT
  }
  Thing.named({var x}); // LINT

  static var a; // LINT
  static const b = 'b'; // OK

  var j; // LINT
  late var k; // LINT
  late int i; // OK
}
