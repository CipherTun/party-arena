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

## Current limitations

This is still a starter project, not a store-ready release. Online multiplayer, sound, saved scores and formal automated gameplay tests are not implemented. Some arcade games are rule/state based rather than physics simulations. The source was reviewed and archive integrity checked in this environment, but Flutter/Dart are not installed here, so the analyzer, Android build and on-device controls have **not** been verified locally. Run the included GitHub Actions workflow and test the resulting APK on a real device before release.
