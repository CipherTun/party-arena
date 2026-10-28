import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;

const playerColors = [Color(0xFF4FC3F7), Color(0xFFFF8A65), Color(0xFF9CCC65), Color(0xFFBA68C8)];
const playerNames = ['Blue', 'Orange', 'Green', 'Purple'];

/// A physics body (circle if [r] set, box if [half] set) that draws itself.
class Blob extends BodyComponent {
  Blob({
    required this.pos,
    this.r,
    this.half,
    Color color = const Color(0xFF2B3A4A),
    this.moves = false,
    this.bounce = .5,
    this.density = 1,
    this.friction = .2,
    this.damping = 0,
    this.fixedRot = false,
  }) : super(paint: Paint()..color = color);

  final Vector2 pos;
  final double? r;
  final Vector2? half;
  final bool moves, fixedRot;
  final double bounce, density, friction, damping;

  @override
  Body createBody() {
    final Shape shape;
    if (r != null) {
      shape = CircleShape()..radius = r!;
    } else {
      shape = PolygonShape()..setAsBox(half!.x, half!.y, Vector2.zero(), 0);
    }
    final b = world.createBody(BodyDef(
      position: pos.clone(),
      type: moves ? BodyType.dynamic : BodyType.static,
      linearDamping: damping,
      fixedRotation: fixedRot,
    ));
    b.createFixture(FixtureDef(shape, restitution: bounce, density: density, friction: friction));
    return b;
  }

  Vector2 get p => body.position;
  Vector2 get v => body.linearVelocity;
}

/// Non-physical drawing in world units (lines, rings, aim guides).
class Deco extends Component {
  Deco(this.draw, {int layer = -5}) {
    priority = layer;
  }
  final void Function(Canvas) draw;
  @override
  void render(Canvas canvas) => draw(canvas);
}

abstract class MiniGame extends Forge2DGame {
  MiniGame({required this.humans, Vector2? gravity}) : super(gravity: gravity ?? Vector2.zero());

  final int humans;
  int get maxPlayers => 2;
  int get n => min(max(humans, 2), maxPlayers); // competitors
  bool isBot(int i) => i >= humans;

  final hud = ValueNotifier<String>('');
  final winner = ValueNotifier<String?>(null);
  final rng = Random();
  final blobs = <Blob>[];
  final touches = <int, int>{};
  late Vector2 area; // visible size in world units, origin at centre
  bool _built = false;
  double get hw => area.x / 2;
  double get hh => area.y / 2;
  bool get over => winner.value != null;
  bool get isReady => _built && blobs.every((b) => b.isLoaded);

  @override
  Color backgroundColor() => const Color(0xFF0F1A24);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();
    area = size / camera.viewfinder.zoom;
    await setup();
    _built = true;
  }

  Future<void> setup();
  void tick(double dt);
  void onTouch(int player, Vector2 w, int phase) {} // 0 down, 1 move, 2 up
  int zoneOf(Vector2 w) => w.y > 0 ? 0 : 1; // bottom = player 0

  @override
  void update(double dt) {
    super.update(dt);
    if (!isReady || over) return;
    tick(min(dt, 1 / 30));
  }

  Blob spawn(Blob b) {
    blobs.add(b);
    world.add(b);
    return b;
  }

  void wall(double x, double y, double hx, double hy, {double bounce = 1, double friction = 0}) =>
      spawn(Blob(pos: Vector2(x, y), half: Vector2(hx, hy), bounce: bounce, friction: friction));

  void end(int? p) {
    winner.value = p == null ? 'Draw!' : '${playerNames[p]} wins!';
    pauseEngine();
  }

  Vector2 toWorld(Offset o) =>
      Vector2((o.dx - size.x / 2) / camera.viewfinder.zoom, (o.dy - size.y / 2) / camera.viewfinder.zoom);

  void pointerDown(int id, Vector2 w) {
    if (over || !_built) return;
    final p = zoneOf(w);
    if (p < humans && p < n) {
      touches[id] = p;
      onTouch(p, w, 0);
    }
  }

  void pointerMove(int id, Vector2 w) {
    final p = touches[id];
    if (p != null && !over) onTouch(p, w, 1);
  }

  void pointerUp(int id, Vector2 w) {
    final p = touches.remove(id);
    if (p != null && !over) onTouch(p, w, 2);
  }
}
