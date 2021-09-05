// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N always_specify_types`

import 'package:meta/meta.dart';

typedef MapList = List<StringMap>; //LINT
typedef JsonMap = Map<String, dynamic>; //OK
typedef StringList = List<JsonMap>; //OK
typedef RawList = List; //LINT
typedef StringMap<V> = Map<String, V>; //OK

StringMap<String> sm = StringMap<String>(); //OK
StringMap? rm1; //LINT
StringMap<String> rm2 = StringMap(); //LINT
StringMap rm3 = StringMap<String>(); //LINT

Map<String, String> map = {}; //LINT
List<String> strings = []; //LINT
Set<String> set = {}; //LINT

List? list; //LINT
List<List>? lists; //LINT
List<int> ints = <int>[1]; //OK

final x = 1; //LINT [1:5]
final int xx = 3;
const y = 2; //LINT
const int yy = 3;

a(var x) {} //LINT
b(s) {} //LINT [3:1]
c(int x) {}
d(final x) {} //LINT
e(final int x) {}

@optionalTypeArgs
class P<T> { }

@optionalTypeArgs
void g<T>() {}

//https://github.com/dart-lang/linter/issues/851
void test() {
  g<dynamic>(); //OK
  g(); //OK
}

main() {
  var x = ''; //LINT [3:3]
  for (var i = 0; i < 10; ++i) {  //LINT [8:3]
    print(i);
  }
  List<String> ls = <String>[];
  ls.forEach((s) => print(s)); //LINT [15:1]
  for (var l in ls) { //LINT [8:3]
    print(l);
  }
  try {
    for (final l in ls) { // LINT [10:5]
      print(l);
    }
  } on Exception catch (ex) {
    print(ex);
  } catch (e) { // NO warning (https://codereview.chromium.org/1427223002/)
    print(e);
  }

  var __; // LINT

  listen((_) { // OK!
    // ...
  });

  P p = new P(); //OK (optionalTypeArgs)
}

P doSomething(P p) //OK (optionalTypeArgs)
{
  return p;
}

listen(void onData(Object event)) {}

var z; //LINT

class Foo {
  static var bar; //LINT
  static final baz  = 1; //LINT
  static final int bazz = 42;
  var foo; //LINT
  Foo(var bar); //LINT [7:3]
  void f(List l) { } //LINT
}

void m() {
  if ('' is Map) //OK {
  {
     print("won't happen");
  }
}
