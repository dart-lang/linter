// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N discarded_futures`
import 'dart:async';

void recreateDir(String path) { // LINT
  deleteDir(path);
  createDir(path);
}

Future<void> recreateDir2(String path) async { // OK
  await deleteDir(path);
  await createDir(path);
}

void recreateDir3(String path) { // OK
  unawaited(deleteDir(path));
  unawaited(createDir(path));
}

Future<void> deleteDir(String path) async {}
Future<void> createDir(String path) async {}

class A {
  Future<void> m() async {}
  FutureOr<void> n() async {}
  void f() { // LINT
    m();
  }
  void g() { // OK
    unawaited(m());
  }
  void h() { // LINT
    n();
  }
}

void f() { //LINT
  () {
    createDir('.');
  }();
}
