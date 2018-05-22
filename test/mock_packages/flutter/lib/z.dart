import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  final a = new TextStyle(fontSize: 10.0); // OK

  @override
  MyWidgetState createState() => new MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  final b = new TextStyle(fontSize: 20.0); // LINT

  @override
  Widget build(BuildContext context) => null;
}
