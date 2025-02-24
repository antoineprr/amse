from nba_api.stats.endpoints import leagueleaders
import pandas as pd

# Récupérer les leaders de la ligue pour la saison 2024-25
leaders = leagueleaders.LeagueLeaders(season='2024-25')

# Obtenir les données sous forme de DataFrame
leaders_df = leaders.get_data_frames()[0]

# Sélectionner les 20 premiers joueurs
top_20_ppg = leaders_df.head(500)

# Exporter les données en JSON sans indentation pour réduire la taille
top_20_ppg.to_json("top_500_2024_25.json", orient='records')

print("Données exportées dans 'top_500_2024_25.json' avec un format compact.")
