import 'package:choco_blast_adventure/core/constants/tile_constants.dart';

/// The kind of blocker on this tile.
enum BlockerType {
  none,
  chocolate,
  ice,
}

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
  final BlockerType blocker;
  final int iceLayers;

  const Tile({
    required this.type,
    this.special = SpecialKind.none,
    this.stripedOrientation,
    this.blocker = BlockerType.none,
    this.iceLayers = 0,
  });

  /// A completely empty tile (used transiently during gravity/refill).
  const Tile.empty()
      : type = null,
        special = SpecialKind.none,
        stripedOrientation = null,
        blocker = BlockerType.none,
        iceLayers = 0;

  bool get isEmpty => type == null && blocker != BlockerType.chocolate;
  bool get isSpecial => special != SpecialKind.none;
  bool get isBlocker => blocker != BlockerType.none;

  Tile copyWith({
    TileType? type,
    SpecialKind? special,
    StripedOrientation? stripedOrientation,
    BlockerType? blocker,
    int? iceLayers,
  }) {
    return Tile(
      type: type ?? this.type,
      special: special ?? this.special,
      stripedOrientation: stripedOrientation ?? this.stripedOrientation,
      blocker: blocker ?? this.blocker,
      iceLayers: iceLayers ?? this.iceLayers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          other.type == type &&
          other.special == special &&
          other.stripedOrientation == stripedOrientation &&
          other.blocker == blocker &&
          other.iceLayers == iceLayers;

  @override
  int get hashCode => type.hashCode ^ special.hashCode ^ stripedOrientation.hashCode ^ blocker.hashCode ^ iceLayers.hashCode;

  Map<String, dynamic> toJson() => {
        'type': type?.name,
        'special': special.name,
        'stripedOrientation': stripedOrientation?.name,
        'blocker': blocker.name,
        'iceLayers': iceLayers,
      };

  factory Tile.fromJson(Map<String, dynamic> json) => Tile(
        type: json['type'] == null ? null : TileType.values.byName(json['type'] as String),
        special: SpecialKind.values.byName(json['special'] as String? ?? 'none'),
        stripedOrientation: json['stripedOrientation'] == null
            ? null
            : StripedOrientation.values.byName(json['stripedOrientation'] as String),
        blocker: BlockerType.values.byName(json['blocker'] as String? ?? 'none'),
        iceLayers: json['iceLayers'] as int? ?? 0,
      );
}
