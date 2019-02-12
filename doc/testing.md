# Testing against Flutter

When validating a new lint or experimenting with new language experiments, testing the linter
against flutter is recommended to help expose false positives and other unexpected behavior.

## Try-bot Testing
0. (If you haven't already, read the [contributing to Dart docs](https://github.com/dart-lang/sdk/blob/master/CONTRIBUTING.md),
   as you'll need to get the Dart SDK sources and create a pull request against the Dart SDK repo which uses a different
   process than we do here.)
1. Update the `"linter_tag"` in the SDK [`DEPS`](https://github.com/dart-lang/sdk/blob/master/DEPS)
   to point to your linter commit SHA-1 hash.
2. Upload your change (`git cl upload`) and navigate to it in a web browser. 
3. Add “flutter-analyze-try” to your chosen try-jobs.
4. Look at bot results and go from there...
