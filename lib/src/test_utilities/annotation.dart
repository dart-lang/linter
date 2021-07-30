// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:analyzer/source/line_info.dart';

final lintRE = RegExp(
    r'(//|#) ?LINT( FAILING)?( \[([\-+]\d+)?(,?(\d+):(\d+))?\])?( (.*))?$');
final okFailingRE = RegExp(r'(//|#).*FAILING');

Annotation? extractAnnotation(int lineNumber, String line) {
  var match = lintRE.firstMatch(line);
  if (match == null) {
    match = okFailingRE.firstMatch(line);
    if (match == null) return null;

    // ignore commented out lines
    var index = match.start;
    var comment = match[1]!;
    if (line.indexOf(comment) != index) return null;

    return Annotation.forLint(null, null, null, lint: false, failing: true)
      ..lineNumber = lineNumber;
  }

  // ignore lints on commented out lines
  var index = match.start;
  var comment = match[1]!;
  if (line.indexOf(comment) != index) return null;

  var failing = match[2] != null;
  var relativeLine = match[4].toInt() ?? 0;
  var column = match[6].toInt();
  var length = match[7].toInt();
  var message = match[9].toNullIfBlank();
  return Annotation.forLint(message, column, length, failing: failing)
    ..lineNumber = lineNumber + relativeLine;
}

/// Information about a 'LINT' annotation/comment.
class Annotation implements Comparable<Annotation> {
  final int? column;
  final int? length;
  final String? message;
  final ErrorType type;
  int? lineNumber;

  /// `LINT` or failing `OK`
  final bool lint;
  final bool failing;

  Annotation(this.message, this.type, this.lineNumber,
      {this.column, this.length, this.lint = true, this.failing = false});

  Annotation.forError(AnalysisError error, LineInfo lineInfo)
      : this(error.message, error.errorCode.type,
            lineInfo.getLocation(error.offset).lineNumber,
            column: lineInfo.getLocation(error.offset).columnNumber,
            length: error.length);

  Annotation.forLint(String? message, int? column, int? length,
      {bool lint = true, bool failing = false})
      : this(message, ErrorType.LINT, null,
            column: column, length: length, lint: lint, failing: failing);

  @override
  int compareTo(Annotation other) {
    if (lineNumber != other.lineNumber) {
      return lineNumber! - other.lineNumber!;
    } else if (column != other.column) {
      return column! - other.column!;
    }
    return message!.compareTo(other.message!);
  }

  @override
  String toString() =>
      '[$type]: "$message" (line: $lineNumber) - [$column:$length]';
}

extension on String? {
  int? toInt() => this == null ? null : int.parse(this!);
  String? toNullIfBlank() =>
      this == null || this!.trim().isEmpty == true ? null : this;
}
