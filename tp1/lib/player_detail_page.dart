import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tp1/stats_class.dart';
import 'dart:convert';
import 'main.dart';
import 'package:provider/provider.dart';

class PlayerDetailPage extends StatelessWidget {
  final PlayerStats player;
  const PlayerDetailPage({Key? key, required this.player}) : super(key: key);

  Widget _buildStatItem(String label, String value) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString('assets/api/nbaTeams.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<dynamic> teams = json.decode(snapshot.data!);
          final teamInfo = teams.firstWhere(
            (team) => team['abbreviation'] == player.team,
            orElse: () => null,
          );
          if (teamInfo != null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                      'assets/images/teams/${teamInfo['id']}.svg',
                      height: 60,
                      width: 60,
                      ),
                      SizedBox(height: 8),
                      Text(
                      teamInfo['full_name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/teams/${teamInfo['id']}.svg',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          teamInfo['full_name'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          } else {
            return Text(
              "Information de l'équipe non disponible",
              style: TextStyle(color: Colors.blueGrey[800]),
            );
          }
        } else if (snapshot.hasError) {
          return Text(
            "Erreur de chargement de l'équipe",
            style: TextStyle(color: Colors.red),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double minutesPerGame = player.min / player.game;
    final double pointsPerGame = player.points / player.game;
    final double assistsPerGame = player.assists / player.game;
    final double reboundsPerGame = player.rebounds / player.game;
    final double blocksPerGame = player.blk / player.game;
    final double stealsPerGame = player.stl / player.game;
    final double turnoversPerGame = player.tov / player.game;
    final double orebPerGame = player.oreb / player.game;
    final double drebPerGame = player.dreb / player.game;
    final double foulsPerGame = player.pf / player.game;

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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          player.player,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<MyAppState>(
                        builder: (context, appState, child) {
                          bool isFavorite = appState.favorites
                              .any((p) => p.playerId == player.playerId);
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () => appState.toggleFavorite(player),
                          );
                        },
                      ),
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
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/players/${player.imageFileName}',
                          height: 130,
                          width: 130,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTeamInfo(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(
                    height: 24,
                    thickness: 2,
                    color: Colors.blueGrey[200],
                  ),
                  Text(
                    "Moyennes par match",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatItem("MPG", minutesPerGame.toStringAsFixed(1)),
                      _buildStatItem("PPG", pointsPerGame.toStringAsFixed(1)),
                      _buildStatItem("APG", assistsPerGame.toStringAsFixed(1)),
                      _buildStatItem("RPG", reboundsPerGame.toStringAsFixed(1)),
                      _buildStatItem("BPG", blocksPerGame.toStringAsFixed(1)),
                      _buildStatItem("SPG", stealsPerGame.toStringAsFixed(1)),
                      _buildStatItem("TOV", turnoversPerGame.toStringAsFixed(1)),
                      _buildStatItem("ORB", orebPerGame.toStringAsFixed(1)),
                      _buildStatItem("DREB", drebPerGame.toStringAsFixed(1)),
                      _buildStatItem("PF", foulsPerGame.toStringAsFixed(1)),
                      _buildStatItem("FG%", (player.fgPct * 100).toStringAsFixed(1)),
                      _buildStatItem("3P%", (player.fg3Pct * 100).toStringAsFixed(1)),
                      _buildStatItem("FT%", (player.ftPct * 100).toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}