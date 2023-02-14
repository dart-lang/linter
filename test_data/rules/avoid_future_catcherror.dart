// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_future_catcherror`

void bad() {
  doSomethingAsync().catchError((err) => null);
}

Future<Object?> doSomethingAsync() => Future<bool>.value(true);
