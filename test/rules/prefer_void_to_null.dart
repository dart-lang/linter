// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_void_to_null`

// TODO(mfairhurst) test void with a prefix, except that causes bugs.
// TODO(mfairhurst) test defining a class named Null (requires a 2nd file)

import 'dart:async';
import 'dart:core';
import 'dart:core' as core;

void void_; // OK
Null null_; // LINT
core.Null core_null; // LINT
Future<void> future_void; // OK
Future<Null> future_null; // LINT
Future<core.Null> future_core_null; // LINT

void void_f() {} // OK
Null null_f() {} // LINT
core.Null core_null_f() {} // LINT
f_void(void x) {} // OK
f_null(Null x) {} // LINT
f_core_null(core.Null x) {} // LINT

usage() {
  void void_; // OK
  Null null_; // LINT
  core.Null core_null; // LINT
  Future<void> future_void; // OK
  Future<Null> future_null; // LINT
  Future<core.Null> future_core_null; // LINT
}

variableNamedNull() {
  var Null; // OK
  return Null; // OK
}

parameterNamedNull(Object Null) {
  Null; // OK
}

class AsMembers {
  void void_; // OK
  Null null_; // LINT
  core.Null core_null; // LINT
  Future<void> future_void; // OK
  Future<Null> future_null; // LINT
  Future<core.Null> future_core_null; // LINT

  void void_f() {} // OK
  Null null_f() {} // LINT
  core.Null core_null_f() {} // LINT
  f_void(void x) {} // OK
  f_null(Null x) {} // LINT
  f_core_null(core.Null x) {} // LINT

  void usage() {
    void void_; // OK
    Null null_; // LINT
    core.Null core_null; // LINT
    Future<void> future_void; // OK
    Future<Null> future_null; // LINT
    Future<core.Null> future_core_null; // LINT
  }

  parameterNamedNull(Object Null) {
    Null; // OK
  }

  variableNamedNull() {
    var Null; // OK
    return Null; // OK
  }
}

class MemberNamedNull {
  final Null = null; // OK
}
