// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N avoid_large_ints`

final i = 1; //OK
final min = -9007199254740991; //OK
final minErr = -9007199254740992; //LINT
final max = 9007199254740991; //OK
final maxErr = 9007199254740992; //LINT
