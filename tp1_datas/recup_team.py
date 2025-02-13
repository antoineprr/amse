from nba_api.stats.static import teams
import json

# Récupérer la liste de toutes les équipes NBA
nba_teams = teams.get_teams()

# Exporter les données au format JSON, formaté correctement
with open("nba_teams.json", "w") as json_file:
    json.dump(nba_teams, json_file, indent=4)

print("Données exportées dans le fichier 'nba_teams.json'")