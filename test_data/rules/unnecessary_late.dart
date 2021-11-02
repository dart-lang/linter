// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N unnecessary_late`

late String unnecessaryTopLevel = ""; // LINT

late String necessaryTopLevel; // OK

class Test {
  static late String unnecessaryStatic = ""; // LINT

  static late String necessaryStatic; // OK

  void test() {
    late String necessaryLocal = ""; // OK
  }
}
