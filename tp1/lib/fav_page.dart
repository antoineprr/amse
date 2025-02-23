import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp1/card_class.dart';
import 'package:tp1/main.dart';

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favPlayers = context.watch<MyAppState>().favorites;

    if (favPlayers.isEmpty) {
      return Center(child: Text('Aucun favori'));
    }

    return ListView.builder(
      itemCount: favPlayers.length,
      itemBuilder: (context, index) {
        return PlayerCard(player: favPlayers[index]);
      },
    );
  }
}