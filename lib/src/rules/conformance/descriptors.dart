// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Class representing a pair of a type and a member on that type.
abstract class MemberDescriptor {
  String get type;
  String get member;

  /// Whether or not this descriptor contains a native type and member.
  bool get isNative;

  /// Whether or not this descriptor contains a `dart:html` type and member.
  bool get isDartHtml;
}

class NativeMemberDescriptor extends MemberDescriptor {
  @override
  final String type;
  @override
  final String member;

  NativeMemberDescriptor({this.type = '', this.member = ''});

  @override
  bool get isNative => true;

  @override
  bool get isDartHtml => false;
}

class DartHtmlMemberDescriptor extends MemberDescriptor {
  @override
  final String type;
  @override
  final String member;

  DartHtmlMemberDescriptor({this.type = '', this.member = ''});

  @override
  bool get isNative => false;

  @override
  bool get isDartHtml => true;
}
