// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular2/di.dart';

@Component(templateUrl: 'someUrl')
class TemplateUrlComponent {}

@Component(template: '<some-node></some-node>')
class TemplateComponent {}

@Component(templateUrl: 'someUrl', template: '<some-node></some-node>') // LINT
class TemplateAndTemplateUrlComponent {}

@Component() // LINT
class NoTemplateComponent {}
