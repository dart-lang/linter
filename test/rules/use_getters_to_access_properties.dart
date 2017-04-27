// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N use_getters_to_access_properties`

class A{
  int a;
  final array = [];

  static createDict() => {}; // OK

  A._internal();
  factory A.factoryConstructor() => null;
  foo(){} // OK because is void
  void bar() {} // OK because is void

  int getInt() { // LINT
    return a;
  }

  int doSomething() { // OK
    foo();
    return a;
  }

  int hasPrefix1() { // OK
    ++a;
    return a;
  }

  int hasPrefix2() { // OK
    return ++a;
  }

  int hasPostfix1() { // OK
    a++;
    return a;
  }

  int hasPostfix2() { // OK
    return a++;
  }

  int hasAssignmentExpression1() { // OK
    a = 0;
    return a;
  }

  int hasAssignmentExpression2() { // OK
    return a = 0;
  }

  int hasVariableDeclarationOnly() { // LINT
    // ignore: unused_local_variable
    int b = a;
    return a;
  }

  @override
  String toString() { // OK because has @override
    return "I am class A";
  }

  A getFactoryA() { // OK
    return new A.factoryConstructor();
  }

  A getNewA() { // OK
    return new A._internal();
  }

  A getElement() { // OK
    array[0] = null;
    return null;
  }
  dynamic getFirst() { // OK because array[0] has an implicit method invocation.
    return array[0];
  }

}

class TestOperators{
  MyOperators a;
  bool testLt() => a < a; // OK
  bool testGt() => a > a; // OK
  bool testLtEq() => a <= a; // OK
  bool testGtEq() => a >= a; // OK
  bool testEqEq() => a == a; // OK
  MyOperators testMinus() => a - a; // OK
  MyOperators testPlus() => a + a; // OK
  MyOperators testSlash() => a / a; // OK
  MyOperators testTildeSlash() => a ~/ a; // OK
  MyOperators testStar() => a * a; // OK
  MyOperators testPercent() => a % a; // OK
  MyOperators testBar() => a | a; // OK
  MyOperators testCaret() => a ^ a; // OK
  MyOperators testAmpersand() => a & a; // OK
  MyOperators testLtLt() => a << a; // OK
  MyOperators testGtGt() => a >> a; // OK
  MyOperators testIndexEq() { // OK
    a[0]=null;
    return a;
  }
  MyOperators testIndex() => a[0]; // OK
  MyOperators testTilde() => ~a; // OK
}

class MyOperators {
  bool operator <(other)=> true;

  bool operator >(other)=> true;

  bool operator <=(other)=> true;

  bool operator >=(other)=> true;

  @override
  bool operator ==(other)=> true;

  MyOperators operator -(other)=> null;

  MyOperators operator +(other)=> null;

  MyOperators operator /(other)=> null;

  MyOperators operator ~/(other)=> null;

  MyOperators operator *(other)=> null;

  MyOperators operator %(other)=> null;

  MyOperators operator |(other)=> null;

  MyOperators operator ^(other)=> null;

  MyOperators operator &(other)=> null;

  MyOperators operator <<(other)=> null;

  MyOperators operator >>(other)=> null;

  MyOperators operator [](other)=> null;

  void operator []=(index, other)=> null;

  MyOperators operator ~()=> null; // OK
}
