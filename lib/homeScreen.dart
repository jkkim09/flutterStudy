import 'package:flutter/material.dart';
import 'package:fluttertest/provider/count_provider.dart';
import 'package:fluttertest/screens/first.dart';
import 'package:fluttertest/screens/fourth.dart';
import 'package:fluttertest/screens/home.dart';
import 'package:fluttertest/screens/second.dart';

class HomeScreen extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _children = [Home(), First(), Second(), Fourth()];
  final List<String> _chilcTitle = ['Page1', 'Page2', 'Page3', 'Page4'];
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chilcTitle[_selectedIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white.withOpacity(.60),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        currentIndex: _selectedIndex, //현재 선택된 Index
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            label: 'Favorites',
            icon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(
            label: 'Music',
            icon: Icon(Icons.music_note),
          ),
          BottomNavigationBarItem(
            label: 'Places',
            icon: Icon(Icons.location_on),
          ),
          BottomNavigationBarItem(
            label: 'News',
            icon: Icon(Icons.library_books),
          ),
        ],
      ),
      body: Center(
        child: _children[_selectedIndex],
      ),
    );
  }
}
