// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N duplicated_keys`

class MyConst{
  const MyConst(this.a);
  final a;
}

const one = 1;
const emptyString = '';
const myList = [[1]];
const myNull = null;

var s = {
  1,
  1, // LINT
  2,
  one, // LINT
  null,
  myNull, // LINT
  '',
  emptyString, // LINT
  const [[1]],
  myList, // LINT
  const MyConst(''),
  const MyConst(''), // LINT
  const MyConst('a'),
};
var m = {
  1: null,
  1: null, // LINT
  2: null,
  one: null, // LINT
  null: null,
  myNull: null, // LINT
  '': null,
  emptyString: null, // LINT
  const [[1]]: null,
  myList: null, // LINT
  const MyConst(''): null,
  const MyConst(''): null, // LINT
  const MyConst('a'): null,
};
