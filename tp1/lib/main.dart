import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  List<dynamic> _nbaStats = [];

  static List<Widget> _widgetOptions = <Widget>[
    MediaPage(),
    LikedMediaPage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadNbaStats();
  }

  Future<void> _loadNbaStats() async {
    final String response = await rootBundle.loadString('assets/api/nba2024stats.json');
    final data = await json.decode(response);
    setState(() {
      _nbaStats = data;
    });
  }

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

class MediaPage extends StatelessWidget {
  final List<Media> mediaList = [
    Media(id: 1, title: 'Media 1', category: 'Video', imageUrl: 'https://via.placeholder.com/150', liked: false),
    Media(id: 2, title: 'Media 2', category: 'Article', imageUrl: 'https://via.placeholder.com/150', liked: false),
    // Ajoutez plus de médias ici
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        return MediaCard(media: mediaList[index]);
      },
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