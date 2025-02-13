import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tp1/player_detail_page.dart';

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

class MyAppState extends ChangeNotifier {}

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
      // ignore: prefer_interpolation_to_compose_strings
      imageFileName: json['PLAYER_ID'].toString() + '.png',
      liked: json['LIKED'] ?? false,
    );
  }
}

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerDetailPage(player: widget.player),
            ),
          );
        },
        leading: CachedNetworkImage(
          imageUrl: 'assets/images/players/${widget.player.imageFileName}',
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
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
                Text('PPG: ${(widget.player.points / widget.player.game).toStringAsFixed(1)}'),
                Text('APG: ${(widget.player.assists / widget.player.game).toStringAsFixed(1)}'),
                Text('RPG: ${(widget.player.rebounds / widget.player.game).toStringAsFixed(1)}'),
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

class TeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('Team Page'),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('Fav Page'),
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