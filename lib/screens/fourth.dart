import 'package:flutter/cupertino.dart';
import 'package:fluttertest/widgetUI/widget_ui_demo.dart';
import 'package:flutter/foundation.dart';

class Fourth extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Fourth> {
  @override
  void initState() {
    super.initState();
    debugPrint('movieTitle:');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: WidgetUIDemo(),
    );
  }
}
