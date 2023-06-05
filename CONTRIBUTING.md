Contributing to the Linter
==========================

[![Build Status](https://github.com/dart-lang/linter/workflows/linter/badge.svg)](https://github.com/dart-lang/linter/actions)
![GitHub contributors](https://img.shields.io/github/contributors/dart-lang/linter.svg)


Want to contribute? Great! First, read this page (including the small print at
the end).

### Before you contribute

_See also: [Dart's code of conduct](https://dart.dev/code-of-conduct)_

Before we can use your code, you must sign the
[Google Individual Contributor License Agreement](https://cla.developers.google.com/about/google-individual)
(CLA), which you can do online. The CLA is necessary mainly because you own the
copyright to your changes, even after your contribution becomes part of our
codebase, so we need your permission to use and distribute your code. We also
need to be sure of various other things—for instance that you'll tell us if you
know that your code infringes on other people's patents. You don't have to sign
the CLA until after you've submitted your code for review and a member has
approved it, but you must do it before we can put your code into our codebase.

Before you start working on a larger contribution, you should get in touch with
us first through the issue tracker with your idea so that we can help out and
possibly guide you. Coordinating up front makes it much easier to avoid
frustration later on.

### Code reviews
All submissions, including submissions by project members, require review.

### File headers
All files in the project must start with the following header.

    // Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
    // for details. All rights reserved. Use of this source code is governed by a
    // BSD-style license that can be found in the LICENSE file.

### Mechanics
Contributing code is easy.

 * First, get the source by forking `https://github.com/dart-lang/linter` into your own GitHub account.
 * If you haven't configured your machine with an SSH key that's known to GitHub then follow the directions here: https://help.github.com/articles/generating-ssh-keys/.
 * `git clone git@github.com:<your_name_here>/linter.git`
 * `cd linter`
 * `git remote add upstream git@github.com:dart-lang/linter.git` (So that you fetch from the main repository, not your clone, when running git fetch et al.)

To start working on a patch:

 * `git fetch upstream`
 * `git checkout upstream/main -b name_of_your_branch`
 * Hack away.  (Before committing, please be sure and run `dart format` on modified files; our build will fail if you don't!)
 * `git commit -a -m "<your informative commit message>"`
 * `git push origin name_of_your_branch`

To send us a pull request:

 * `git pull-request` (if you are using [Hub](https://github.com/github/hub/)) or
  go to `https://github.com/dart-lang/linter` and click the
  "Compare & pull request" button
 * either explicitly name a reviewer in the GitHub UI or add their GitHub name in the pull request message body

Please make sure all your checkins have detailed commit messages explaining the patch and if a PR is *not* ready to land, consider making it clear in the description and/or prefixing the title with "WIP".

Please note that a few kinds of changes require a `CHANGELOG` entry. Notably, any change that:

1. adds a new lint
2. removes or deprecates a lint or
3. fundamentally changes the semantics of an existing lint

should have a short entry in the `CHANGELOG`. Feel free to bring up any questions in your PR.

Once you've gotten an LGTM from a project maintainer, submit your changes to the
`main` branch using one of the following methods:

* Wait for one of the project maintainers to submit it for you.
* Click the green "Merge pull request" button on the GitHub UI of your pull
  request (requires commit access)
* `git push upstream name_of_your_branch:main` (requires commit access)
* Having done all this, please make sure we have a good email address so we can credit you in our `AUTHORS` file.
* Thank you!

### The small print
Contributions made by corporations are covered by a different agreement than the
one above, the
[Software Grant and Corporate Contributor License Agreement](https://developers.google.com/open-source/cla/corporate).
