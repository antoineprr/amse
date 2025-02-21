import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tp1/player_detail_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Afficher une vue de chargement tant que le logo n'est pas disponible
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PlayerStats> topPlayers = [];
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadCarouselImages();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final String response = await rootBundle.loadString('assets/api/nba2024stats.json');
      final List<dynamic> data = json.decode(response);
      List<PlayerStats> players = data.map((json) => PlayerStats.fromJson(json)).toList();
      players.sort((a, b) => ((b.points / b.game).compareTo(a.points / a.game)));
      setState(() {
        topPlayers = players.take(10).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des images pour le carousel: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/logo.png'), context);
    _precacheImagesFromDirectory('assets/images/players/');
    _precacheImagesFromDirectory('assets/images/teams/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget buildCarousel() {
    final double carouselHeight = MediaQuery.of(context).size.width > 800 ? 300 : 200;

    if (topPlayers.isEmpty) {
      return SizedBox(
        height: carouselHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: topPlayers.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final player = topPlayers[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => PlayerDetailPage(player: player),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/images/players/${player.imageFileName}',
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                              frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return frame == null
                                    ? Container(
                                        width: 50,
                                        height: 50,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : child;
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            player.player,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                top: carouselHeight / 2 - 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 40),
                  onPressed: () {
                    int previousPage = _currentPage - 1;
                    if (previousPage < 0) {
                      previousPage = topPlayers.length - 1;
                    }
                    _pageController.animateToPage(
                      previousPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                top: carouselHeight / 2 - 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, size: 40),
                  onPressed: () {
                    int nextPage = _currentPage + 1;
                    if (nextPage >= topPlayers.length) {
                      nextPage = 0;
                    }
                    _pageController.animateToPage(
                      nextPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(topPlayers.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Joueurs populaires',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        buildCarousel(),
      ],
    );
  }

  void _precacheImagesFromDirectory(String directory) async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths =
        manifestMap.keys.where((key) => key.startsWith(directory)).toList();

    for (final path in imagePaths) {
      if (path.endsWith('.svg')) continue;
      precacheImage(AssetImage(path), context);
    }
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
      liked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PLAYER_ID': playerId,
      'PLAYER': player,
      'TEAM': team,
      'GP': game,
      'MIN': min,
      'PTS': points,
      'AST': assists,
      'REB': rebounds,
      'FG_PCT': fgPct,
      'FG3_PCT': fg3Pct,
      'FT_PCT': ftPct,
      'BLK': blk,
      'STL': stl,
      'TOV': tov,
      'OREB': oreb,
      'DREB': dreb,
      'PF': pf,
      'liked': liked,
    };
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
  String searchText = "";
  final searchController = TextEditingController();
  String selectedSortMetric = "PPG";
  int currentPage = 0;
  final int itemsPerPage = 100;
  final ScrollController scrollController = ScrollController(); // Ajout du controller

  @override
  void initState() {
    super.initState();
    futureStats = loadStats();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
        players.sort((a, b) {
          switch (selectedSortMetric) {
            case "APG":
              return (b.assists / b.game).compareTo(a.assists / a.game);
            case "RPG":
              return (b.rebounds / b.game).compareTo(a.rebounds / a.game);
            case "PPG":
            default:
              return (b.points / b.game).compareTo(a.points / a.game);
          }
        });

        List<PlayerStats> filteredPlayers = players
            .where((player) =>
                player.player.toLowerCase().contains(searchText.toLowerCase()))
            .toList();

        int totalPages = (filteredPlayers.length / itemsPerPage).ceil();
        if (totalPages == 0) totalPages = 1; // pour éviter des problèmes d'index
        if (currentPage >= totalPages) {
          currentPage = totalPages - 1;
        }
        final currentPagePlayers = filteredPlayers
            .skip(currentPage * itemsPerPage)
            .take(itemsPerPage)
            .toList();

        return Column(
          children: [
            // Options de filtrage toujours visibles
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Rechercher un joueur",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchText = "";
                              currentPage = 0;
                            });
                            scrollController.jumpTo(0);
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                          currentPage = 0;
                        });
                        scrollController.jumpTo(0);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSortMetric,
                          items: const [
                            DropdownMenuItem(child: Text("PPG"), value: "PPG"),
                            DropdownMenuItem(child: Text("APG"), value: "APG"),
                            DropdownMenuItem(child: Text("RPG"), value: "RPG"),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSortMetric = value!;
                              currentPage = 0;
                            });
                            scrollController.jumpTo(0);
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredPlayers.isEmpty
                  ? Center(child: Text('Aucun joueur ne correspond à la recherche'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: currentPagePlayers.length,
                      itemBuilder: (context, index) {
                        return PlayerCard(player: currentPagePlayers[index]);
                      },
                    ),
            ),
            // Affichage de la pagination uniquement si des résultats existent
            if (filteredPlayers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: currentPage > 0
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                              scrollController.animateTo(0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            }
                          : null,
                    ),
                    Text("Page ${currentPage + 1} de $totalPages"),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                currentPage++;
                              });
                              scrollController.animateTo(0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
          ],
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
          showDialog(
            context: context,
            builder: (_) => PlayerDetailPage(player: widget.player),
          );
        },
        leading: Image.asset(
          'assets/images/players/${widget.player.imageFileName}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return frame == null
                ? Container(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : child;
          },
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
            Text('Année de création : ${team.yearFounded}'),
            Text('Abréviation : ${team.abbreviation}'),
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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            "À propos de l'application",
            style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            "Cette application présente des statistiques de la saison régulière 2023-24 de la NBA.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Divider(),
          SizedBox(height: 16),
          Text(
            "Abréviations utilisées",
            style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...[
            {"abbr": "MPG", "desc": "Minutes Per Game - Moyenne de minutes jouées par match"},
            {"abbr": "PPG", "desc": "Points Per Game - Moyenne de points marqués par match"},
            {"abbr": "APG", "desc": "Assists Per Game - Moyenne de passes décisives par match"},
            {"abbr": "RPG", "desc": "Rebounds Per Game - Moyenne de rebonds attrapés par match"},
            {"abbr": "FG%", "desc": "Field Goal Percentage - Pourcentage de tirs réussis"},
            {"abbr": "3P%", "desc": "Three-Point Percentage - Pourcentage de tirs à trois points réussis"},
            {"abbr": "FT%", "desc": "Free Throw Percentage - Pourcentage de lancers francs réussis"},
            {"abbr": "BPG", "desc": "Blocks Per Game - Moyenne de contres par match"},
            {"abbr": "SPG", "desc": "Steals Per Game - Moyenne d'interceptions par match"},
            {"abbr": "TOV", "desc": "Turnovers Per Game - Moyenne de balles perdues par match"},
            {"abbr": "OREB", "desc": "Offensive Rebounds Per Game - Moyenne de rebonds offensifs par match"},
            {"abbr": "DREB", "desc": "Defensive Rebounds Per Game - Moyenne de rebonds défensifs par match"},
            {"abbr": "PF", "desc": "Personal Fouls Per Game - Moyenne de fautes personnelles par match"},
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                item["abbr"]!,
                style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                item["desc"]!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
              ),
            );
          }).toList(),
          SizedBox(height: 32),
          Divider(),
          SizedBox(height: 16),
          Text(
            "Crédits",
            style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "Développé par Antoine Poirier dans le cadre de l'UV AMSE.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          Text(
            "Les données proviennent de nba_api (API non-officielle de la NBA).\nLes images proviennent du site web de la NBA.\nStatistiques pour la saison régulière NBA 2023-2024, utilisées à des fins privées.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}