import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertest/homeScreen.dart';
import 'package:fluttertest/provider/viewMode_provider.dart';
import 'package:fluttertest/ui/views/clipper_view.dart';
import 'package:fluttertest/ui/views/painter_view.dart';
import 'package:provider/provider.dart';
import 'package:fluttertest/provider/count_provider.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  ViewModeProvider _viewModeProvider;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) {
              return CountProvider(0);
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              _viewModeProvider = ViewModeProvider(true);
              return _viewModeProvider;
            },
          )
        ],
        child: MaterialApp(
          home: new SplashScreen(),
          theme: ThemeData.dark(),
          routes: <String, WidgetBuilder>{
            '/HomeScreen': (BuildContext context) => new HomeScreen(),
            '/Wave': (BuildContext context) => new ClipperView(),
            '/Painter': (BuildContext context) => new PainterView(),
          },
        ));
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Image.asset(
          'images/google_flutter_logo.png',
          width: 158.9,
          height: 45.3,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
