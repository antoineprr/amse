import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'main.dart';

class PlayerDetailPage extends StatelessWidget {
  final PlayerStats player;
  const PlayerDetailPage({Key? key, required this.player}) : super(key: key);

  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context)
          .loadString('api/nbaTeams.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<dynamic> teams = json.decode(snapshot.data!);
          final teamInfo = teams.firstWhere(
            (team) => team['abbreviation'] == player.team,
            orElse: () => null,
          );
          if (teamInfo != null) {
            return Row(
              children: [
                SvgPicture.asset(
                  'images/teams/${teamInfo['id']}.svg',
                  height: 60,
                  width: 60,
                ),
                SizedBox(width: 16),
                Text(
                  teamInfo['full_name'],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            );
          } else {
            return Text("Information de l'équipe non disponible");
          }
        } else if (snapshot.hasError) {
          return Text("Erreur de chargement de l'équipe");
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

    return Scaffold(
      appBar: AppBar(
        title: Text(player.player),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/players/${player.imageFileName}',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamInfo(context),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(height: 24, thickness: 2, color: Color.fromRGBO(200, 16, 46, 1),),
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
              _buildStatItem("FG%", (player.fgPct * 100).toStringAsFixed(1)),
              _buildStatItem("3P%", (player.fg3Pct * 100).toStringAsFixed(1)),
              _buildStatItem("FT%", (player.ftPct * 100).toStringAsFixed(1)),
              _buildStatItem("BPG", blocksPerGame.toStringAsFixed(1)),
              _buildStatItem("SPG", stealsPerGame.toStringAsFixed(1)),
              _buildStatItem("TOV", turnoversPerGame.toStringAsFixed(1)),
              _buildStatItem("ORB", orebPerGame.toStringAsFixed(1)),
              _buildStatItem("DREB", drebPerGame.toStringAsFixed(1)),
              _buildStatItem("PF", foulsPerGame.toStringAsFixed(1)),
            ],
          )
        ],
      ),
    );
  }
}