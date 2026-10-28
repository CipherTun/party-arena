import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'core.dart';
import 'games/hoops.dart';
import 'games/arcade.dart';
import 'games/pong.dart';
import 'games/puck.dart';
import 'games/sumo.dart';
import 'games/tug.dart';

void main() => runApp(const PartyApp());

class GameInfo {
  const GameInfo(this.name, this.icon, this.blurb, this.build, {this.maxPlayers = 2, this.category = 'Quick Play'});
  final String name, blurb, category;
  final IconData icon;
  final MiniGame Function(int humans) build;
  final int maxPlayers;
}

final games = <GameInfo>[
  GameInfo('Air Hockey', Icons.sports_hockey, '2 players · first to 5', (h) => PuckGame(humans: h, soccer: false), category: 'Sports & Physics'),
  GameInfo('Soccer', Icons.sports_soccer, '2 players · first to 5', (h) => PuckGame(humans: h, soccer: true), category: 'Sports & Physics'),
  GameInfo('Ping Pong', Icons.sports_tennis, '2 players · first to 7', (h) => PongGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Sumo Push', Icons.circle, '2–4 players · drag to push rivals', (h) => SumoGame(humans: h), maxPlayers: 4, category: 'Sports & Physics'),
  GameInfo('Tug of War', Icons.compare_arrows, '2 players · tap fast', (h) => TugGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Basketball', Icons.sports_basketball, '2 players · slingshot shots', (h) => HoopsGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Tap Race', Icons.touch_app, 'Tap fast · 12 seconds', (h) => QuickTapGame(humans: h), category: 'Racing & Action'),
  GameInfo('Reaction Duel', Icons.bolt, 'Wait for green, then tap', (h) => ReactionGame(humans: h), category: 'Quick Play'),
  GameInfo('Color Clash', Icons.palette, 'Find the target color', (h) => ColorMatchGame(humans: h), category: 'Quick Play'),
  GameInfo('Whack-a-Dot', Icons.ads_click, 'Hit the glowing dot', (h) => WhackGame(humans: h), category: 'Quick Play'),
  GameInfo('Tic Tac Toe', Icons.grid_3x3, 'Classic X and O', (h) => TicTacToeGame(humans: h), category: 'Strategy & Puzzle'),
  GameInfo('Rock Paper Scissors', Icons.back_hand, 'Best of three rounds', (h) => RpsGame(humans: h), category: 'Quick Play'),
  GameInfo('Sprint Race', Icons.directions_car, 'Tap to accelerate', (h) => RacingGame(humans: h), category: 'Racing & Action'),
  GameInfo('Tank Duel', Icons.shield, 'Fire and outlast the rival', (h) => TankDuelGame(humans: h), category: 'Racing & Action'),
  GameInfo('Archery', Icons.gps_fixed, 'Five shots each · bullseye bonus', (h) => ArcheryGame(humans: h), category: 'Racing & Action'),
  GameInfo('Memory Match', Icons.grid_view, 'Find all six matching pairs', (h) => MemoryGridGame(humans: h), category: 'Brain & Trivia'),
  GameInfo('Connect Four', Icons.circle, 'Line up four discs', (h) => ConnectFourGame(humans: h), category: 'Strategy & Puzzle'),
  GameInfo('Dots & Boxes', Icons.apps, 'Claim boxes by drawing edges', (h) => DotsBoxesGame(humans: h), category: 'Strategy & Puzzle'),
  GameInfo('Mini Golf', Icons.golf_course, 'Sink it in five strokes', (h) => MiniGolfGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Boat Race', Icons.directions_boat, 'Tap to paddle to the finish', (h) => BoatRaceGame(humans: h), category: 'Racing & Action'),
  GameInfo('Obstacle Run', Icons.directions_run, 'Jump and survive', (h) => ObstacleRunGame(humans: h), category: 'Racing & Action'),
  GameInfo('Snowball Fight', Icons.ac_unit, 'Throw snowballs to win', (h) => SnowballGame(humans: h), category: 'Racing & Action'),
  GameInfo('Ball Balance', Icons.sports_handball, 'Keep the ball from falling', (h) => BallBalanceGame(humans: h), category: 'Sports & Physics'),

  GameInfo('Fruit Catch', Icons.spa, 'Catch fruit; avoid bombs · 25 seconds', (h) => FruitCatchGame(humans: h), category: 'Quick Play'),
  GameInfo('Math Sprint', Icons.calculate, 'Solve sums faster than your rival', (h) => MathSprintGame(humans: h), category: 'Brain & Trivia'),
  GameInfo('Dodgeball', Icons.sports_handball, 'Drag to dodge incoming throws', (h) => DodgeballGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Curling', Icons.sports, 'Slide stones toward the target', (h) => CurlingGame(humans: h), category: 'Sports & Physics'),
  GameInfo('Trivia Blitz', Icons.quiz, 'Answer quick general-knowledge questions', (h) => TriviaBlitzGame(humans: h), category: 'Brain & Trivia'),
  GameInfo('Simon Tiles', Icons.grid_view_rounded, 'Tap the highlighted tile', (h) => SimonSequenceGame(humans: h), category: 'Quick Play'),
  GameInfo('Maze Escape', Icons.route, 'Navigate the maze and reach the goal', (h) => MazeEscapeGame(humans: h), category: 'Strategy & Puzzle'),
  GameInfo('Brick Breaker', Icons.sports_tennis, 'Move the paddle and break all bricks', (h) => BrickBreakerGame(humans: h), category: 'Strategy & Puzzle'),
  GameInfo('Platform Hopper', Icons.sports_esports, 'Jump across platforms to the finish', (h) => PlatformHopperGame(humans: h), category: 'Racing & Action'),
];

class PartyApp extends StatelessWidget {
  const PartyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Party Arena',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const MenuScreen(),
      );
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int humans = 1;
  String query = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final categories = games.map((game) => game.category).toSet().toList()..sort();
    categories.insert(0, 'All');
    final visibleGames = games
        .where((game) => (selectedCategory == 'All' || game.category == selectedCategory) &&
            (game.name.toLowerCase().contains(normalizedQuery) ||
            game.blurb.toLowerCase().contains(normalizedQuery)))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Arena'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${games.length} games',
                  style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Quick games. One device. Play together.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: DropdownButtonFormField<int>(
              value: humans,
              decoration: const InputDecoration(
                labelText: 'Players',
                prefixIcon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 human + CPU opponent')),
                DropdownMenuItem(value: 2, child: Text('2 human players')),
                DropdownMenuItem(value: 3, child: Text('3 human players')),
                DropdownMenuItem(value: 4, child: Text('4 human players')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => humans = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: categories.map((category) => DropdownMenuItem<String>(
                value: category, child: Text(category),
              )).toList(),
              onChanged: (value) { if (value != null) setState(() => selectedCategory = value); },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Find a game',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => query = ''),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: visibleGames.isEmpty
                ? const Center(child: Text('No games match that search.'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: visibleGames.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 158,
                    ),
                    itemBuilder: (context, index) {
                      final game = visibleGames[index];
                      final supported = humans <= game.maxPlayers;
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: supported
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GameScreen(
                                        info: game,
                                        humans: humans,
                                      ),
                                    ),
                                  )
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(game.icon, size: 28),
                                    const Spacer(),
                                    Icon(
                                      supported
                                          ? Icons.play_circle_outline
                                          : Icons.lock_outline,
                                      size: 20,
                                      color: supported
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  game.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Expanded(
                                  child: Text(
                                    supported
                                        ? game.blurb
                                        : 'Supports up to ${game.maxPlayers} human players',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.info, required this.humans});
  final GameInfo info;
  final int humans;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MiniGame game = widget.info.build(widget.humans);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.info.name),
          leading: IconButton(
            tooltip: 'Back to games',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            ValueListenableBuilder<String>(
              valueListenable: game.hud,
              builder: (_, score, __) => score.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Text(score,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) =>
                  game.pointerDown(event.pointer, game.toWorld(event.localPosition)),
              onPointerMove: (event) =>
                  game.pointerMove(event.pointer, game.toWorld(event.localPosition)),
              onPointerUp: (event) =>
                  game.pointerUp(event.pointer, game.toWorld(event.localPosition)),
              onPointerCancel: (event) =>
                  game.pointerUp(event.pointer, game.toWorld(event.localPosition)),
              child: GameWidget(key: ObjectKey(game), game: game),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: game.winner,
              builder: (_, result, __) => result == null
                  ? const SizedBox.shrink()
                  : ColoredBox(
                      color: const Color(0xCC0B1219),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_outlined, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                result,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: 220,
                                child: FilledButton.icon(
                                  onPressed: () => setState(
                                      () => game = widget.info.build(widget.humans)),
                                  icon: const Icon(Icons.replay),
                                  label: const Text('Rematch'),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Back to games'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
}
