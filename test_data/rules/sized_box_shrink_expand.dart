// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N sized_box_shrink_expand`

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Widget sizedBoxWithZeroWidthZeroHeight() {
  return SizedBox(
    // LINT
    height: 0,
    width: 0,
    child: Container(),
  );
}

Widget sizedBoxWithInfiniteWidthInfiniteHeight() {
  return SizedBox(
    // LINT
    height: double.INFINITY,
    width: double.INFINITY,
    child: Container(),
  );
}

Widget sizedBoxWithInfiniteWidthzeroHeight() {
  return SizedBox(
    // OK
    height: 0,
    width: double.INFINITY,
    child: Container(),
  );
}

Widget sizedBoxWithZeroWidthInfiniteHeight() {
  return SizedBox(
    // OK
    height: double.INFINITY,
    width: 0,
    child: Container(),
  );
}

Widget sizedBoxWithMixedWidthsAndHeights() {
  return SizedBox(
    // OK
    height: 26,
    width: 42,
    child: Container(),
  );
}

Widget sizedBoxWithZeroWidth() {
  return SizedBox(
    // OK
    width: 0,
    child: Container(),
  );
}

Widget sizedBoxWithInfiniteWidth() {
  return SizedBox(
    // OK
    width: double.INFINITY,
    child: Container(),
  );
}

Widget sizedBoxWithZeroHeight() {
  return SizedBox(
    // OK
    height: 0,
    child: Container(),
  );
}

Widget sizedBoxWithInfiniteHeight() {
  return SizedBox(
    // OK
    height: double.INFINITY,
    child: Container(),
  );
}
