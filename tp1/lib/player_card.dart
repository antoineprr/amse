import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp1/main.dart';
import 'package:tp1/player_detail_page.dart';
import 'package:tp1/stats_class.dart';

class PlayerCard extends StatefulWidget {
  final PlayerStats player;

  PlayerCard({required this.player});

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  @override
  Widget build(BuildContext context) {
    bool isFavorite = context
        .watch<MyAppState>()
        .favorites
        .any((p) => p.playerId == widget.player.playerId);

    return Card(
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => PlayerDetailPage(player: widget.player),
          );
        },
        leading: Image.asset(
          'assets/images/players/${widget.player.imageFileName}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return frame == null
                ? Container(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : child;
          },
        ),
        title: Text(
          widget.player.player,
          style: TextStyle(fontSize: 14.0),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.player.team,
          style: TextStyle(fontSize: 12.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PPG: ${(widget.player.points / widget.player.game).toStringAsFixed(1)}'),
                Text('APG: ${(widget.player.assists / widget.player.game).toStringAsFixed(1)}'),
                Text('RPG: ${(widget.player.rebounds / widget.player.game).toStringAsFixed(1)}'),
              ],
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false)
                    .toggleFavorite(widget.player);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
