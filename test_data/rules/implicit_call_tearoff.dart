// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N implicit_call_tearoff`

class C {
  void call() {}
  void other() {}
}

void callIt(void Function() f) {
  f();
}

void Function() r1() => C(); // LINT
void Function() r2() => C().call; // OK
void Function() r3(C c) => c; // LINT
void Function() r4(C c) => c.call; // OK

void Function() r5(C? c1, C c2) {
  return c1 ?? c2; // LINT
}

void Function() r6(C? c1, C c2) {
  return c1?.call ?? c2.call; // OK
}

void Function() r7() {
  return C()..other(); // LINT
}

void Function() r8() {
  return (C()..other()).call; // OK
}

List<void Function()> r9(C c) {
  return [c]; // LINT
}

List<void Function()> r10(C c) {
  return [c.call]; // OK
}

void main() {
  callIt(C()); // LINT
  callIt(C().call); // OK
  Function f1 = C(); // LINT
  Function f2 = C().call; // OK
  void Function() f3 = C(); // LINT
  void Function() f4 = C().call; // OK

  final c = C();
  callIt(c); // LINT
  callIt(c.call); // OK
  Function f5 = c; // LINT
  Function f6 = c.call; // OK
  void Function() f7 = c; // LINT
  void Function() f8 = c.call; // OK

  <void Function()>[
    C(), // LINT
    C().call, //OK
    c, // LINT
    c.call, // OK
  ];
}
