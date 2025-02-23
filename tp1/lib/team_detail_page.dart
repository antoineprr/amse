import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tp1/stats_class.dart';
import 'package:tp1/player_detail_page.dart';

class TeamDetailPage extends StatelessWidget {
  final Team team;
  const TeamDetailPage({Key? key, required this.team}) : super(key: key);


  Future<List<PlayerStats>> _loadPlayers(BuildContext context) async {
    final String response = await DefaultAssetBundle.of(context).loadString('assets/api/nba2024stats.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => PlayerStats.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: FractionallySizedBox(
        widthFactor: 0.95,
        heightFactor: 0.95,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      team.fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1),
            Expanded(
              child: FutureBuilder<List<PlayerStats>>(
                future: _loadPlayers(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur de chargement des données'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucune donnée disponible'));
                  }

                  final players = snapshot.data!.where((player) => player.team == team.abbreviation).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/images/teams/${team.id}.svg',
                            height: 100,
                            width: 100,
                            placeholderBuilder: (context) => CircularProgressIndicator(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.fullName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ville : ${team.city}',
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                                ),
                                Text(
                                  'État : ${team.state}',
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                                ),
                                Text(
                                  'Fondée en : ${team.yearFounded}',
                                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Joueurs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          double width = constraints.maxWidth;
                          
                          if (width > 800) {
                            crossAxisCount = 5;
                          } else if (width > 600) {
                            crossAxisCount = 4;
                          } else {
                            crossAxisCount = 3;
                          }
                          
                          double spacing = 4;
                          double totalSpacing = (crossAxisCount - 1) * spacing;
                          double cellWidth = (width - totalSpacing) / crossAxisCount;
                          
                          return GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            children: players.map((player) {
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => PlayerDetailPage(player: player),
                                  );
                                },
                                child: Column(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/images/players/${player.imageFileName}',
                                        width: cellWidth * 0.8,
                                        height: cellWidth * 0.8,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}