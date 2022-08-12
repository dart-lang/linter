// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_implicit_call_tearoffs`

class Callable {
  void call() {}
}

void callIt(void Function() f) {
  f();
}

void main() {
  final c = Callable();
  callIt(c); //LINT
  c as Function; //TODO
  Function f1 = c; //LINT
  callIt(Callable()); //LINT
  Callable() as Function; //TODO
  Function f2 = Callable(); //LINT
}
