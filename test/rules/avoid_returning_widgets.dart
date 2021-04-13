// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N avoid_returning_widgets`

import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) { // OK
    return Container();
  }

  String notImportant() => 'hey'; // OK

  Widget yourWidget() { // LINT
    return Container();
  }

  Widget myWidget() => Container(); // LINT

  Widget _myWidget() => Container(); // LINT

  Widget get _aWidget => Container(); // LINT

  Container yourWidget2() { // LINT
    return Container();
  }

  Container myWidget2() => Container(); // LINT

  Container _myWidget2() => Container(); // LINT

  Container get _aWidget2 => Container(); // LINT
}

class OneWidget extends StatefulWidget {
  @override
  State createState() => OneWidgetState(); // OK

  Widget build() => Container(); // LINT
}

class OneWidgetState extends State<OneWidget> {
  @override
  Widget build(BuildContext context) { // OK
    return Container();
  }

  String notImportant() => 'hey'; // OK

  Widget yourWidget() { // LINT
    return Container();
  }

  Widget myWidget() => Container(); // LINT

  Widget _myWidget() => Container(); // LINT

  Widget get _aWidget => Container(); // LINT

  Container yourWidget2() { // LINT
    return Container();
  }

  Container myWidget2() => Container(); // LINT

  Container _myWidget2() => Container(); // LINT

  Container get _aWidget2 => Container(); // LINT
}

class Cat {
  Widget build() => Container(); // LINT
}

Widget globalFunction() => Container(); // LINT

Widget get globalField => Container(); // LINT
