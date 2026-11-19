# ArrowPuzzleGame — System Architecture & Technical Specification
**Version:** 1.0.0-draft  
**Author:** Lead Software Architect & Game Developer  
**Status:** Under Review (Phase 1 Deliverable)  

---

## 1. Executive Summary & Game Concept
**ArrowPuzzleGame** is a commercial-quality, modern, minimalist mobile puzzle game designed for Android and iOS. Inspired by the core spatial puzzle mechanics of arrow-escape games, it features 100% original visual branding, haptic audio design, dynamic puzzle generation, and a clean offline-first architecture.

### 1.1 Core Mechanics
1. **Grid & Arrow Entities:** A 2D board with dimensions $M \times N$ (e.g., $5\times 5$, $7\times 7$, up to $10\times 12$ in Master/Challenge modes) populated with arrow entities.
2. **Directionality:** Each arrow occupies a grid cell $(x, y)$ and points in a cardinal direction:
   - $\text{UP} \; (0, -1)$
   - $\text{DOWN} \; (0, 1)$
   - $\text{LEFT} \; (-1, 0)$
   - $\text{RIGHT} \; (1, 0)$
3. **Escape Rule (Raycasting Path Validation):**
   - When a player taps an arrow, the engine performs a raycast along the arrow's pointing vector towards the board boundary.
   - If the ray encounters another active arrow cell or obstacle, collision occurs $\rightarrow$ the move is **invalid**.
   - If the ray reaches the board boundary without any obstruction $\rightarrow$ the move is **valid**, the arrow executes an escape animation and is removed from the active grid.
4. **Win Condition:** The level is won when the active arrow count reaches zero ($\text{activeCount} == 0$).
5. **Loss Condition:**
   - **Relaxed / Challenge Mode:** 3 hearts exhausted due to 3 invalid moves (or 0 hearts).
   - **Timed Mode:** Countdown timer reaches $00:00$.

---

## 2. Guaranteed Solvable Puzzle Generation Algorithm (Reverse-Play Backtracking)

### 2.1 The Solvability Problem
Random arrow placement easily leads to circular deadlocks (e.g., A blocks B, B blocks C, C blocks A), causing unsolvable puzzles. **Unsolvable puzzles are strictly unacceptable in commercial puzzle games.**

### 2.2 Mathematical Solution: Reverse Simulation (Construction by Inversion)
To guarantee that every generated level has at least one valid solution, we construct the board in reverse order:
1. **Start with an empty board** (representing the solved, cleared state).
2. **Step $K$ to Step $1$ (Reverse Insertion):**
   - Pick an empty coordinate $(x, y)$.
   - Choose a direction $D$ such that the ray from $(x, y)$ in direction $D$ to the boundary is **currently clear of any existing arrows**.
   - Place this arrow on the board. In forward gameplay, this arrow will be able to escape freely when the board reaches this step.
   - For the next arrow, place it such that its path can be either clear or intentionally blocked by already placed arrows.
3. **Solvability Invariant:** Since every placed arrow had an unobstructed path to the boundary at the moment it was inserted, playing the game in reverse order of insertion guarantees an escape sequence.

### 2.3 Forward Verification & Difficulty Rating
Once a puzzle is generated:
- An automated BFS/DFS solver executes on the puzzle to find:
  - Total number of branching choices at each step.
  - Number of "distractor" choices (moves that look tempting but lead to dead ends).
  - Minimum move sequence to win.
- Puzzles are categorized into:
  - **Easy:** High percentage of immediate clear choices, small board ($5\times 5$ to $6\times 6$).
  - **Hard:** Moderate cross-blocking, medium board ($7\times 7$ to $8\times 8$).
  - **Master:** Dense inter-locking paths, board sizes up to $10\times 12$.

---

## 3. Game Modes Specification

