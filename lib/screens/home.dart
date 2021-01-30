import 'package:flutter/material.dart';
import 'package:fluttertest/provider/count_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Counter Build");
    // _countProvider = Provider.of<CountProvider>(context);
    return Consumer<CountProvider>(builder: (context, provider, child) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            provider.add();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '터치하면 Counter 증가',
              ),
              // Text('$_counter'),
              Text(provider.count.toString()),
              InkWell(
                child: Text('reset'),
                onTap: () {
                  print("test");
                  provider.setCounter(0);
                },
              )
            ],
          ),
        ),
      );
    });
  }
}
