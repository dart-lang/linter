// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_sizedbox_over_container`

// ignore_for_file: prefer_expression_function_bodies

import 'package:flutter/widgets.dart';

Widget containerWithChild() {
  return Container( // OK
    child: Row(),
  );
}

Widget containerWithChildAndWidth() {
  return Container( // OK
    width: 10,
    child: Row(),
  );
}

Widget containerWithChildAndHeight() {
  return Container( // OK
    height: 10,
    child: Column(),
  );
}

Widget containerWithChildWidthAndHeight() {
  return Container( // OK
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
  return Container( // LINT
    width: 10,
  );
}

Widget emptyContainerWithHeight() {
  return Container( // LINT
    height:10,
  );
}

Widget emptyContainerWithWidthAndHeight() {
  return Container( // LINT
    width: 10,
    height: 10,
  );
}

Widget buildRowWidth() {
  return Row(
    children: <Widget>[
      const MyLogo(),
      Container(width: 4), // LINT
      const Expanded(
        child: Text('...'),
      ),
    ],
  );
}

Widget buildRowHeight() {
  return Row(
    children: <Widget>[
      const MyLogo(),
      Container(height: 4), // LINT
      const Expanded(
        child: Text('...'),
      ),
    ],
  );
}

Widget buildRowWidthAndHeight() {
  return Row(
    children: <Widget>[
      const MyLogo(),
      Container(width: 4, height: 4), // LINT
      const Expanded(
        child: Text('...'),
      ),
    ],
  );
}

