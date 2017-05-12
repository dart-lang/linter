// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N place_undefined_optional_positional_parameters_last`

void goodGetDateTime(int year, [int month = 1, int day]) {}

void badGetDateTime(int year, [int day, int month = 1]) {} // LINT

class TestNonStaticMethods {
  void goodGetDateTime(int year, [int month = 1, int day]) {}

  void badGetDateTime(int year, [int day, int month = 1]) {} // LINT
}

class TestStaticMethods {
  static void goodGetDateTime(int year, [int month = 1, int day]) {}

  static void badGetDateTime(int year, [int day, int month = 1]) {} // LINT
}

class TestConstructors {
  TestConstructors.goodGetDateTime(int year, [int month = 1, int day]);

  TestConstructors.badGetDateTime(int year, [int day, int month = 1]); // LINT
}
