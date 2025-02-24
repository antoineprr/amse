# tp1 - Stats don't lie (SdL)

Ce projet Flutter est une application de statistiques NBA. Il présente des informations détaillées sur les joueurs et les équipes de la saison régulière 2024-25, avec des fonctionnalités de recherche et de favoris pour faciliter la consultation des performances.

## Pages

- **Accueil** : Visualisez un aperçu des joueurs et équipes populaires ou recherchez un joueur.
- **Joueurs** : Affichez la liste des 500 joueurs avec leurs statistiques (Points Per Game, Assists, Rebounds, etc.). Vous pouvez trier par métriques (PPG, APG, RPG), effectuer une recherche par nom, consulter des informations avancées en cliquant sur un joueur et ajouter des joueurs aux favoris.
- **Équipes** : Consultez les informations de chaque équipe ainsi que le détail de leurs joueurs en cliquant sur leur logo.
- **Favoris** : Affichez vos joueurs favoris.
- **À propos** : Description de l'application, explications des abréviations, sources de données (nba_api, nba.com) et crédits.

## Fonctionnalités

- **Navigation par onglets** : Passez facilement de la page d'accueil aux pages détaillées grâce à la barre de navigation ou en glissant l'écran.
- **Responsivité** : Affichage adapté à toutes les interfaces.

## Données utilisées

Les statistiques des joueurs sont récupérées via l'API non officielle de la NBA (nba_api) et les images proviennent du site officiel de la NBA. Des données statiques, stockées au format JSON, sont utilisées et doivent être mises à jour manuellement (l'API étant un client Python, l'intégration directe n'est pas possible depuis Flutter).

## Installation de l'application

- **Ordinateur** : Dans un terminal, placez-vous dans le répertoire souhaité et exécutez :

```sh
git clone http://www.github.com/antoineprr/amse.git
cd amse/tp1
flutter create .
flutter run
```

- **Android (APK)** : Nécessite de posséder un ordinateur

1. **Génération de l'APK en mode Release**
Dans le terminal, placez-vous dans le répertoire souhaité et exécutez les commandes suivantes :
```sh
git clone http://www.github.com/antoineprr/amse.git
cd amse/tp1
flutter build apk --release
```
L'APK généré se trouve généralement dans le répertoire `build/app/outputs/flutter-apk/` (nommé `app-release.apk`).

2. **Installation de l'APK sur un appareil Android**  
Récupérez l'APK depuis votre ordinateur selon la méthode de votre choix et installez-le sur votre appareil Android.