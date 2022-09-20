// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_init_to_null`

int? ii = null; //LINT
dynamic iii = null; //LINT

// todo (pq): mock and add FutureOr examples

var x = null; //LINT
var y; //OK
var z = 1; //OK
const nil = null; //OK
final nil2 = null; //OK
foo({p: null}) {} //LINT


class X {
  static const nil = null; //OK
  final nil2 = null; //OK

  // TODO(pq): ints are not nullable so we'll want to update the lint here
  int? xx = null; //LINT
  int y; //OK
  int z; //OK

  X.c({this.xx: null}) //LINT
      : y = 1, z = 1;

  fooNamed({
    p: null, //LINT
    p1 = null, //LINT
    var p2 = null, //LINT
    p3 = 1, //OK
    p4, //OK
  }) {}

  fooOptional([
    p = null, //LINT
    p1 = null, //LINT
    var p2 = null, //LINT
    p3 = 1, //OK
    p4, //OK
  ]) {}
}
