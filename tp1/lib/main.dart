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
import 'package:tp1/utils.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadAssetManifest();
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
  bool _logoLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/logo.png'), context).then((_) {
      if (!mounted) return;
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

    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
        body: TabBarView(
          children: [
        HomePage(),
        PlayerPage(),
        TeamPage(),
        FavPage(),
        AboutPage(),
          ],
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          child: TabBar(
        tabs: [
          Tab(
            icon: Icon(Icons.home),
            child: FittedBox(child: Text('Accueil')),
          ),
          Tab(
            icon: Icon(Icons.person),
            child: FittedBox(child: Text('Joueurs')),
          ),
          Tab(
            icon: Icon(Icons.group),
            child: FittedBox(child: Text('Équipes')),
          ),
          Tab(
            icon: Icon(Icons.star),
            child: FittedBox(child: Text('Favoris')),
          ),
          Tab(
            icon: Icon(Icons.info),
            child: FittedBox(child: Text('À propos')),
          ),
        ],
        indicatorColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
