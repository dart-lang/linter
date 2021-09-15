// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N use_iterables`

import 'dart:core';
import 'dart:core' as core;

extension I on Iterable {
  operator+(Iterable other) => [];
  operator[](int index) => null;
}

class A {
  Iterable map(Function(Object) f) => [];
}

T identity<T>(T x) => x;

Iterable lazy() => [1].map(identity); // LINT
Iterable? lazyOrNull() {
  return [1].map(identity); // LINT
}

class H {
  final Iterable iter;
  H(Iterable iterable) :
    iter = [...iterable].map(identity); // LINT
}

void f() {
  A().map(print); // OK
  [].map(print); // LINT
  var s = { 1 };
  s.map(print); // LINT
  [].map(print).toList(); // OK
  [].map(print).first; // OK
  print([].map(print)); // OK
  var iter = [].map(print); // OK
  var iter2 = [1].map(print) as Iterable; // OK
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

  core.List.empty().map(print); // LINT
  print(core.List.empty().map(print)); // OK
  var b = [].map(print) == null; // OK
  print([].map(print) == null); // OK
  var x = [1].map(print) + []; // OK
  var i = [1].map(print)[0]; // OK
  [1]..map(print); // LINT
  [1]..map(print).toList(); // OK
  [1]..map(print)..toList(); // LINT

  for ([1].map(print); ; ) { // LINT
    print('?');
  }
  for (; ; [1].map(print)) { // LINT
    print('?');
  }
  ([1].map(print)); // LINT
  [1].map(print) as Iterable; // LINT
  if ([1].map(print) is Iterable) print('!'); // LINT
  iterOrNull()?.map(print); // LINT
  iterOrNull()?.map(print).first; // OK
  true ? [].map(print) : []; // LINT
  var iter3 = true ? [].map(print) : []; // OK
  visit([1].map(identity)); // OK
  visit([
    1,
    ...[2, 3].map(identity), // OK
  ]);

  [1].expand((e) => [e].map(identity)); // OK
  [1].expand((e) {
    return [e].map(identity); // OK
  });
}

void visit(Iterable iterable) { }

Iterable iter() => [];
Iterable? iterOrNull() => [];
