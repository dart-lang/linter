// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N sized_box_for_whitespace`

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Widget containerWithChild() {
  return Container( // OK
    child: Row(),
  );
}

Widget containerWithChildAndWidth() {
  return Container( // LINT
    width: 10,
    child: Row(),
  );
}

Widget containerWithChildAndHeight() {
  return Container( // LINT
    height: 10,
    child: Column(),
  );
}

Widget containerWithChildWidthAndHeight() {
  return Container( // LINT
    width: 10,
    height: 10,
    child: Row(),
  );
}

Widget emptyContainer() {
  return Container( // OK
  );
}

Widget emptyContainerWithWidth() {
  return Container( // OK
    width: 10,
  );
}

Widget emptyContainerWithHeight() {
  return Container( // OK
    height:10,
  );
}

Widget emptyContainerWithWidthAndHeight() {
  return Container( // LINT
    width: 10,
    height: 10,
  );
}

Widget emptyContainerWithKeyAndWidthAndHeight() {
  return Container( // LINT
    key: Key(''),
    width: 10,
    height: 10,
  );
}
