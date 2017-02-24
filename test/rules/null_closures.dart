// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N null_closures`

import 'dart:core';

void list_firstWhere() {
  // firstWhere has a named closure argument.
  <int>[2, 4, 6].firstWhere((e) => e.isEven, orElse: null); // LINT
  <int>[2, 4, 6].firstWhere((e) => e.isEven, orElse: () => null); // OK
}

void map_putIfAbsent() {
  // putIfAbsent has a required closure argument.
  var map = <int, int>{};
  map.putIfAbsent(7, null); // LINT
  map.putIfAbsent(7, () => null); // OK
}

typedef void Callback(String);

void typedef_parameter() {
  var fn = (Callback c) { c('Hello'); };
  fn(null); // LINT
}
