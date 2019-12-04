// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N no_state_constructor`

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MyStateful extends StatefulWidget {
  const MyStateful({Key key, this.props}): super(key: key);

  final int props;

  MyStatefulState createState() => MyStatefulState(props);
}

class MyStatefulState extends State<MyStateful> {
  MyStatefulState(this.props); // LINT

  final int props;

  @override
  Widget build(BuildContext context) => Row();
}
