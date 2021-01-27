import 'package:flutter/cupertino.dart';
import 'package:fluttertest/widgetUI/test_sound/record_to_stream_example.dart';

class Second extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RecordToStreamExample(),
    );
  }
}
