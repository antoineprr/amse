


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tp1/player_detail_page.dart';
import 'package:tp1/stats_class.dart';

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
