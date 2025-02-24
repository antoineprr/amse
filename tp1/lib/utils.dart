import 'dart:convert';
import 'package:flutter/services.dart';

Map<String, dynamic>? _assetManifest;

Future<void> loadAssetManifest() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  _assetManifest = json.decode(manifestContent);
}

bool checkAsset(String assetPath) {
  if (_assetManifest == null) return true;
  return _assetManifest!.containsKey(assetPath);
}