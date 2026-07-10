import 'package:choco_blast_adventure/game_logic/match_detector.dart';

/// Phases of a cell's animation during cascade resolution.
enum CellAnimPhase {
  /// No animation — tile is at rest.
  idle,

  /// Tile matched — white glow + slight scale-up (flash phase).
  matched,

  /// Tile is popping — particle burst + shrink to zero.
  popping,

  /// Tile is falling down due to gravity.
  falling,

  /// New tile sliding in from the top to fill a gap.
  refilling,
}

/// Animation state for a single cell.
class CellAnimState {
  final CellAnimPhase phase;
  final int cascadeStep;

  /// For falling: how many rows this tile moved down.
  final int fallDistance;

  /// For refilling: the row the tile came from (negative = above board).
  final int fromRow;

  /// Score to display as popup at this cell's position.
  final int? scorePopup;

  const CellAnimState({
    this.phase = CellAnimPhase.idle,
    this.cascadeStep = 0,
    this.fallDistance = 0,
    this.fromRow = 0,
    this.scorePopup,
  });

  CellAnimState copyWith({
    CellAnimPhase? phase,
    int? cascadeStep,
    int? fallDistance,
    int? fromRow,
    int? scorePopup,
    bool clearScorePopup = false,
  }) {
    return CellAnimState(
      phase: phase ?? this.phase,
      cascadeStep: cascadeStep ?? this.cascadeStep,
      fallDistance: fallDistance ?? this.fallDistance,
      fromRow: fromRow ?? this.fromRow,
      scorePopup: clearScorePopup ? null : (scorePopup ?? this.scorePopup),
    );
  }
}

/// Tracks the animation state for the entire board during cascade resolution.
class BoardAnimState {
  /// Per-cell animation states. Only cells currently animating are present.
  final Map<Cell, CellAnimState> cellStates;

  /// Which cascade step we're currently animating (0-indexed).
  final int activeCascadeStep;

  /// Total number of cascade steps.
  final int totalSteps;

  /// Whether any animation is currently playing.
  final bool isAnimating;

  /// Bomb blast state — center cell and all cells that were hit.
  final Cell? bombBlastCenter;
  final Set<Cell> bombBlastCells;

  const BoardAnimState({
    this.cellStates = const {},
    this.activeCascadeStep = 0,
    this.totalSteps = 0,
    this.isAnimating = false,
    this.bombBlastCenter,
    this.bombBlastCells = const {},
  });

  /// Get the animation state for a cell, or idle if not present.
  CellAnimState stateFor(int r, int c) {
    return cellStates[Cell(r, c)] ?? const CellAnimState();
  }

  /// Create a flash state: mark matched cells as [CellAnimPhase.matched].
  BoardAnimState.flash(Set<Cell> cells, int step, int total)
      : cellStates = {
          for (final c in cells)
            c: CellAnimState(phase: CellAnimPhase.matched, cascadeStep: step),
        },
        activeCascadeStep = step,
        totalSteps = total,
        isAnimating = true,
        bombBlastCenter = null,
        bombBlastCells = const {};

  /// Create a pop state: mark matched cells as [CellAnimPhase.popping].
  BoardAnimState.pop(Set<Cell> cells, int step, int total)
      : cellStates = {
          for (final c in cells)
            c: CellAnimState(phase: CellAnimPhase.popping, cascadeStep: step),
        },
        activeCascadeStep = step,
        totalSteps = total,
        isAnimating = true,
        bombBlastCenter = null,
        bombBlastCells = const {};

  /// Create a fall state: mark cells that moved due to gravity.
  BoardAnimState.fall(Map<Cell, int> fallDistances, int step, int total)
      : cellStates = {
          for (final entry in fallDistances.entries)
            entry.key: CellAnimState(
              phase: CellAnimPhase.falling,
              cascadeStep: step,
              fallDistance: entry.value,
            ),
        },
        activeCascadeStep = step,
        totalSteps = total,
        isAnimating = true,
        bombBlastCenter = null,
        bombBlastCells = const {};

  /// Create a refill state: mark new tiles sliding in from above.
  BoardAnimState.refill(Map<Cell, int> fromRows, int step, int total)
      : cellStates = {
          for (final entry in fromRows.entries)
            entry.key: CellAnimState(
              phase: CellAnimPhase.refilling,
              cascadeStep: step,
              fromRow: entry.value,
            ),
        },
        activeCascadeStep = step,
        totalSteps = total,
        isAnimating = true,
        bombBlastCenter = null,
        bombBlastCells = const {};

  /// No animation playing.
  static const BoardAnimState idle = BoardAnimState();

  /// Create a bomb blast state with center and hit cells.
  factory BoardAnimState.bombBlast(Cell center, Set<Cell> hitCells) {
    return BoardAnimState(
      isAnimating: true,
      bombBlastCenter: center,
      bombBlastCells: hitCells,
      cellStates: {
        for (final c in hitCells)
          c: const CellAnimState(phase: CellAnimPhase.matched),
      },
    );
  }
}