```
                     ┌──────────────────────────────┐
                     │       ArrowPuzzleGame        │
                     └──────────────┬───────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         ▼                          ▼                          ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   Relaxed Mode   │       │  Challenge Mode  │       │    Timed Mode    │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ • 3 Difficulties │       │ • Complex Boards │       │ • Countdown Clock│
│ • 3 Hearts       │       │ • Obstacle Cells │       │ • Combo Scores   │
│ • Hint System    │       │ • Unlockables    │       │ • Bonus Time     │
│ • Saved Progress │       │ • Trophy Rewards │       │ • Leaderboards   │
└──────────────────┘       └──────────────────┘       └──────────────────┘
```

### 3.1 Relaxed Mode
- Focused on zen-like puzzle solving.
- 3 Hearts per run. Making an invalid tap triggers a slight vibration, heart depletion, and an arrow shake animation.
- Players can earn or buy hints (highlights 1 currently escapable arrow in soft gold glow).
- Infinite resumes: Player progress is automatically stored locally after each cleared arrow.

### 3.2 Challenge Mode
- Introduces special grid mechanics:
  - **Immovable Obstacles (Rocks/Blocks):** Permanent obstructions that cannot escape.
  - **Multi-directional Arrows / Portals (Advanced phases):** Expandable feature set.
- Unlocks exclusive decorative arrow themes and background themes upon milestone completions.

### 3.3 Timed Mode
- Speed-run puzzle solving.
- Starts with base time (e.g., 60 seconds).
- Each successful arrow escape grants bonus time ($+1.5\text{s}$) and score multiplier.
- Fast consecutive escapes trigger "Combo Streak" multipliers.
- Highest score saved to local and global leaderboards.

---

## 4. Software Architecture & Clean Layering

The Flutter application adheres to Clean Architecture principles, completely separating pure game logic from UI widgets:

```
┌───────────────────────────────────────────────────────────┐
│                    Presentation Layer                     │
│  - Flutter Widgets (Screens, Dialogs, HUD)               │
│  - CustomPainter (High-performance Arrow Board Canvas)    │
│  - AnimationControllers & TickerProviders                 │
└─────────────────────────────▲─────────────────────────────┘
                              │ States & Events
┌─────────────────────────────▼─────────────────────────────┐
│                      State Management                     │
│  - Riverpod StateNotifier / NotifierProviders             │
│  - GameSessionNotifier, PlayerProfileNotifier, AdNotifier │
└─────────────────────────────▲─────────────────────────────┘
                              │ Invokes Actions
┌─────────────────────────────▼─────────────────────────────┐
│                 Core Game Engine (Domain)                 │
│  - Pure Dart (Zero Flutter dependencies, 100% testable)   │
│  - GridBoard, ArrowEntity, RaycastDetector                │
│  - ReversePuzzleGenerator, LevelSolverValidator           │
└─────────────────────────────▲─────────────────────────────┘
                              │ Persists / Syncs
┌─────────────────────────────▼─────────────────────────────┐
│                    Data & Infrastructure                  │
│  - Local Database: Hive / SQLite (Offline storage)        │
│  - Secure Storage: FlutterSecureStorage (Tokens, Keys)    │
│  - Remote Sync: Cloud Backend API (Leaderboard, Backup)   │
│  - AdManager: Google Mobile Ads SDK                       │
└───────────────────────────────────────────────────────────┘
```

### 4.1 CustomPainter Rendering vs Widget Grid
- For high-speed performance and 60/120 FPS arrow animations, the puzzle board is rendered using Flutter's **`CustomPainter`** over a single hardware-accelerated canvas rather than nested widget hierarchies.
- Benefits:
  - Zero widget rebuild overhead during continuous arrow sliding animations.
  - Pixel-perfect custom arrow rendering with rounded geometry, inner shadows, and dynamic glow.
  - Effortless particle effects on arrow escapes.

---

## 5. Offline & Online Backend Architecture

### 5.1 Offline-First Principles
- **100% Core Playability Offline:** The game engine, level generation, level progression, hearts system, and audio function without any network connection.
- **Local Persistence:** All player progress, unlocked items, coins, and local best scores are saved to fast local storage (Hive/SQLite) immediately upon change.

