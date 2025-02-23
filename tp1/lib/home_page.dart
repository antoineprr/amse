import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tp1/player_detail_page.dart';
import 'package:tp1/stats_class.dart';
import 'package:tp1/team_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PlayerStats> _allPlayers = [];
  List<PlayerStats> _filteredPlayers = [];
  List<PlayerStats> topPlayers = [];
  List<Team> topTeams = [];
  String _searchQuery = '';
  int _currentPlayerPage = 0;
  int _currentTeamPage = 0;
  late PageController _playerPageController;
  late PageController _teamPageController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playerPageController = PageController(initialPage: 0);
    _teamPageController = PageController(initialPage: 0);
    _loadCarouselImages();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final String response =
          await rootBundle.loadString('assets/api/nba2024stats.json');
      final List<dynamic> data = json.decode(response);
      List<PlayerStats> players =
          data.map((json) => PlayerStats.fromJson(json)).toList();
      players.sort((a, b) => ((b.points / b.game).compareTo(a.points / a.game)));
      setState(() {
        _allPlayers = players;
        _filteredPlayers = players;
        topPlayers = players.take(10).toList();
      });

      final String teamResponse =
          await rootBundle.loadString('assets/api/nbaTeams.json');
      final List<dynamic> teamData = json.decode(teamResponse);
      List<Team> teams = teamData.map((json) => Team.fromJson(json)).toList();

      final List<String> teamOrder = [
        "Los Angeles Lakers",
        "Boston Celtics",
        "Golden State Warriors",
        "Cleveland Cavaliers",
        "Oklahoma City Thunder",
        "Dallas Mavericks",
        "Denver Nuggets",
        "New York Knicks",
      ];

      List<Team> filteredTeams = teams.where((team) {
        return teamOrder.contains(team.fullName);
      }).toList();

      filteredTeams.sort((a, b) =>
          teamOrder.indexOf(a.fullName).compareTo(teamOrder.indexOf(b.fullName)));

      setState(() {
        topTeams = filteredTeams;
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
    _playerPageController.dispose();
    _teamPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPlayerPageChanged(int index) {
    setState(() {
      _currentPlayerPage = index;
    });
  }

  void _onTeamPageChanged(int index) {
    setState(() {
      _currentTeamPage = index;
    });
  }

  Widget buildCarousel() {
    final double carouselHeight =
        MediaQuery.of(context).size.width > 800 ? 300 : 200;

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
                controller: _playerPageController,
                itemCount: topPlayers.length,
                onPageChanged: _onPlayerPageChanged,
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
                              frameBuilder: (BuildContext context, Widget child,
                                  int? frame, bool wasSynchronouslyLoaded) {
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
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
                    int previousPage = _currentPlayerPage - 1;
                    if (previousPage < 0) {
                      previousPage = topPlayers.length - 1;
                    }
                    _playerPageController.animateToPage(
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
                    int nextPage = _currentPlayerPage + 1;
                    if (nextPage >= topPlayers.length) {
                      nextPage = 0;
                    }
                    _playerPageController.animateToPage(
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
              margin:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentPlayerPage == index ? 12 : 8,
              height: _currentPlayerPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPlayerPage == index
                    ? Colors.blueAccent
                    : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildTeamCarousel() {
    final double carouselHeight =
        MediaQuery.of(context).size.width > 800 ? 300 : 200;

    if (topTeams.isEmpty) {
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
                controller: _teamPageController,
                itemCount: topTeams.length,
                onPageChanged: _onTeamPageChanged,
                itemBuilder: (context, index) {
                  final team = topTeams[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => TeamDetailPage(team: team),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SvgPicture.asset(
                              'assets/images/teams/${team.id}.svg',
                              fit: BoxFit.contain,
                              placeholderBuilder: (context) =>
                                  CircularProgressIndicator(),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            team.fullName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
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
                    int previousPage = _currentTeamPage - 1;
                    if (previousPage < 0) {
                      previousPage = topTeams.length - 1;
                    }
                    _teamPageController.animateToPage(
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
                    int nextPage = _currentTeamPage + 1;
                    if (nextPage >= topTeams.length) {
                      nextPage = 0;
                    }
                    _teamPageController.animateToPage(
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
          children: List.generate(topTeams.length, (index) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentTeamPage == index ? 12 : 8,
              height: _currentTeamPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentTeamPage == index
                    ? Colors.blueAccent
                    : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildSearchResults() {
    if (_filteredPlayers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Aucun joueur trouvé', style: TextStyle(fontSize: 16)),
      );
    }
    return Column(
      children: _filteredPlayers.map((player) {
        return ListTile(
          leading: Image.asset(
            'assets/images/players/${player.imageFileName}',
            width: 50,
            height: 50,
          ),
          title: Text(player.player),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => PlayerDetailPage(player: player),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(29, 66, 138, 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Bienvenue sur Stats don't lie",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un joueur...',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _filteredPlayers = List.from(_allPlayers);
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filteredPlayers = _allPlayers.where((player) {
                  return player.player
                      .toLowerCase()
                      .contains(value.toLowerCase());
                }).toList();
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _searchQuery.trim().isNotEmpty
            ? buildSearchResults()
            : Column(
                children: [
                  Center(
                    child: Text(
                      'Joueurs populaires',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildCarousel(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Équipes populaires',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildTeamCarousel(),
                ],
              ),
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