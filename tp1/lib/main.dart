import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp1/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp1/player_page.dart';
import 'package:tp1/stats_class.dart';
import 'package:tp1/team_page.dart';
import 'package:tp1/fav_page.dart';
import 'package:tp1/about_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Stats don't lie 🏀",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(200, 16, 46, 1)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<PlayerStats> favorites = [];

  MyAppState() {
    _loadFavorites();
  }

  void toggleFavorite(PlayerStats player) {
    bool isFavorite = favorites.any((p) => p.playerId == player.playerId);
    if (isFavorite) {
      favorites.removeWhere((p) => p.playerId == player.playerId);
      player.liked = false;
    } else {
      favorites.add(player);
      player.liked = true;
    }
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favList = favorites.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('favorites', favList);
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favList = prefs.getStringList('favorites');
    if (favList != null) {
      favorites = favList.map((favJson) => PlayerStats.fromJson(jsonDecode(favJson))).toList();
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool _logoLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/logo.png'), context).then((_) {
      setState(() {
        _logoLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_logoLoaded) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = PlayerPage();
        break;
      case 2:
        page = TeamPage();
        break;
      case 3:
        page = FavPage();
        break;
      case 4:
        page = AboutPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(29, 66, 138, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
