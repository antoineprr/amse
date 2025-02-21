from nba_api.stats.endpoints import leagueleaders
import pandas as pd
import json

# Récupérer les leaders de la ligue pour la saison 2023-24
leaders = leagueleaders.LeagueLeaders(season='2023-24')

# Obtenir les données sous forme de DataFrame
leaders_df = leaders.get_data_frames()[0]

# Sélectionner les 20 premiers joueurs
top_20_ppg = leaders_df.head(500)

# Convertir le DataFrame en dictionnaire
top_20_ppg_dict = top_20_ppg.to_dict(orient='records')

# Exporter les données au format JSON, formaté correctement
with open("top_20_ppg_2023_24_formatted.json", "w") as json_file:
    json.dump(top_20_ppg_dict, json_file, indent=4)

print("\nDonnées exportées au format JSON correctement formaté dans le fichier 'top_20_ppg_2023_24_formatted.json'")
