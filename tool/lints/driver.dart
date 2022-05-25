// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/generated/engine.dart' // ignore: implementation_imports
    show AnalysisErrorInfoImpl, AnalysisOptionsImpl;
import 'package:analyzer/src/lint/linter.dart'; // ignore: implementation_imports
import 'package:analyzer/src/lint/registry.dart'; // ignore: implementation_imports
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/formatter.dart';
import 'package:linter/src/rules.dart'; // ignore: implementation_imports
import 'package:path/path.dart' as path;

import 'rules/visit_registered_nodes.dart';

void main() {
  var rules =
      path.normalize(io.File(path.join('lib', 'src', 'rules')).absolute.path);
  Driver([VisitRegisteredNodes()]).analyze([rules]);
}

class Driver {
  Logger logger = Logger.standard();

  List<LintRule> lints;
  bool silent = false;

  Driver(this.lints);

  Future analyze(List<String> sources,
      {bool displayTiming = false}) {
    var analysisFuture = _analyze(sources);
    if (!displayTiming) return analysisFuture;

    var stopwatch = Stopwatch()..start();
    return analysisFuture.then((value) {
      print(
          '(Elapsed time: ${Duration(milliseconds: stopwatch.elapsedMilliseconds)})');
    });
  }

  Future _analyze(List<String> sources) async {
    if (sources.isEmpty) {
      _print('Specify one or more files and directories.');
      return;
    }
    ResourceProvider resourceProvider = PhysicalResourceProvider.INSTANCE;
    await _analyzeFiles(resourceProvider, sources);
    _print('Finished.');
  }

  Future _analyzeFiles(
      ResourceProvider resourceProvider, List<String> analysisRoots) async {
    _print('Analyzing...');

    // Register our checks.
    lints.forEach(Registry.ruleRegistry.register);

    for (var root in analysisRoots) {
      var collection = AnalysisContextCollection(
        includedPaths: [root],
        resourceProvider: resourceProvider,
      );

      var errors = <AnalysisErrorInfo>[];

      for (var context in collection.contexts) {
        // Add lints.
        var options = context.analysisOptions as AnalysisOptionsImpl;
        options.lintRules = context.analysisOptions.lintRules.toList();
        lints.forEach(options.lintRules.add);
        options.lint = true;

        for (var filePath in context.contextRoot.analyzedFiles()) {
          if (isDartFileName(filePath)) {
            try {
              var result = await context.currentSession.getErrors(filePath);
              if (result is ErrorsResult) {
                if (result.errors.isNotEmpty) {
                  errors.add(AnalysisErrorInfoImpl(result.errors, result.lineInfo));
                }

              }
            } on Exception catch (e) {
              _print('Exception caught analyzing: $filePath');
              _print(e.toString());
            }
          }
        }
      }
      // errors.forEach(print);

      ReportFormatter(errors, _TodoFilter(), io.stdout).write();
    }
  }



  /// Pass the following [msg] to the [logger] instance iff [silent] is false.
  void _print(String msg) {
    if (!silent) {
      logger.stdout(msg);
    }
  }

  /// Returns `true` if this [fileName] is a Dart file.
  static bool isDartFileName(String fileName) => fileName.endsWith('.dart');
}

class _TodoFilter extends LintFilter {
  @override
  bool filter(AnalysisError lint) => lint.errorCode.name == 'TODO';
}