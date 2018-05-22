// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_final_immutable_in_flutter_state`

import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  final a = new TextStyle(fontSize: 10.0); // OK

  @override
  MyWidgetState createState() => new MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  static final b = new TextStyle(fontSize: 20.0); // LINT
  final c = new TextStyle(fontSize: 20.0); // LINT

  @override
  Widget build(BuildContext context) => null;
}
