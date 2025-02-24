import 'package:tp1/utils.dart';

class PlayerStats {
  final int playerId;
  final String player;
  final String team;
  final int game;
  final int min;
  final int points;
  final int assists;
  final int rebounds;
  final double fgPct;
  final double fg3Pct;
  final double ftPct;
  final int blk;
  final int stl;
  final int tov;
  final int oreb;
  final int dreb;
  final int pf;
  final String imageFileName;
  bool liked;

  PlayerStats({
    required this.playerId,
    required this.player,
    required this.team,
    required this.game,
    required this.min,
    required this.points,
    required this.assists,
    required this.rebounds,
    required this.fgPct,
    required this.fg3Pct,
    required this.ftPct,
    required this.blk,
    required this.stl,
    required this.tov,
    required this.oreb,
    required this.dreb,
    required this.pf,
    required this.imageFileName,
    required this.liked,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['PLAYER_ID'],
      player: json['PLAYER'],
      team: json['TEAM'],
      game: json['GP'],
      min: json['MIN'],
      points: json['PTS'],
      assists: json['AST'],
      rebounds: json['REB'],
      fgPct: (json['FG_PCT'] as num).toDouble(),
      fg3Pct: (json['FG3_PCT'] as num).toDouble(),
      ftPct: (json['FT_PCT'] as num).toDouble(),
      blk: json['BLK'],
      stl: json['STL'],
      tov: json['TOV'],
      oreb: json['OREB'],
      dreb: json['DREB'],
      pf: json['PF'],
      imageFileName: (() {
        String imageName = json['PLAYER_ID'].toString() + '.png';
        return (checkAsset('assets/images/players/' + imageName))
        ? imageName
        : 'default.png';
      })(),
      liked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PLAYER_ID': playerId,
      'PLAYER': player,
      'TEAM': team,
      'GP': game,
      'MIN': min,
      'PTS': points,
      'AST': assists,
      'REB': rebounds,
      'FG_PCT': fgPct,
      'FG3_PCT': fg3Pct,
      'FT_PCT': ftPct,
      'BLK': blk,
      'STL': stl,
      'TOV': tov,
      'OREB': oreb,
      'DREB': dreb,
      'PF': pf,
      'liked': liked,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStats && runtimeType == other.runtimeType && playerId == other.playerId;

  @override
  int get hashCode => playerId.hashCode;
}


class Team {
  final int id;
  final String fullName;
  final String abbreviation;
  final String nickname;
  final String city;
  final String state;
  final int yearFounded;

  Team({
    required this.id,
    required this.fullName,
    required this.abbreviation,
    required this.nickname,
    required this.city,
    required this.state,
    required this.yearFounded,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      fullName: json['full_name'],
      abbreviation: json['abbreviation'],
      nickname: json['nickname'],
      city: json['city'],
      state: json['state'],
      yearFounded: json['year_founded'],
    );
  }
}
