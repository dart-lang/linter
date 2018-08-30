// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N flutter_style_todos`

// BAD
//TODO
// TODO
// TODO: bla
// TODO(user) remove
// TODO:(user): Button
// TODO(user) : We
/// nothing here
/// TODO(user): We
// TODO(#12357): Bad username

// GOOD
// TODO(user): We
// TODO(user-name): We
// TODO(user1,user2): We
