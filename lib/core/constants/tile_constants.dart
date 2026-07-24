import 'package:flutter/material.dart';

/// Identifiers for the 6 tile types (Mahjong fruits).
enum TileType {
  apple,
  watermelon,
  lemon,
  banana,
  avocado,
  orange,
}

const Map<TileType, String> tileTypeLabels = {
  TileType.apple: 'apple',
  TileType.watermelon: 'watermelon',
  TileType.lemon: 'lemon',
  TileType.banana: 'banana',
  TileType.avocado: 'avocado',
  TileType.orange: 'orange',
};

TileType tileTypeFromLabel(String label) {
  return tileTypeLabels.entries
      .firstWhere((e) => e.value == label, orElse: () => const MapEntry(TileType.apple, 'apple'))
      .key;
}

const int tileTypeCount = 6;
const List<TileType> allTileTypes = TileType.values;

/// Emojis for the tiles
const Map<TileType, String> tileEmoji = {
  TileType.apple: '🍎',
  TileType.watermelon: '🍉',
  TileType.lemon: '🍋',
  TileType.banana: '🍌',
  TileType.avocado: '🥑',
  TileType.orange: '🍊',
};

/// Main colors used for particle effects.
const Map<TileType, Color> tileBaseColor = {
  TileType.apple: Color(0xFFE53935),
  TileType.watermelon: Color(0xFF43A047),
  TileType.lemon: Color(0xFFFFEB3B),
  TileType.banana: Color(0xFFFFC107),
  TileType.avocado: Color(0xFF81C784),
  TileType.orange: Color(0xFFFF9800),
};
