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

// State with setState
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

// State with field
class MyWidget3 extends StatefulWidget // OK
{
  const MyWidget3({super.key});

  @override
  State<MyWidget3> createState() => _MyWidget3State();
}

class _MyWidget3State extends State<MyWidget3> {
  final int i = 2;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// State public
class MyWidget4 extends StatefulWidget // OK
{
  const MyWidget4({super.key});

  @override
  State<MyWidget4> createState() => MyWidget4State();
}

class MyWidget4State extends State<MyWidget4> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// extends other StatefulWidget
class MyWidget5Parent extends StatefulWidget {
  const MyWidget5Parent({super.key});

  @override
  State<MyWidget5Parent> createState() => MyWidget5ParentState();
}

class MyWidget5ParentState extends State<MyWidget5Parent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MyWidget5 extends MyWidget5Parent // OK
{
  const MyWidget5({super.key});

  @override
  State<MyWidget5> createState() => _MyWidget5State();
}

class _MyWidget5State extends State<MyWidget5> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Stateful in the widget name
class MyStatefulWidget6 extends StatefulWidget // OK
{
  const MyStatefulWidget6({super.key});

  @override
  State<MyStatefulWidget6> createState() => _MyStatefulWidget6State();
}

class _MyStatefulWidget6State extends State<MyStatefulWidget6> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// State with mounted
class MyWidget7 extends StatefulWidget // OK
{
  const MyWidget7({super.key});

  @override
  State<MyWidget7> createState() => _MyWidget7State();
}

class _MyWidget7State extends State<MyWidget7> {
  @override
  Widget build(BuildContext context) {
    if (mounted) {}
    return Container();
  }
}

// State with widget access
class MyWidget8 extends StatefulWidget // LINT
{
  const MyWidget8({super.key});
  final bool b = true;

  @override
  State<MyWidget8> createState() => _MyWidget8State();
}

class _MyWidget8State extends State<MyWidget8> {
  @override
  Widget build(BuildContext context) {
    if (widget.b) {}
    return Container();
  }
}