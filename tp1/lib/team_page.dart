import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tp1/stats_class.dart';
import 'package:tp1/team_detail_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 5 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => TeamDetailPage(team: team),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/images/teams/${team.id}.svg',
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => CircularProgressIndicator(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
