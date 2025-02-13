import requests
from bs4 import BeautifulSoup
import json
import os

# Fonction pour récupérer le logo d'une équipe
def get_team_logo(team_id):
    url = f'https://www.nba.com/stats/team/{team_id}'
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Trouver la balise img avec la classe spécifique
    img_tag = soup.find('img', {'class': 'TeamLogo_logo__PclAJ TeamHeader_teamLogoBW__s7vYd'})
    if img_tag:
        logo_src = img_tag['src']
        return logo_src
    return None

# Fonction pour télécharger et sauvegarder l'image
def download_image(url, team_name, team_id, save_directory):
    if not url:
        print(f"Aucune URL d'image pour l'équipe {team_name}")
        return
    
    if not os.path.exists(save_directory):
        os.makedirs(save_directory)
    
    # Définir le nom de fichier à partir de l'ID de l'équipe
    file_name = f"{team_id}.svg"
    file_path = os.path.join(save_directory, file_name)
    
    response = requests.get(url)
    if response.status_code == 200:
        with open(file_path, 'wb') as file:
            file.write(response.content)
        print(f"Image sauvegardée pour l'équipe {team_name} à {file_path}")
    else:
        print(f"Échec du téléchargement de l'image pour l'équipe {team_name}")

# Charger les données JSON des équipes
with open('nba_teams.json', 'r') as file:
    teams_data = json.load(file)

# Répertoire pour sauvegarder les logos des équipes
save_directory = 'team_images'

# Itérer sur chaque équipe pour récupérer et télécharger le logo
for team in teams_data:
    team_id = team['id']
    team_name = team['full_name']
    logo_url = get_team_logo(team_id)
    download_image(logo_url, team_name, team_id, save_directory)