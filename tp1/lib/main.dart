import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
        title: 'Media Management App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MediaPage();
        break;
      case 1:
        page = HomePage();
        break;
      case 2:
        page = AboutPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.photo),
            label: 'Media',
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('Home Page'),
    );
  }
}

class PlayerStats {
  final int playerId;
  final String player;
  final String team;
  final int game;
  final int min;
  final int points;
  final int assists;
  final int rebounds;
  final double fgPct;
  final double fg3Pct;
  final double ftPct;
  final int blk;
  final int stl;
  final int tov;
  final int oreb;
  final int dreb;
  final int pf;
  final String imageFileName;
  bool liked;

  PlayerStats({
    required this.playerId,
    required this.player,
    required this.team,
    required this.game,
    required this.min,
    required this.points,
    required this.assists,
    required this.rebounds,
    required this.fgPct,
    required this.fg3Pct,
    required this.ftPct,
    required this.blk,
    required this.stl,
    required this.tov,
    required this.oreb,
    required this.dreb,
    required this.pf,
    required this.imageFileName,
    required this.liked,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['PLAYER_ID'],
      player: json['PLAYER'],
      team: json['TEAM'],
      game: json['GP'],
      min: json['MIN'],
      points: json['PTS'],
      assists: json['AST'],
      rebounds: json['REB'],
      fgPct: (json['FG_PCT'] as num).toDouble(),
      fg3Pct: (json['FG3_PCT'] as num).toDouble(),
      ftPct: (json['FT_PCT'] as num).toDouble(),
      blk: json['BLK'],
      stl: json['STL'],
      tov: json['TOV'],
      oreb: json['OREB'],
      dreb: json['DREB'],
      pf: json['PF'],
      imageFileName: json['PLAYER_ID'].toString() + '.png',
      liked: json['LIKED'] ?? false,
    );
  }
}

class MediaPage extends StatefulWidget {
  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late Future<List<PlayerStats>> futureStats;

  @override
  void initState() {
    super.initState();
    futureStats = loadStats();
  }

  Future<List<PlayerStats>> loadStats() async {
    try {
      final String response = await rootBundle.loadString('assets/api/nba2024stats.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => PlayerStats.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayerStats>>(
      future: futureStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Erreur: ${snapshot.error}');
          return Center(child: Text('Erreur de chargement des données'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune donnée disponible'));
        }

        final players = snapshot.data!;

        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            return PlayerCard(player: players[index]);
          },
        );
      },
    );
  }
}

class PlayerCard extends StatefulWidget {
  final PlayerStats player;

  PlayerCard({required this.player});

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset('assets/images/${widget.player.imageFileName}'),
        title: Text(
          widget.player.player,
          style: TextStyle(fontSize: 14.0),
        ),
        subtitle: Text(
          widget.player.team,
          style: TextStyle(fontSize: 12.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PPG: ${(widget.player.points/widget.player.game).toStringAsFixed(1)}'),
                Text('APG: ${(widget.player.assists/widget.player.game).toStringAsFixed(1)}'),
                Text('RPG: ${(widget.player.rebounds/widget.player.game).toStringAsFixed(1)}'),
              ],
            ),
            IconButton(
              icon: Icon(
                widget.player.liked ? Icons.favorite : Icons.favorite_border,
                color: widget.player.liked ? Colors.red : null,
              ),
              onPressed: () {
                setState(() {
                  widget.player.liked = !widget.player.liked;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return Center(
      child: Text('About Page'),
    );
  }
}