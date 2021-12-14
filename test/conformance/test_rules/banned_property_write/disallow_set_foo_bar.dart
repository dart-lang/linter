// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/rules/conformance/banned_property_write.dart';

class DisallowSetFooBar extends BannedPropertyWrite {
  DisallowSetFooBar()
      : super(
            name: 'disallow_set_foo_bar',
            description: 'Avoid setting Foo.bar.',
            details: 'This lint is only meant for testing conformance rules. '
                'This lint should not be published.',
            nativeType: 'Foo',
            nativeProperty: 'bar');
}
