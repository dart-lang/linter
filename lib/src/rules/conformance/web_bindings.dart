// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

final String _dartJsHelperLibrary = '_js_helper';

final String _jsNameAnnotationName = 'JSName';
final String _nativeAnnotationName = 'Native';

final List<String> _dartHtmlLibraries = [
  'dart.dom.html',
  'dart.dom.indexed_db',
  'dart.dom.svg',
  'dart.dom.web_audio',
  'dart.dom.web_gl',
  'dart.dom.web_sql',
];

/// Returns whether [element] comes from one of the `dart:html` libraries that
/// contain native bindings.
bool fromDartHtml(Element element) =>
    _dartHtmlLibraries.contains(element.library?.name);

/// Returns all the underlying native types that this class corresponds to.
///
/// `@Native` annotations may contain multiple classes delimited by a comma. If
/// the class has a `@Native` annotation and has values, returns a list of
/// those. If the class has a `@Native` annotation and does not have any values,
/// it returns a list with just the Dart name. Otherwise, returns null.
List<String>? _getNativeTypes(ClassElement element) {
  for (var annotation in element.metadata) {
    var annotationElement = annotation.element;
    if (annotationElement is ConstructorElement &&
        annotationElement.enclosingElement.name == _nativeAnnotationName &&
        annotationElement.library.name == _dartJsHelperLibrary) {
      var value =
          annotation.computeConstantValue()?.getField('name')?.toStringValue();
      if (value != null && value.isNotEmpty) {
        return value.split(',');
      } else {
        return [element.name];
      }
    }
  }
  return null;
}

/// Returns the value in the `@JSName` annotation.
///
/// If the annotation exists and has a value, returns that value. Otherwise,
/// returns null.
String? _getJsNameValue(List<ElementAnnotation> metadata) {
  for (var annotation in metadata) {
    var annotationElement = annotation.element;
    if (annotationElement is ConstructorElement &&
        annotationElement.enclosingElement.name == _jsNameAnnotationName &&
        annotationElement.library.name == _dartJsHelperLibrary) {
      var value =
          annotation.computeConstantValue()?.getField('name')?.toStringValue();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
  }
  return null;
}

// TODO(srujzs): The following maps are roughly a couple MB (depending on
// encoding), as there are hundreds of types bound in `dart:html` with a varying
// number of properties per type. If this is too large, an alternative would be
// to do a lookup in the AST every time, but this adds considerable computation
// time for every rule.

// Mapping of native types that are bound in `dart:html` to a map of their
// properties to those properties' Dart names.
final Map<String, Map<String, String>> _nativeTypeToDartProperties = {};
// Mapping of types in `dart:html` to a map of their properties to the native
// properties that those properties bind to.
final Map<String, Map<String, String>> _dartTypeToNativeProperties = {};
// Mapping of types in `dart:html` to the native types they bind.
final Map<String, List<String>> _dartTypeToNativeTypes = {};

/// Computes and caches native property bindings from `dart:html`.
///
/// Specifically, computes the three maps above. Given the current [library],
/// uses its imports and exports to find the web libraries. This mapping is
/// necessary if the library dynamically calls a setter, since the property name
/// may match a renamed property in `dart:html`, and we would have no reference
/// to that binding without this processing. It's also necessary to determine
/// whether a native type could be used with non-static interop.
void computeHtmlBindings(LibraryElement? library) {
  // TODO(srujzs): This is expensive. If we visit a lot of libraries before we
  // find one that imports the web libraries, this will be unperformant.
  // Ideally, we should only do any processing once. We should see if we can use
  // some form of a summary of the `dart:html` libraries as they will stay
  // static across SDK versions.
  if (library == null || _nativeTypeToDartProperties.isNotEmpty) return;

  List<LibraryElement> visited = <LibraryElement>[];
  visited.add(library);
  List<LibraryElement> toProcess = <LibraryElement>[];

  // Fetch the elements for all the web libraries. Since they're all under
  // `dart:html`, the processing further down happens only once.
  for (int index = 0; index < visited.length; index++) {
    LibraryElement currLibrary = visited[index];
    if (_dartHtmlLibraries.contains(currLibrary.name) &&
        !toProcess.contains(currLibrary)) {
      toProcess.add(currLibrary);
    }
    for (LibraryElement lib in [
      ...currLibrary.importedLibraries,
      ...currLibrary.exportedLibraries
    ]) {
      if (!visited.contains(lib)) visited.add(lib);
    }
  }

  if (toProcess.isEmpty) return;

  for (var webLibrary in toProcess) {
    for (var cls in webLibrary.definingCompilationUnit.classes) {
      List<String> nativeTypes = _getNativeTypes(cls) ?? [cls.name];
      _dartTypeToNativeTypes[cls.name] = nativeTypes;

      Map<String, String> nativePropToDartProp = {};
      Map<String, String> dartPropToNativeProp = {};

      for (Element member in [...cls.fields, ...cls.accessors]) {
        // Only record external members as they map to the native names.
        if (member is ExecutableElement && !member.isExternal ||
            member is FieldElement && !member.isExternal) continue;
        if (member.isSynthetic || member.isPrivate) continue;
        // Use `displayName` to avoid setters appending `=` in `name`.
        var dartProperty = member.displayName;
        var nativeProperty = _getJsNameValue(member.metadata) ?? dartProperty;

        nativePropToDartProp[nativeProperty] = dartProperty;
        for (var nativeType in nativeTypes) {
          _nativeTypeToDartProperties[nativeType] = nativePropToDartProp;
        }

        dartPropToNativeProp[dartProperty] = nativeProperty;
        _dartTypeToNativeProperties[cls.name] = dartPropToNativeProp;
      }
    }
  }
}

/// Gets the web library property bound to [nativeType].[nativeMember].
///
/// If either inputs are null, or there is no associated member, returns null.
String? getWebLibraryMember({String? nativeType, String? nativeMember}) {
  if (_nativeTypeToDartProperties.containsKey(nativeType) &&
      _nativeTypeToDartProperties[nativeType]!.containsKey(nativeMember)) {
    return _nativeTypeToDartProperties[nativeType]![nativeMember];
  }
  return null;
}

/// Gets the native property that is bound by [dartType].[dartMember].
///
/// If either inputs are null, or there is no associated member, returns null.
String? getNativePropertyBinding({String? dartType, String? dartMember}) {
  if (_dartTypeToNativeProperties.containsKey(dartType) &&
      _dartTypeToNativeProperties[dartType]!.containsKey(dartMember)) {
    return _dartTypeToNativeProperties[dartType]![dartMember];
  }
  return dartMember;
}

/// Gets the native types bound to the `dart:html` type [dartType].
///
/// If [dartType] is null or is not a `@Native` class in `dart:html`, returns
/// null.
List<String>? getBoundNativeTypes({String? dartType}) {
  if (_dartTypeToNativeTypes.containsKey(dartType)) {
    return _dartTypeToNativeTypes[dartType];
  }
  return null;
}

/// Returns whether or not [nativeType] is bound to a `@Native` type in
/// `dart:html`.
bool hasDartHtmlBinding(String nativeType) =>
    _nativeTypeToDartProperties.containsKey(nativeType);
