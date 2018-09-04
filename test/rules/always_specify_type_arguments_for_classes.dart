// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N always_specify_type_arguments_for_classes`

// Hack to work around issues importing `meta.dart` in tests.
// Ideally, remove:
library meta;

class _OptionalTypeArgs {
  const _OptionalTypeArgs();
}

const _OptionalTypeArgs optionalTypeArgs = const _OptionalTypeArgs();

// ... and replace w/:
// import 'package:meta/meta.dart';

Map<String, String> map = {}; //LINT
List<String> strings = []; //LINT

List list; // LINT
List<List> lists; //LINT
List<int> ints; //OK


@optionalTypeArgs
class P<T> { }

main() {
  var p = new P(); //OK (optionalTypeArgs)
}

P doSomething(P p) //OK (optionalTypeArgs)
{
  return p;
}

class Foo {
  void f(List l) { } //LINT
}

void m() {
  if ('' is Map) //OK {
  {
     print("won't happen");
  }
}
