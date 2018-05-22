import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'framework.dart';

export 'package:flutter/painting.dart';

class AspectRatio extends SingleChildRenderObjectWidget {
  const AspectRatio({
    @required double aspectRatio,
    Key key,
    Widget child,
  });
}

class Center extends StatelessWidget {
  const Center({Key key, double heightFactor, Widget child});
}

class ClipRect extends SingleChildRenderObjectWidget {
  const ClipRect({Key key, Widget child}) : super(key: key, child: child);
  const ClipRect.rect({Key key, Widget child}) : super(key: key, child: child);
}

class Column extends Flex {
  Column({
    Key key,
    CrossAxisAlignment crossAxisAlignment: CrossAxisAlignment.center,
    List<Widget> children: const <Widget>[],
  });
}

class Expanded extends StatelessWidget {
  const Expanded({
    @required Widget child,
    Key key,
    int flex: 1,
  });
}

class Flex extends Widget {
  Flex({
    Key key,
    List<Widget> children: const <Widget>[],
  });
}

class Padding extends SingleChildRenderObjectWidget {
  final EdgeInsetsGeometry padding;

  const Padding({
    Key key,
    this.padding,
    Widget child,
  });
}

class Row extends Flex {
  Row({
    Key key,
    List<Widget> children: const <Widget>[],
  });
}

class Transform extends SingleChildRenderObjectWidget {
  const Transform({
    @required transform,
    Key key,
    origin,
    alignment,
    transformHitTests: true,
    Widget child,
  });
}
