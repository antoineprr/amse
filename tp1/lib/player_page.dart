import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tp1/card_class.dart';
import 'package:tp1/stats_class.dart';

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
  final ScrollController scrollController = ScrollController();

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
        if (totalPages == 0) totalPages = 1; 
        if (currentPage >= totalPages) {
          currentPage = totalPages - 1;
        }
        final currentPagePlayers = filteredPlayers
            .skip(currentPage * itemsPerPage)
            .take(itemsPerPage)
            .toList();

        return Column(
          children: [
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
