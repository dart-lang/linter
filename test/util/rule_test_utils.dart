// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart' as file_system;
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:linter/src/analyzer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../mock_sdk.dart';

Annotation extractAnnotation(String line) {
  int index = line.indexOf(RegExp(r'(//|#)[ ]?LINT'));

  // Grab the first comment to see if there's one preceding the annotation.
  // Check for '#' first to allow for lints on dartdocs.
  int comment = line.indexOf('#');
  if (comment == -1) {
    comment = line.indexOf('//');
  }

  if (index > -1 && comment == index) {
    int column;
    int length;
    var annotation = line.substring(index);
    var leftBrace = annotation.indexOf('[');
    if (leftBrace != -1) {
      var sep = annotation.indexOf(':');
      column = int.parse(annotation.substring(leftBrace + 1, sep));
      var rightBrace = annotation.indexOf(']');
      length = int.parse(annotation.substring(sep + 1, rightBrace));
    }

    int msgIndex = annotation.indexOf(']') + 1;
    if (msgIndex < 1) {
      msgIndex = annotation.indexOf('T') + 1;
    }
    String msg;
    if (msgIndex < line.length) {
      msg = line.substring(index + msgIndex).trim();
      if (msg.isEmpty) {
        msg = null;
      }
    }
    return Annotation.forLint(msg, column, length);
  }
  return null;
}

AnnotationMatcher matchesAnnotation(
        String message, ErrorType type, int lineNumber) =>
    AnnotationMatcher(Annotation(message, type, lineNumber));

/// Information about a 'LINT' annotation/comment.
class Annotation implements Comparable<Annotation> {
  final int column;
  final int length;
  final String message;
  final ErrorType type;
  int lineNumber;

  Annotation(this.message, this.type, this.lineNumber,
      {this.column, this.length});

  Annotation.forError(AnalysisError error, LineInfo lineInfo)
      : this(error.message, error.errorCode.type,
            lineInfo.getLocation(error.offset).lineNumber,
            column: lineInfo.getLocation(error.offset).columnNumber,
            length: error.length);

  Annotation.forLint([String message, int column, int length])
      : this(message, ErrorType.LINT, null, column: column, length: length);

  @override
  int compareTo(Annotation other) {
    if (lineNumber != other.lineNumber) {
      return lineNumber - other.lineNumber;
    } else if (column != other.column) {
      return column - other.column;
    }
    return message.compareTo(other.message);
  }

  @override
  String toString() =>
      '[$type]: "$message" (line: $lineNumber) - [$column:$length]';
}

class AnnotationMatcher extends Matcher {
  final Annotation _expected;

  AnnotationMatcher(this._expected);

  @override
  Description describe(Description description) =>
      description.addDescriptionOf(_expected);

  @override
  bool matches(item, Map matchState) => item is Annotation && _matches(item);

  bool _matches(Annotation other) {
    // Only test messages if they're specified in the expectation
    if (_expected.message != null) {
      if (_expected.message != other.message) {
        return false;
      }
    }
    // Similarly for highlighting
    if (_expected.column != null) {
      if (_expected.column != other.column ||
          _expected.length != other.length) {
        return false;
      }
    }
    return _expected.type == other.type &&
        _expected.lineNumber == other.lineNumber;
  }
}

/// Builds the [DartLinter] with appropriate mock SDK, resource providers, and
/// package config path.
DartLinter buildDriver(String ruleName, File file, {String analysisOptions}) {
  LintRule rule = Registry.ruleRegistry[ruleName];
  if (rule == null) {
    fail('rule `$ruleName` is not registered, and cannot be tested.');
  }

  MemoryResourceProvider memoryResourceProvider = MemoryResourceProvider(
      context: PhysicalResourceProvider.INSTANCE.pathContext);
  _TestResourceProvider resourceProvider =
      _TestResourceProvider(memoryResourceProvider);

  p.Context pathContext = memoryResourceProvider.pathContext;
  String packageConfigPath = memoryResourceProvider.convertPath(pathContext
      .join(pathContext.dirname(file.absolute.path), '.mock_packages'));
  if (!resourceProvider.getFile(packageConfigPath).exists) {
    packageConfigPath = null;
  }

  LinterOptions options = LinterOptions([rule], analysisOptions)
    ..mockSdk = MockSdk(memoryResourceProvider)
    ..resourceProvider = resourceProvider
    ..packageConfigPath = packageConfigPath;

  return DartLinter(options);
}

/// A resource provider that accesses entities in a MemoryResourceProvider,
/// falling back to the PhysicalResourceProvider when they don't exist.
class _TestResourceProvider extends PhysicalResourceProvider {
  MemoryResourceProvider memoryResourceProvider;

  _TestResourceProvider(this.memoryResourceProvider) : super(null);

  @override
  file_system.File getFile(String path) {
    file_system.File file = memoryResourceProvider.getFile(path);
    return file.exists ? file : super.getFile(path);
  }

  @override
  file_system.Folder getFolder(String path) {
    file_system.Folder folder = memoryResourceProvider.getFolder(path);
    return folder.exists ? folder : super.getFolder(path);
  }

  @override
  file_system.Resource getResource(String path) {
    file_system.Resource resource = memoryResourceProvider.getResource(path);
    return resource.exists ? resource : super.getResource(path);
  }
}
