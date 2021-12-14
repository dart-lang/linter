// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/rules/conformance/banned_property_write.dart';

class DisallowSetHtmlDocumentTitle extends BannedPropertyWrite {
  DisallowSetHtmlDocumentTitle()
      : super.withDartHtmlTypes(
            name: 'disallow_set_htmldocument_title',
            description: 'Avoid setting HtmlDocument.title.',
            details: 'This lint is only meant for testing conformance rules. '
                'This lint should not be published.',
            dartHtmlType: 'HtmlDocument',
            dartHtmlProperty: 'title');
}
