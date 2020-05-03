// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_mixin`

import 'dart:collection';

import 'dart:convert';

class A {}

class B extends Object with A {} // LINT

mixin M {}

class C with M {} // OK

class I with IterableMixin //OK
{
  @override
  Iterator get iterator => throw UnimplementedError();
}

class L with ListMixin //OK
{
  @override
  int length;

  @override
  Object operator [](int index) {
    throw UnimplementedError();
  }

  @override
  void operator []=(int index, value) {}
}

class MM with MapMixin //OK
{
  @override
  Object operator [](Object key) {
    throw UnimplementedError();
  }

  @override
  void operator []=(key, value) {
  }

  @override
  void clear() {
  }

  @override
  Iterable get keys => throw UnimplementedError();

  @override
  Object remove(Object key) {
    throw UnimplementedError();
  }
}

class S with SetMixin //OK
{
  @override
  bool add(value) {
    throw UnimplementedError();
  }

  @override
  bool contains(Object valuent) {
    throw UnimplementedError();
  }

  @override
  Iterator get iterator => throw UnimplementedError();

  @override
  int get length => throw UnimplementedError();

  @override
  Object lookup(Object valuent) {
    throw UnimplementedError();
  }

  @override
  bool remove(Object value) {
    throw UnimplementedError();
  }

  @override
  Set toSet() {
    throw UnimplementedError();
  }
}

class SCS with StringConversionSinkMixin //OK
{
  @override
  void addSlice(String str, int start, int end, bool isLast) {
  }

  @override
  void close() {
  }
}
