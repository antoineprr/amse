
import 'package:flutter/material.dart';

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
            "Cette application présente les joueurs et équipes de la saison régulière 2024-25 de la NBA.",
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
            {"abbr": "RPG", "desc": "Rebounds Per Game - Moyenne de rebonds par match"},
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
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Les données proviennent de nba_api (API non-officielle de la NBA).\nLes images proviennent du site web de la NBA.\nStatistiques pour la saison régulière NBA 2024-2025, utilisées à des fins personnelles.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Développé par Antoine Poirier dans le cadre de l'UV AMSE.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
 