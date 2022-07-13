# Pushing a new Release

## Preparing a Release

Before releasing there are a few boxes to tick off.

* [ ] Is there a [milestone plan](https://github.com/dart-lang/linter/issues?q=is%3Aopen+is%3Aissue+label%3Amilestone-plan) for the release? If so, has it been updated?
* [ ] Is the changelog up to date? (Look at commit history to verify.)
* [ ] Does the `AUTHORS` file need updating?
* [ ] Spot check new lint rules for [naming consistency](https://github.com/dart-lang/linter/blob/main/doc/WritingLints.MD).  Rename as needed.

## Doing the Push

First, make sure the build is GREEN.

[![Build Status](https://github.com/dart-lang/linter/workflows/linter/badge.svg)](https://github.com/dart-lang/linter/actions)

All clear?  Then:

  1. Update `pubspec.yaml` with a version bump and `CHANGELOG.md` accordingly.
  2. Tag a release [branch](https://github.com/dart-lang/linter/releases).
  3. Publish to `pub.dev` (`dart pub lish`); heed all warnings that are not test data related!
  4. Update SDK `DEPS`.

You're done!
