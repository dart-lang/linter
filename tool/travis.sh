#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# DO NOT SUBMIT until recommenting this line.
#if [[ "$TRAVIS_EVENT_TYPE" = "cron" ]]
#then
  if [[ "$LINTER_BOT" = "fuzz" ]]
  then
    pub global activate dust
    # snapshot fuzzer for better performance
    SNAPSHOT="tool/fuzz.dart.snapshot"
    dart --snapshot=$SNAPSHOT --snapshot-kind=kernel tool/fuzz.dart

    # if a fuzz corpus already exists, then minify it
    if [[ -e "$SNAPSHOT.corpus" ]]
    then
      pub global run dust $SNAPSHOT --seed_dir $SNAPSHOT.corpus --corpus_dir $SNAPSHOT.corpus.new --count 0 --timeout 20 --vm_count 3
      rm -rf $SNAPSHOT.corpus
      mv $SNAPSHOT.corpus.new $SNAPSHOT.corpus
    fi

    
    # Fuzz the snapshot with the rule tests as a seed, with 1000 cases.
    timeout --preserve-status 35m pub global run dust $SNAPSHOT --seed_dir test/rules/ --count 1000 --timeout 20 --vm_count 3 || :

    # if any failures were detected, dust will return 1 and the bot will fail
  fi

  exit 0
#fi

if [ "$LINTER_BOT" = "release" ]; then
  echo "Validating release..."
  dart tool/bot/version_check.dart

elif [ "$LINTER_BOT" = "benchmark" ]; then
  echo "Running the linter benchmark..."

  # The actual lints can have errors - we don't want to fail the benchmark bot.
  set +e

  # Benchmark linter with all lints enabled.
  dart bin/linter.dart --benchmark -q -c example/all.yaml .

  # Check for errors encountered during analysis / benchmarking and fail as appropriate.
  if [ $? -eq 63 ];  then
    echo ""
    echo "Error occurred while benchmarking"
    exit 1
  fi

elif [ "$LINTER_BOT" = "pana_baseline" ]; then
  echo "Checking the linter pana baseline..."

  dart tool/pana_baseline.dart

else
  echo "Running main linter bot"

  # Verify that the libraries are error free.
  dartanalyzer --fatal-warnings \
    bin/linter.dart \
    lib/src/rules.dart \
    test/all.dart

  echo ""

  # Run the tests.
  dart --enable-asserts test/all.dart
  
  # Install dart_coveralls; gather and send coverage data.
  if [ "$COVERALLS_TOKEN" ]; then
    pub global activate dart_coveralls
    pub global run dart_coveralls report \
      --token $COVERALLS_TOKEN \
      --retry 2 \
      --exclude-test-files \
      test/all.dart
  fi
fi
