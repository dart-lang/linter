// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_redundant_parameter_values`

class A {
  void f({bool valWithDefault = true, bool val}) {}
  void g({int valWithDefault = 1, bool val}) {}
  void h({String valWithDefault = 'default', bool val}) {}
}

bool q() => true;

void ff({bool valWithDefault = true, bool val}) {}

void main() {
  A().f(valWithDefault: true); //LINT
  A().g(valWithDefault: 1); //LINT
  A().h(valWithDefault: 'default'); //LINT

  A().f(val: false); //OK
  A().f(val: false, valWithDefault: false); //OK

  final v = true;
  A().f(val: false, valWithDefault: v); //OK
  A().f(val: false, valWithDefault: q()); //OK

  ff(valWithDefault: true); //LINT
  ff(val: false); //OK
  ff(val: false, valWithDefault: false); //OK

  ff(val: false, valWithDefault: v); //OK
  ff(val: false, valWithDefault: q()); //OK
}
