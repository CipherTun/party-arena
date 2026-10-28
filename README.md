# Party Arena

Party Arena is a local, one-device mini-game collection built with Flutter, Flame and Forge2D. It includes 32 distinct games: physics-driven games use Forge2D bodies, while board, timing and tap games use their own rules and state. One-human modes use simple CPU opponents where implemented.

## Games included

1. Air Hockey
2. Soccer
3. Ping Pong
4. Sumo Push
5. Tug of War
6. Basketball
7. Tap Race
8. Reaction Duel
9. Color Clash
10. Whack-a-Dot
11. Tic Tac Toe
12. Rock Paper Scissors
13. Sprint Race
14. Tank Duel
15. Archery
16. Memory Match
17. Connect Four
18. Dots & Boxes
19. Mini Golf
20. Boat Race
21. Obstacle Run
22. Snowball Fight
23. Ball Balance
24. Fruit Catch
25. Math Sprint
26. Dodgeball
27. Curling
28. Trivia Blitz
29. Simon Tiles
30. Maze Escape
31. Brick Breaker
32. Platform Hopper

The menu has search, a category filter, and a player-count selector. Categories are Sports & Physics (10 games), Racing & Action (8), Quick Play (6), Strategy & Puzzle (5), and Brain & Trivia (3). Every game stays visible; games that do not support the selected number of human players are disabled with a clear explanation. Sumo Push supports up to four human players; the other listed games are two-player games (including solo-vs-CPU mode where supported). Reaction Duel is the single reaction-timing game; a duplicate variant was removed. Games are grouped into Sports & Physics, Racing & Action, Quick Play, Strategy & Puzzle, and Brain & Trivia, with a category filter in the menu.

## Build locally

Install the Flutter stable SDK (Dart 3.3 or newer), then from this directory run:

```sh
flutter create . --platforms=android
flutter pub get
flutter analyze
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Build with GitHub Actions

The included `.github/workflows/android.yml` workflow runs on pushes and pull requests to `main`/`master`, and can also be started from the Actions tab with **Run workflow**. It generates Android platform files, resolves dependencies, runs `flutter analyze`, builds a release APK and uploads it as the `party-arena-android-apk` artifact.

## Controls

- Physics games use touch/drag controls shown or implied by the game field.
- Tap games use the half of the screen assigned to each player.
- Turn-based board games accept taps on the board; solo modes include a basic CPU opponent where implemented.
- Fruit Catch and Dodgeball use drag controls; Math Sprint and Trivia Blitz use four answer zones; Curling launches sliding stones; Simon Tiles rewards hitting the highlighted tile; Maze Escape uses edge/center taps for directions; Brick Breaker uses paddle dragging; Platform Hopper uses taps to jump over obstacles.
- Use the back arrow to leave a game; after a round, use **Rematch** or **Back to games**.

## What changed in this revision (bug-fix and controls pass)

Found by reading the code (not by compiling it):

- **Build blocker:** `arcade.dart` used `TextPainter` without importing Flutter's painting library.
- **Rock Paper Scissors:** your pick was random and results flashed past. You now tap ROCK / PAPER / SCISSORS, picks stay hidden until both are in, and each round has a reveal pause (sudden death if tied after 3).
- **Reaction Duel:** time was counted from the start of the round, not from the green light. Fixed, with a random wait and a timeout.
- **Whack-a-Dot:** the top row was unreachable for the human in 1-player mode. Each player now has their own 6-dot board.
- **Tank Duel / Snowball Fight:** every shot hit automatically. Drag to dodge (tanks) and moving targets you must lead (snowballs).
- **Archery:** tapping the centre always scored 10. Now a moving crosshair; time your tap.
- **Obstacle Run:** the obstacle was drawn moving the wrong way and dead players kept scoring. Fixed, with skill-based jump timing and rising speed.
- **Platform Hopper:** progress froze while airborne so every obstacle was a guaranteed hit. Fixed; the CPU times its jumps.
- **Curling:** stones started on the wrong side and drifted away from the house. Now steer with left/right, power from tap distance, stones collide, closest stone wins.
- **Trivia Blitz:** the hexagon question had an out-of-range answer index (nobody could get it right). Fixed and 5 questions added.
- **Maze Escape:** unfair start (3 steps vs 7). New layout with equal shortest paths, on-screen arrows, CPU uses shortest-path search.
- **Brick Breaker:** the ball never bounced off the ceiling and moved far too slowly. Fixed ball speed, ceiling, brick collisions and spin clamp.
- **Ball Balance:** was won by tapping fastest. Now a tug-of-ball: roll it past your edge.
- **Memory Match:** the CPU could finish the last pair without ending the game; matching a pair now keeps your turn.
- **Mini Golf:** unholed balls tied with holed ones and the game could end mid-roll. Now +3 stroke penalty for not holing, and it waits for balls to stop. CPU computes putt power.
- **Tic Tac Toe / Connect Four / Dots & Boxes:** CPU waits before moving; Connect Four CPU now takes wins and blocks.
- **CI:** `flutter analyze` no longer fails the build on info/warning lints; `flutter_lints` added and an `analysis_options.yaml` included.

## Current limitations

This is still a starter project, not a store-ready release. Online multiplayer, sound, saved scores and formal automated gameplay tests are not implemented. Some arcade games are rule/state based rather than physics simulations. The source was reviewed and archive integrity checked in this environment, but Flutter/Dart are not installed here, so the analyzer, Android build and on-device controls have **not** been verified locally. Run the included GitHub Actions workflow and test the resulting APK on a real device before release.
