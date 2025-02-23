import requests
from bs4 import BeautifulSoup
import json
import os

# Fonction pour récupérer l'image d'un joueur
def get_player_image(player_id):
    url = f'https://www.nba.com/stats/player/{player_id}'
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Trouver la balise img avec les classes spécifiques
    img_tag = soup.find('img', {'class': 'PlayerImage_image__wH_YX PlayerSummary_playerImage__sysif'})
    if img_tag:
        img_src = img_tag['src']
        return img_src
    return None

# Fonction pour télécharger et sauvegarder l'image
def download_image(url, player_name, player_id, save_directory):
    if not url:
        print(f"No image URL for player {player_name}")
        return

    # Vérifier si l'image existe déjà dans le dossier "player_images"
    file_name = f"{player_id}.png"
    file_path = os.path.join(save_directory, file_name)
    
    if os.path.exists(file_path):
        print(f"Image already exists for player {player_name} at {file_path}")
        return

    # Télécharger l'image
    response = requests.get(url)
    if response.status_code == 200:
        # Créer le nouveau répertoire pour sauvegarder l'image s'il n'existe pas
        new_directory = 'new_player_images'
        if not os.path.exists(new_directory):
            os.makedirs(new_directory)
        
        new_file_path = os.path.join(new_directory, file_name)
        with open(new_file_path, 'wb') as file:
            file.write(response.content)
        print(f"Image saved for player {player_name} at {new_file_path}")
    else:
        print(f"Failed to download image for player {player_name}")

# Charger les données JSON
with open('top_20_ppg_2023_24_formatted.json', 'r') as file:
    players_data = json.load(file)

# Répertoire pour sauvegarder les images
save_directory = 'player_images'

# Itérer sur chaque joueur pour récupérer et télécharger l'image
for player in players_data:
    player_id = player['PLAYER_ID']
    player_name = player['PLAYER']
    image_url = get_player_image(player_id)
    download_image(image_url, player_name, player_id, save_directory)