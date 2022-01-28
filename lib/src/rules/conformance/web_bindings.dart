// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import '../../ast.dart';
import 'descriptors.dart';

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

/// Class that queries and caches the `dart:html` library's bindings.
///
/// `dart:html` 'binds' native types to certain types (annotated with `@Native`)
/// in order to provide Dart interfaces for them. This class contains methods to
/// query back and forth between the native type/member
class DartHtmlBindings {
  // TODO(srujzs): The following maps are roughly a couple MB (depending on
  // encoding), as there are hundreds of types bound in `dart:html` with a
  // varying number of members per type. If this is too large, an alternative
  // would be to do a lookup in the AST every time, but this adds considerable
  // computation time for every rule.

  /// Mapping of native types that are bound in `dart:html` to a map of their
  /// members to those members' Dart names.
  final Map<String, Map<String, String>> _nativeTypeToDartMembers = {};

  /// Mapping of types in `dart:html` to a map of their members to the native
  /// members that those members bind to.
  final Map<String, Map<String, String>> _dartTypeToNativeMembers = {};

  /// Mapping of types in `dart:html` to the native types they bind.
  final Map<String, List<String>> _dartTypeToNativeTypes = {};

  /// Whether or not we've processed `dart:html` bindings yet.
  bool _computedBindings = false;

  /// The library used to process the bindings.
  LibraryElement? _library;

  DartHtmlBindings();

  /// Set library using the compilation unit of [node] if needed for computing
  /// `dart:html` bindings later.
  ///
  /// Once it's used to compute bindings, the value does not change.
  void cacheLibrary(AstNode node) {
    if (_computedBindings) return;
    var library = getCompilationUnit(node)?.declaredElement?.library;
    if (library != null) _library = library;
  }

  /// Computes and caches native member bindings from `dart:html`.
  ///
  /// Specifically, computes the three maps above. Given the current library,
  /// uses its imports and exports to find the web libraries. This mapping is
  /// necessary if the library dynamically calls a setter, since the member
  /// name may match a renamed member in `dart:html`, and we would have no
  /// reference to that binding without this processing. It's also necessary to
  /// determine whether a native type could be used with non-static interop.
  void _computeHtmlBindings() {
    if (_computedBindings || _library == null) return;

    // TODO(srujzs): This is expensive. If we visit a lot of libraries before we
    // find one that imports the web libraries, this will be unperformant.
    // Ideally, we should only do any processing once. We should see if we can
    // use some form of a summary of the `dart:html` libraries as they will stay
    // static across SDK versions.
    List<LibraryElement> visited = <LibraryElement>[];
    visited.add(_library!);
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
          var dartMember = member.displayName;
          var nativeMember = _getJsNameValue(member.metadata) ?? dartMember;

          nativePropToDartProp[nativeMember] = dartMember;
          for (var nativeType in nativeTypes) {
            _nativeTypeToDartMembers[nativeType] = nativePropToDartProp;
          }

          dartPropToNativeProp[dartMember] = nativeMember;
          _dartTypeToNativeMembers[cls.name] = dartPropToNativeProp;
        }
      }
    }
    _computedBindings = true;
  }

  /// Gets the web library member bound to the native type and member in
  /// [descriptor].
  ///
  /// If [descriptor] is not a native pair or there is no associated member for
  /// the type and member, returns the empty string.
  String getWebLibraryMember(MemberDescriptor descriptor) {
    if (!descriptor.isNative) return '';
    _computeHtmlBindings();
    return _nativeTypeToDartMembers[descriptor.type]?[descriptor.member] ?? '';
  }

  /// Gets the native member that is bound by the `dart:html` type and member in
  /// [descriptor].
  ///
  /// If [descriptor] is not a `dart:html` pair or there is no associated member
  /// for the type and member, returns the empty string.
  String getNativeMemberBinding(MemberDescriptor descriptor) {
    if (!descriptor.isDartHtml) return '';
    _computeHtmlBindings();
    return _dartTypeToNativeMembers[descriptor.type]?[descriptor.member] ?? '';
  }

  /// Gets the native types bound to the `dart:html` type in [descriptor].
  ///
  /// If [descriptor] is not a `dart:html` pair or there is not a `@Native`
  /// class in `dart:html` for that type, returns the empty list.
  List<String> getBoundNativeTypes(MemberDescriptor descriptor) {
    if (!descriptor.isDartHtml) return [];
    _computeHtmlBindings();
    return _dartTypeToNativeTypes[descriptor.type] ?? [];
  }

  /// Returns whether or not the native type in [descriptor] is bound to a
  /// `@Native` type in `dart:html`.
  ///
  /// If [descriptor] is not a native pair or there is no associated member for
  /// the type and member, returns false.
  bool hasDartHtmlBinding(MemberDescriptor descriptor) {
    if (!descriptor.isNative) return false;
    _computeHtmlBindings();
    return _nativeTypeToDartMembers.containsKey(descriptor.type);
  }
}
