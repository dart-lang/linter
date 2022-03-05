// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N use_decorated_box`

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

Widget containerWithoutArguments() {
  return Container(); // OK
}

Widget containerWithKey() {
  return Container( // OK
    key: Key('abc'),
  );
}

Widget containerWithDecoration() {
  return Container( // LINT
    decoration: Decoration(),
  );
}

Widget containerWithChild() {
  return Container( // OK
    child: SizedBox(),
  );
}

Widget containerWithKeyAndChild() {
  return Container( // OK
    key: Key('abc'),
    child: SizedBox(),
  );
}

Widget containerWithKeyAndDecoration() {
  return Container( // LINT
    key: Key('abc'),
    decoration: Decoration(),
  );
}

Widget containerWithDecorationAndChild() {
  return Container( // LINT
    decoration: Decoration(),
    child: SizedBox(),
  );
}

Widget containerWithKeyAndDecorationAndChild() {
  return Container( // LINT
    key: Key('abc'),
    decoration: Decoration(),
    child: SizedBox(),
  );
}

Widget containerWithAnotherArgument() {
  return Container( // OK
    width: 20,
  );
}

Widget containerWithDecorationAndAdditionalArgument() {
  return Container( // OK
    decoration: Decoration(),
    width: 20,
  );
}

Widget containerWithDecorationAndAdditionalArgumentAndChild() {
  return Container( // OK
    decoration: Decoration(),
    width: 20,
    child: SizedBox(),
  );
}

Widget containerWithNullDecoration() {
  return Container( // OK
    decoration: null,
    child: SizedBox(),
  );
}

const Decoration? _nullableDecoration = null;

Widget containerWithNullableDecoration() {
  return Container( // OK
    decoration: _nullableDecoration,
    child: SizedBox(),
  );
}

final _nonNullDecoration = Decoration();

Widget containerWithNonNullDecoration() {
  return Container( // LINT
    decoration: _nonNullDecoration,
    child: SizedBox(),
  );
}

Decoration? _getDecoration() => null;

Widget nullableReturnValue() {
  return Container( // OK
    decoration: _getDecoration(),
    child: SizedBox(),
  );
}
