// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N unnecessary_stateful_widgets`

import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget // LINT
{
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GoodWidget extends StatelessWidget // OK
{
  const GoodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// State with mixin
class MyWidget2 extends StatefulWidget // OK
{
  const MyWidget2({super.key});

  @override
  State<MyWidget2> createState() => _MyWidget2State();
}

class _MyWidget2State extends State<MyWidget2> {
  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Container();
  }
}
