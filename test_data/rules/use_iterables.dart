// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N use_iterables`

void f() {
  [].map(print); // LINT
  var s = { 1 };
  s.map(print); // LINT
  [].map(print).toList(); // OK
  [].map(print).last; // OK
  print([].map(print)); // OK
  var iter = [].map(print); // OK
  var s1 = {
    [].map(print), // OK
  };
  var l = [
    [].map(print), // OK
  ];
  var m = {
    '' : [].map(print), // OK
  };
  var m2 = { '' : 1};
  m2.keys.map(print); // LINT
}

Iterable iter() => [].map(print); // OK
