import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_avif/flutter_avif.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NBA Media',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MediaPage(),
    LikedMediaPage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NBA Media'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Liked',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class PlayerStats {
  final String player;
  final String team;
  final String pos;
  final double points;
  final double assists;
  final double rebounds;
  final String imageFileName;
  bool liked;

  PlayerStats({
    required this.player,
    required this.team,
    required this.pos,
    required this.points,
    required this.assists,
    required this.rebounds,
    required this.imageFileName, 
    this.liked = false,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      player: json['Player'],
      team: json['Team'],
      pos: json['Pos'],
      points: (json['PTS'] as num).toDouble(),
      assists: (json['AST'] as num).toDouble(),
      rebounds: (json['TRB'] as num).toDouble(),
      imageFileName: json['Image'], 
      liked: json['Liked'] ?? false,
    );
  }
}

class MediaPage extends StatefulWidget {
  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late Future<List<PlayerStats>> futureStats;

  @override
  void initState() {
    super.initState();
    futureStats = loadStats();
  }

  Future<List<PlayerStats>> loadStats() async {
    final String response = await rootBundle.loadString('assets/api/nba2024stats.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => PlayerStats.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayerStats>>(
      future: futureStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement des données'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune donnée disponible'));
        }

        final players = snapshot.data!;

        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            return PlayerCard(player: players[index]);
          },
        );
      },
    );
  }
}

class PlayerCard extends StatefulWidget {
  final PlayerStats player;

  PlayerCard({required this.player});

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: widget.player.imageFileName.endsWith('.avif')
            ? AvifImage.asset('assets/images/${widget.player.imageFileName}')
            : Image.asset('assets/images/${widget.player.imageFileName}'),
        title: Text(
          widget.player.player,
          style: TextStyle(fontSize: 14.0),
        ),
        subtitle: Text(
          '${widget.player.team} - ${widget.player.pos}',
          style: TextStyle(fontSize: 12.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PTS: ${widget.player.points.toStringAsFixed(1)}'),
                Text('AST: ${widget.player.assists.toStringAsFixed(1)}'),
                Text('REB: ${widget.player.rebounds.toStringAsFixed(1)}'),
              ],
            ),
            IconButton(
              icon: Icon(
                widget.player.liked ? Icons.favorite : Icons.favorite_border,
                color: widget.player.liked ? Colors.red : null,
              ),
              onPressed: () {
                setState(() {
                  widget.player.liked = !widget.player.liked;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCard extends StatefulWidget {
  final Media media;

  MediaCard({required this.media});

  @override
  _MediaCardState createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(widget.media.imageUrl),
        title: Text(widget.media.title),
        subtitle: Text(widget.media.category),
        trailing: IconButton(
          icon: Icon(
            widget.media.liked ? Icons.favorite : Icons.favorite_border,
            color: widget.media.liked ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              widget.media.liked = !widget.media.liked;
            });
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaDetailPage(media: widget.media),
            ),
          );
        },
      ),
    );
  }
}

class MediaDetailPage extends StatelessWidget {
  final Media media;

  MediaDetailPage({required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(media.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(media.imageUrl),
            Text(media.category),
            // Ajoutez plus de détails ici
          ],
        ),
      ),
    );
  }
}

class LikedMediaPage extends StatelessWidget {
  final List<Media> likedMediaList = [
    // Ajoutez les médias likés ici
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: likedMediaList.length,
      itemBuilder: (context, index) {
        return MediaCard(media: likedMediaList[index]);
      },
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('About NBA Media App'),
    );
  }
}

class Media {
  final int id;
  final String title;
  final String category;
  final String imageUrl;
  bool liked;

  Media({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.liked,
  });
}