// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:core';

void throwString() {
  throw 'hello world!'; // LINT
}

void throwNull() {
  throw null; // LINT
}

void throwNumber() {
  throw 7; // LINT
}

void throwObject() {
  throw Object(); // LINT
}

void throwError() {
  throw Error(); // OK
}

void throwDynamicPrebuiltError() {
  var error = new Error();
  throw error; // OK
}

void throwStaticPrebuiltError() {
  Error error = Error();
  throw error; // OK
}

void throwArgumentError() {
  Error error = ArgumentError('oh!');
  throw error; // OK
}

void throwException() {
  Exception exception = Exception('oh!');
  throw exception; // OK
}

void throwStringFromFunction() {
  throw returnString(); // LINT
}

String returnString() => 'string!';

void throwExceptionFromFunction() {
  throw returnException();
}

Exception returnException() => Exception('oh!');

// TODO: Even though in the test this does not get linted, it does while
// analyzing the SDK code. Find out why.
dynamic noSuchMethod(Invocation invocation) {
  throw NoSuchMethodError.withInvocation(Object(), invocation);
}

class Err extends Object with Exception {
  static throws() {
    throw Err(); // OK
  }
}

void throwsDynamicPromotedToNonError(dynamic error) {
  if (error is String) {
    throw error; // LINT
  }
}

void throwsPromotedObject(Object error) {
  if (error is Error) {
    throw error; // OK
  }
}

void throwsBoundTypeVariable<E extends Exception>(E error) {
  throw error; // OK
}

throwsPromotedTypeVariable<E>(E error) {
  if (error is Error) {
    throw error; // OK
  }
}
