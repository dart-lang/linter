// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class RequireTrailingCommasExample {
  RequireTrailingCommasExample.constructor1(Object param1, Object param2);

  RequireTrailingCommasExample.constructor2(
    Object param1,
    Object param2,
    Object param3,
  );

  RequireTrailingCommasExample.constructor3(
      Object param1, Object param2, Object param3); // LINT

  RequireTrailingCommasExample.constructor4(
    Object param1,
    Object param2, [
    Object param3 = const [
      'test',
    ],
  ]);

  RequireTrailingCommasExample.constructor5(Object param1, Object param2,
      [Object param3 = const [
        'test',
      ]]); // LINT

  RequireTrailingCommasExample.constructorWithAssert1()
      : assert(
          true,
          'A very very very very very very very very long string',
        );

  RequireTrailingCommasExample.constructorWithAssert2()
      : assert(true,
            'A very very very very very very very very long string'); // LINT

  void operator [](Object param1, Object param2, Object param3, Object param4,
      Object param5) {} // LINT

  void method1(Object param1, Object param2, {Object param3, Object param4}) {}

  void method2(
    Object param1,
    Object param2,
    Object param3,
    Object param4,
    Object param5,
  ) {}

  void method3(
    Object param1,
    Object param2, {
    Object param3,
    Object param4,
    Object param5,
  }) {}

  void method4(Object param1, Object param2, Object param3, Object param4,
      Object param5) {} // LINT

  void method5(Object param1, Object param2,
      {Object param3, Object param4, Object param5}) {} // LINT

  void method6(Object param1, Object param2,
      {Object param3,
      Object param4,
      Object param5,
      Object param6,
      Object param7}) {} // LINT

  void method7(Object param1, Object param2, Object param3,
      {Object namedParam = true}) {} // LINT

  void run() {
    void test(Object param1, Object param2, {Object param3}) {}

    test('fits on one line, no need trailing comma', 'test');

    test(
      'does not fit on one line, requires trailing comma',
      'test test test test test',
    );

    test('does not fit on one line, requires trailing comma',
        'test test test test test'); // LINT

    test('test', () {
      // Function literal implemented using curly braces.
    });

    test('test', () {
      // Function literal implemented using curly braces.
    }, param3: 'test'); // OK

    test(
      'test',
      () {
        // Function literal implemented using curly braces.
      },
      param3: 'test',
    );

    test('test', 'test', param3: () {
      // Function literal implemented using curly braces.
    }); // OK

    test(
      'test',
      'test',
      param3: () {
        // Function literal implemented using curly braces.
      },
    );

    test(
      () {
        // Function literal implemented using curly braces.
      },
      'test',
    );

    test(() {
      // Function literal implemented using curly braces.
    }, 'test'); // OK

    test('map literal', {
      'one': 'test',
      'two': 'test',
    });

    test({
      'one': 'test',
      'two': 'test',
    }, 'map literal'); // OK

    test('set literal', {
      'one',
      'two',
    });

    test({
      'one',
      'two',
    }, 'set literal'); // OK

    test('list literal', [
      'one',
      'two',
    ]);

    test([
      'one',
      'two',
    ], 'list literal'); // OK

    (a, b) {
      // Self-executing closure.
    }(1, 2);

    (one, two, three, four, five, six, seven, eight, nine, ten,
            veryVeryVeryLong) //LINT
        {
      // Self-executing closure.
    }(1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        'a very very very very very very very long string'); // LINT

    test(
      'no exception for set literal as it fits entirely on 1 line',
      const {'one', 'two', 'three'},
    );

    test('no exception for set literal as it fits entirely on 1 line',
        const {'one', 'two', 'three'}); // LINT

    test('exception for set literal as it spans multiple lines', const {
      'one',
      'two',
      'three',
    });

    test('exception for set literal as it spans multiple lines', const <
        AnExtremelyLongClassNameOneTwoThreeFourFiveSixSevenEightNineTen>{}); // LINT

    test(
      'no exception for array literal as it fits entirely on 1 line',
      const ['one', 'two', 'three'],
    );

    test('no exception for array literal as it fits entirely on 1 line',
        const ['one', 'two', 'three']); // LINT

    test('exception for array literal as it spans multiple lines', const [
      'one',
      'two',
      'three',
    ]);

    test('exception for array literal as it spans multiple lines', const <
        AnExtremelyLongClassNameOneTwoThreeFourFiveSixSevenEightNineTen>[]); // LINT

    test(
      'no exception for map literal as it fits entirely on 1 line',
      const {'one': '1', 'two': '2', 'three': '3'},
    );

    test('no exception for map literal as it fits entirely on 1 line',
        const {'one': '1', 'two': '2', 'three': '3'}); // LINT

    test('exception for map literal as it spans multiple lines', const {
      'one': '1',
      'two': '2',
      'three': '3',
    });

    test('exception for map literal as it spans multiple lines', const <String,
        AnExtremelyLongClassNameOneTwoThreeFourFiveSixSevenEightNineTen>{}); // LINT

    test(
      'no exception for function literal as it fits entirely on 1 line',
      () {},
    );

    test('no exception for function literal as it fits entirely on 1 line',
        () {}); // LINT

    test(A(
      a: '',
      b: '',
      c: '',
    )); // OK
    test(method1(
      '',
      '',
      param3: '',
    )); // OK
    var o;
    o(o.map(() {
      return '';
    }).join()); // OK
    o(o.map(() => A(
      a: '',
    )).join()); // OK
    o(o ?? () {
      return '';
    }); // OK

    assert(true);

    assert((){
      return true;
    }()); // OK

    assert('a very very very very very very very very very long string'
        .isNotEmpty); // LINT

    assert(
      'a very very very very very very very very very long string'.isNotEmpty,
    );

    assert(false, 'a short string');

    assert(false,
        'a very very very very very very very very very long string'); // LINT

    assert(
      false,
      'a very very very very very very very very very long string',
    );

    print('''
    '''); // OK

    print(''
    ''); // LINT
  }
}

class AnExtremelyLongClassNameOneTwoThreeFourFiveSixSevenEightNineTen {}

class A {
  A({a, b, c});
}