### 5.2 Online Architecture Evaluation

| Feature | Firebase (Google) | Supabase (Open-Source Postgres) | Custom Backend (Node/Go) | Recommended |
| :--- | :--- | :--- | :--- | :--- |
| **Setup Speed** | Very Fast (Official Flutter plugins) | Fast (Official Dart SDK) | Slow (Build from scratch) | **Firebase** |
| **Authentication** | Anonymous, Google, Apple ID | Email, OAuth | Custom JWT | **Firebase** |
| **Free Tier Quota** | Generous (Spark Plan) | Generous (Free 500MB DB) | Requires paid VPS | **Firebase** |
| **Global Leaderboard**| Firestore + Cloud Functions | Postgres Realtime / SQL Views | Custom API | **Firebase / Supabase**|
| **Cost Risk** | Pay-as-you-go past free limits | Predictable fixed tier | Server hosting cost | **Firebase Free Tier** |

**Recommendation:** We begin with **Firebase (Free Spark Tier)** for Authentication (Anonymous + Google/Apple Sign-in) and Cloud Firestore for Leaderboard/Profile sync. Offline queueing ensures zero game blocking if the device loses connection.

---

## 6. Monetization Architecture (Google AdMob)

### 6.1 Ad Placements & Guardrails
1. **Banner Ads:**
   - Displayed strictly at the bottom of non-gameplay screens (Home Screen, Level Selection, Collection Screen).
   - **Never displayed during active gameplay.**
2. **Interstitial Ads (Full-screen transitions):**
   - Displayed only between level transitions after every $N$ levels (configurable, default: 3 levels).
   - Minimum interval timer (e.g., at least 90 seconds between interstitials).
3. **Rewarded Ads (Player-initiated):**
   - **Extra Life / Continue:** When all 3 hearts are lost, player can watch an ad to refill hearts and continue the puzzle.
   - **Free Hint:** Watch an ad to receive 2 free hints.
   - **2x Coin Multiplier:** Double the reward after finishing a challenging level.
4. **Ad Architecture Guardrail:**
   - Centralized `AdService` singleton.
   - Offline safety: If ads fail to load or device is offline, gameplay is completely unrestricted.
   - Test Ad Unit IDs strictly enforced during all development phases.

---

## 7. Data Models Specification

```dart
// Core Arrow Data Model
enum ArrowDirection { up, down, left, right }
enum ArrowState { idle, selected, escaping, blocked, cleared }

class ArrowEntity {
  final String id;
  final int gridX;
  final int gridY;
  final ArrowDirection direction;
  final ArrowState state;

  const ArrowEntity({
    required this.id,
    required this.gridX,
    required this.gridY,
    required this.direction,
    this.state = ArrowState.idle,
  });
}

// Level Configuration Model
class LevelConfig {
  final int levelNumber;
  final int gridWidth;
  final int gridHeight;
  final List<ArrowEntity> initialArrows;
  final int difficultyTier; // 1: Easy, 2: Hard, 3: Master
  final int? timeLimitSeconds; // null for Relaxed Mode
}

// Player Profile Model
class PlayerProfile {
  final String userId;
  final String displayName;
  final int currentLevel;
  final int coins;
  final int hearts;
  final DateTime lastHeartRegenTimestamp;
  final Map<String, int> highScores;
  final List<String> unlockedSkins;
}
```

---

## 8. Summary of Architectural Decisions
1. **Engine Separation:** Pure Dart domain package for the puzzle engine; guarantees fast automated unit tests without UI mockups.
2. **Deterministic Solver:** Reverse generation ensures zero broken puzzles for players.
3. **Canvas Performance:** CustomPainter ensures 60/120 FPS high-end tactile feel.
4. **User-Friendly Privacy:** Anonymous login allows instant play with zero barrier; optional cloud sync protects progress.
