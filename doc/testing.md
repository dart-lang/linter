# Testing against Flutter

When validating a new lint or experimenting with new language experiments, testing the linter
against flutter is recommended to help expose false positives and other unexpected behavior.

## Try-Bot testing
1. update the `"linter_tag"` in the SDK [`DEPS`](https://github.com/dart-lang/sdk/blob/master/DEPS)
   to point to your linter commit
2. add “flutter-analyze-try” to your chosen try-jobs
