// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_async_await_over_raw_futures`

import 'dart:async';

Future bad1() { // LINT
  return longRunningCalculation().then((result) {
    return verifyResult(result.summary);
  }).catchError((e) {
    return new Future.value(false);
  });
}

Future bad2() { // LINT
  return longRunningCalculation().then((result) {
    return verifyResult(result.summary);
  });
}

Future bad3() { // LINT
  return longRunningCalculation().whenComplete(() {
    return verifyResult(null);
  });
}

Future good() { // OK
  return longRunningCalculation().timeout(null, onTimeout: () {
    return verifyResult(null);
  });
}

dynamic badWithDynamic1() { // LINT
  return longRunningCalculation().then((result) {
    return verifyResult(result.summary);
  }).catchError((e) {
    return new Future.value(false);
  });
}

dynamic badWithDynamic2() { // LINT
  return longRunningCalculation().then((result) {
    return verifyResult(result.summary);
  });
}

dynamic badWithDynamic3() { // LINT
  return longRunningCalculation().whenComplete(() {
    return verifyResult(null);
  });
}

dynamic goodWithDynamic() { // OK
  return longRunningCalculation().timeout(null, onTimeout: () {
    return verifyResult(null);
  });
}

class A {
  Future bad1() { // LINT
    return longRunningCalculation().then((result) {
      return verifyResult(result.summary);
    }).catchError((e) {
      return new Future.value(false);
    });
  }

  Future bad2() { // LINT
    return longRunningCalculation().then((result) {
      return verifyResult(result.summary);
    });
  }

  Future bad3() { // LINT
    return longRunningCalculation().whenComplete(() {
      return verifyResult(null);
    });
  }

  Future good() { // OK
    return longRunningCalculation().timeout(null, onTimeout: () {
      return verifyResult(null);
    });
  }

  dynamic badWithDynamic1() { // LINT
    return longRunningCalculation().then((result) {
      return verifyResult(result.summary);
    }).catchError((e) {
      return new Future.value(false);
    });
  }

  dynamic badWithDynamic2() { // LINT
    return longRunningCalculation().then((result) {
      return verifyResult(result.summary);
    });
  }

  dynamic badWithDynamic3() { // LINT
    return longRunningCalculation().whenComplete(() {
      return verifyResult(null);
    });
  }

  dynamic goodWithDynamic() { // OK
    return longRunningCalculation().timeout(null, onTimeout: () {
      return verifyResult(null);
    });
  }
}

Future verifyResult(summary) => null;

Future longRunningCalculation() => null;
