// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_annotating_with_function`

bool isBadValidString(String value, Function predicate) { // LINT
  return predicate(value);
}

bool isGoodValidString(String value, bool predicate(String string)) {
  return predicate(value);
}
