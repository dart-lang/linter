// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N no_logic_in_state_constructor`

import 'package:flutter/widgets.dart';

class _Widget extends StatefulWidget {}
mixin _Mixin {}

class A extends State {
  A(); // OK
}

class B extends State<_Widget> {
  B(); // OK
}

class C extends State {
  C() {} // OK
}

class D extends State {
  D() { // OK
    // Comment
  }
}

class E extends State {
  E() { // LINT
    print('hi');
  }
}

class F extends State<_Widget> {
  F() { // LINT
    print('hi');
  }
}

class G extends State {
  G() { // LINT
    var i;
  }
}

class H extends State with _Mixin {
  H() { // LINT
    print('hi');
  }
}

class I {
  I(); // OK
}

class J {
  J() {} // OK
}

class K {
  K() { // OK
    print('');
  }
}

class L extends StatefulWidget {
  L() { // OK
    print('');
  }
}
