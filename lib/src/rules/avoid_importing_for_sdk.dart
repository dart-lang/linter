// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.avoid_importing_for_sdk;

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/generated/resolver.dart';
import 'package:linter/src/linter.dart';

const desc = r'Avoid importing just for the SDK';

const details = r'''
**AVOID** importing libraries just for Dart SDK members.

**BAD:**
```
import 'package:angular2/angular2.dart';

String s = 'just a String';
```

**GOOD:**
```
String s = 'just a String';
```
''';

class AvoidImportingForSdk extends LintRule {
  AvoidImportingForSdk()
      : super(
            name: 'avoid_importing_for_sdk',
            description: desc,
            details: details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  final LintRule rule;

  Visitor(this.rule);

  @override
  visitCompilationUnit(CompilationUnit node) {
    // Gather used imported elements.
    LibraryElement library = node?.element?.library;
    var _usedElementsHelper = new GatherUsedImportedElementsVisitor(library);
    node.accept(_usedElementsHelper);

    var x = new SdkImportsVerifier();
    x.addImports(node);
    x.removeUsedElements(_usedElementsHelper.usedElements);
    x.generateUnnecessaryImportForSdkHints(rule);
  }
}

class SdkImportsVerifier extends BaseImportsVerifier {
  /// A map of [ImportDirective]s that the current library imports, but does not
  /// use (except for exported Dart SDK elements), and the Dart SDK libraries
  /// that they provide.
  ///
  /// When an SDK identifier (inside dart:*) is visited by this visitor, and an
  /// import has been identified as providing that identifier's library, then
  /// the identifier's library is added to the import's set.
  ///
  /// When a non-SDK identifier (outside of dart:*) is visited by this visitor
  /// and an import has been identified as being used by the library, the
  /// [ImportDirective] is removed as a key in this map. After all the sources
  /// in the library have been evaluated, this map represents the set of
  /// unnecessary imports, only used for their exported Dart SDK elements. Each
  /// value represents the set of libraries that need to be imported instead of
  /// the current ImportDirective that has exported them.
  ///
  /// See [_updateUnnecessaryImportsForSdk].
  final HashMap<ImportDirective, Set<LibraryElement>>
      _unnecessaryImportsForSdk =
      new HashMap<ImportDirective, Set<LibraryElement>>();

  @override
  void addImport(ImportDirective directive) {
    _unnecessaryImportsForSdk[directive] = new HashSet<LibraryElement>();
  }

  @override
  boolean allImportsAreHandled() => _unnecessaryImportsForSdk.isEmpty;

  @override
  void handlePrefixedImport(
      PrefixElement _, List<Element> elements, ImportDirective directive) {
    for (Element element in elements) {
      _updateUnnecessaryImportsForSdk(directive, element.library);
    }
  }

  @override
  void handleSinglyImportedElement(
      Element element, ImportDirective directive) {
    _updateUnnecessaryImportsForSdk(directive, element.library);
  }

  @override
  void handleMultiplyImportedElement(
      Element element, ImportDirective directive, Namespace namespace) {
    String name = element.displayName;
    if (directive.prefix != null) {
      name = "${directive.prefix.name}.$name";
    }
    if (namespace != null && namespace.get(name) != null) {
      _updateUnnecessaryImportsForSdk(directive, element.library);
    }
  }

  void _updateUnnecessaryImportsForSdk(
      ImportDirective importDirective, LibraryElement library) {
    if (!_unnecessaryImportsForSdk.containsKey(importDirective)) {
      // Nothing to do; [importDirective] was removed from the map earlier,
      // because it is a legitimate import.
      return;
    }
    if (library.isInSdk) {
      // [library] is in the Dart SDK, but was provided by [importDirective].
      // Suspicous. Add [library] to [importDirective]'s list in the map, so
      // that we may suggest a better library to import.
      _unnecessaryImportsForSdk[importDirective].add(library);
    } else {
      // [library] is not in the Dart SDK, so [importDirective] is _not_
      // unnecessary. Remove it entirely from the map.
      _unnecessaryImportsForSdk.remove(importDirective);
    }
  }

  /// Report an [HintCode.UNNECESSARY_IMPORT_FOR_SDK] hint for each unnecessary
  /// import that is only being used for the SDK elements that it exports.
  ///
  /// Only call this method after all of the compilation units have been visited
  /// by this visitor.
  ///
  /// @param errorReporter the error reporter used to report the set of
  ///          [HintCode.UNNECESSARY_IMPORT_FOR_SDK] hints
  void generateUnnecessaryImportForSdkHints(LintRule rule) {
    _unnecessaryImportsForSdk.forEach((ImportDirective import, Set libraries) {
      // Check that the import isn't Dart SDK.
      ImportElement importElement = import.element;
      if (importElement != null) {
        LibraryElement libraryElement = importElement.importedLibrary;
        if (libraryElement != null && libraryElement.isInSdk) {
          return;
        }
      }
      if (libraries.isEmpty) {
        // No elements from the Dart SDK were found through this import.
        return;
      }
      var usedSdkLibraries = libraries
          .map((library) => library.identifier.toString()).join(", ");
      rule.reportLint(import);
    });
  }
}
