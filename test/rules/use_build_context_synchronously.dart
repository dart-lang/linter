// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N use_build_context_synchronously`

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  @override
  State createState() => _MyState();
}

class _MyState extends State<MyWidget> {
  void methodUsingStateContext1() async {
    // Uses context from State.
    Navigator.of(context).pushNamed('routeName'); // OK

    await Future<void>.delayed(Duration());

    // Not ok. Used after an async gap without checking mounted.
    Navigator.of(context).pushNamed('routeName'); // LINT
  }

  void methodUsingStateContext2() async {
    // Uses context from State.
    Navigator.of(context).pushNamed('routeName'); // OK

    await Future<void>.delayed(Duration());

    if (!mounted) return;

    // OK. mounted checked first.
    Navigator.of(context).pushNamed('routeName'); // OK
  }

  // Method given a build context to use.
  void methodWithBuildContextParameter1(BuildContext context) async {
    Navigator.of(context).pushNamed('routeName'); // OK

    await Future<void>.delayed(Duration());
    Navigator.of(context).pushNamed('routeName'); // LINT
  }

  // Same as above, but using a conditional path.
  void methodWithBuildContextParameter2(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Future<void>.delayed(Duration());
    }
    Navigator.of(context).pushNamed('routeName'); // LINT
  }

  // Mounted checks only protect State-provided contexts.
  void methodWithBuildContextParameter3(BuildContext context) async {
    Navigator.of(context).pushNamed('routeName'); // OK

    await Future<void>.delayed(Duration());

    if (!mounted) return;

    // Mounted doesn't cover provided context.
    Navigator.of(context).pushNamed('routeName'); // LINT
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}
