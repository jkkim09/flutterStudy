import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertest/provider/viewMode_provider.dart';
import 'package:provider/provider.dart';

class Fourth extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Fourth> {
  ViewModeProvider _viewModeProvider;
  @override
  void initState() {
    super.initState();
    debugPrint('movieTitle:');
  }

  @override
  Widget build(BuildContext context) {
    _viewModeProvider = Provider.of<ViewModeProvider>(context);
    return Column(
      children: [
        InkWell(
          child: Text('다크 모드'),
          onTap: () {
            _viewModeProvider.setDark();
          },
        ),
        InkWell(
            child: Text('라이트 모드'),
            onTap: () {
              _viewModeProvider.setWhite();
            })
      ],
    );
  }
}
