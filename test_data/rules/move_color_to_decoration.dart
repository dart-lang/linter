// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `dart test -N move_color_to_decoration`

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';


Widget onlyColor() {
  return Container( // OK
    color: Colors.transparent,
  );
}

Widget onlyDecoration() {
  return Container( // OK
    decoration: BoxDecoration(),
  );
}

Widget colorAndDecoration() {
  return Container( // LINT
    color: Colors.transparent,
    decoration: BoxDecoration(),
  );
}

Widget bothNull() {
  return Container( // OK
    color: null,
    decoration: null,
  );
}

Widget colorIsNull() {
  return Container( // OK
    color: null,
    decoration: BoxDecoration(),
  );
}

Widget decorationIsNull() {
  return Container( // OK
    color: Colors.transparent,
    decoration: null,
  );
}

Widget colorWithChild() {
  return Container( // OK
    color: Colors.transparent,
    child: SizedBox(),
  );
}

Widget withThirdNonNullArgument() {
  return Container( // LINT
    color: Colors.transparent,
    decoration: BoxDecoration(),
    child: SizedBox(),
  );
}
