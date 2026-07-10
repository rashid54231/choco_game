import 'package:choco_blast_adventure/core/constants/tile_constants.dart';

/// The kind of special behaviour a tile has (none = normal tile).
enum SpecialKind {
  none,
  /// "Striped": clears a full row or column when activated.
  striped,
  /// "Wrapped": explodes in a 3x3 area, twice.
  wrapped,
  /// "Color Bomb": clears all tiles of the swapped tile's color.
  colorBomb,
}

/// Orientation for striped tiles.
enum StripedOrientation {
  horizontal, // clears a row
  vertical, // clears a column
}

/// A single board cell. [null] color means an empty cell (mid-cascade).
class Tile {
  final TileType? type;
  final SpecialKind special;
  final StripedOrientation? stripedOrientation;

  const Tile({
    required this.type,
    this.special = SpecialKind.none,
    this.stripedOrientation,
  });

  /// A completely empty tile (used transiently during gravity/refill).
  const Tile.empty()
      : type = null,
        special = SpecialKind.none,
        stripedOrientation = null;

  bool get isEmpty => type == null;
  bool get isSpecial => special != SpecialKind.none;

  Tile copyWith({
    TileType? type,
    SpecialKind? special,
    StripedOrientation? stripedOrientation,
  }) {
    return Tile(
      type: type ?? this.type,
      special: special ?? this.special,
      stripedOrientation: stripedOrientation ?? this.stripedOrientation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          other.type == type &&
          other.special == special &&
          other.stripedOrientation == stripedOrientation;

  @override
  int get hashCode => type.hashCode ^ special.hashCode ^ stripedOrientation.hashCode;

  Map<String, dynamic> toJson() => {
        'type': type?.name,
        'special': special.name,
        'stripedOrientation': stripedOrientation?.name,
      };

  factory Tile.fromJson(Map<String, dynamic> json) => Tile(
        type: json['type'] == null ? null : TileType.values.byName(json['type'] as String),
        special: SpecialKind.values.byName(json['special'] as String? ?? 'none'),
        stripedOrientation: json['stripedOrientation'] == null
            ? null
            : StripedOrientation.values.byName(json['stripedOrientation'] as String),
      );
}
