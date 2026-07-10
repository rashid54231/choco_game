import 'package:flutter/material.dart';

/// Identifiers for the 6 tile types (glossy candy shapes).
enum TileType {
  blueSphere,    // glossy blue ball
  greenSquare,   // green cube/pillow
  purpleFlower,  // purple flower/star
  orangeBean,    // orange oval
  redBerry,      // red berry
  yellowStar,    // yellow star
}

/// Human readable labels for tile types (used by collect-goals, etc).
const Map<TileType, String> tileTypeLabels = {
  TileType.blueSphere: 'blue',
  TileType.greenSquare: 'green',
  TileType.purpleFlower: 'purple',
  TileType.orangeBean: 'orange',
  TileType.redBerry: 'red',
  TileType.yellowStar: 'yellow',
};

TileType tileTypeFromLabel(String label) {
  return tileTypeLabels.entries
      .firstWhere((e) => e.value == label, orElse: () => const MapEntry(TileType.blueSphere, 'blue'))
      .key;
}

const int tileTypeCount = 6;
const List<TileType> allTileTypes = TileType.values;

/// Main candy colors (base fill).
const Map<TileType, Color> tileBaseColor = {
  TileType.blueSphere: Color(0xFF2E88E8),
  TileType.greenSquare: Color(0xFF3AAF3A),
  TileType.purpleFlower: Color(0xFF9C27B0),
  TileType.orangeBean: Color(0xFFFF8C00),
  TileType.redBerry: Color(0xFFE53935),
  TileType.yellowStar: Color(0xFFFFD600),
};

/// Darker shade for gradients / depth.
const Map<TileType, Color> tileAccentColor = {
  TileType.blueSphere: Color(0xFF1A5FB8),
  TileType.greenSquare: Color(0xFF258A25),
  TileType.purpleFlower: Color(0xFF7B1FA2),
  TileType.orangeBean: Color(0xFFE07000),
  TileType.redBerry: Color(0xFFB71C1C),
  TileType.yellowStar: Color(0xFFC7A800),
};

/// Highlight / sheen color for each tile type.
const Map<TileType, Color> tileHighlightColor = {
  TileType.blueSphere: Color(0xFF64B5F6),
  TileType.greenSquare: Color(0xFF81C784),
  TileType.purpleFlower: Color(0xFFCE93D8),
  TileType.orangeBean: Color(0xFFFFCC80),
  TileType.redBerry: Color(0xFFEF9A9A),
  TileType.yellowStar: Color(0xFFFFF176),
};
