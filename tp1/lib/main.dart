import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tp1/player_detail_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  void toggleFavorite(PlayerStats player) {
    bool isFavorite = favorites.any((p) => p.playerId == player.playerId);
    if (isFavorite) {
      favorites.removeWhere((p) => p.playerId == player.playerId);
      player.liked = false;
    } else {
      favorites.add(player);
      player.liked = true;
    }
    notifyListeners();
  }
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précharger l'image du logo
    precacheImage(AssetImage('assets/images/logo.png'), context);
    // Précharger toutes les images des players et des teams
    _precacheImagesFromDirectory('assets/images/players/');
    _precacheImagesFromDirectory('assets/images/teams/');
  }

  void _precacheImagesFromDirectory(String directory) async {
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys.where((key) => key.startsWith(directory)).toList();

    for (final path in imagePaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      liked: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStats && runtimeType == other.runtimeType && playerId == other.playerId;

  @override
  int get hashCode => playerId.hashCode;
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
    bool isFavorite = context
        .watch<MyAppState>()
        .favorites
        .any((p) => p.playerId == widget.player.playerId);

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PlayerDetailPage(player: widget.player)),
          );
        },
        leading: Image.asset(
          'assets/images/players/${widget.player.imageFileName}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
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
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false)
                    .toggleFavorite(widget.player);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late Future<List<Team>> futureTeams;

  @override
  void initState() {
    super.initState();
    futureTeams = loadTeams();
  }

  Future<List<Team>> loadTeams() async {
    try {
      final String response = await rootBundle.loadString('assets/api/nbaTeams.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: futureTeams,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Erreur: ${snapshot.error}');
          return Center(child: Text('Erreur de chargement des données'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune donnée disponible'));
        }

        final teams = snapshot.data!;

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            return TeamCard(team: teams[index]);
          },
        );
      },
    );
  }
}

class Team {
  final int id;
  final String fullName;
  final String abbreviation;
  final String nickname;
  final String city;
  final String state;
  final int yearFounded;

  Team({
    required this.id,
    required this.fullName,
    required this.abbreviation,
    required this.nickname,
    required this.city,
    required this.state,
    required this.yearFounded,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      fullName: json['full_name'],
      abbreviation: json['abbreviation'],
      nickname: json['nickname'],
      city: json['city'],
      state: json['state'],
      yearFounded: json['year_founded'],
    );
  }
}

class TeamCard extends StatelessWidget {
  final Team team;

  TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SvgPicture.asset(
          'assets/images/teams/${team.id}.svg',
          width: 50,
          height: 50,
          placeholderBuilder: (context) => CircularProgressIndicator(),
        ),
        title: Text(team.fullName),
        subtitle: Text('${team.city}, ${team.state}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Founded: ${team.yearFounded}'),
            Text('Abbreviation: ${team.abbreviation}'),
          ],
        ),
      ),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favPlayers = context.watch<MyAppState>().favorites;

    if (favPlayers.isEmpty) {
      return Center(child: Text('Aucun favori'));
    }

    return ListView.builder(
      itemCount: favPlayers.length,
      itemBuilder: (context, index) {
        return PlayerCard(player: favPlayers[index]);
      },
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