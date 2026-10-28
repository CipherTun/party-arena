import 'dart:math';
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

/// Top-down sumo: hold a finger to pull your heavy ball toward it. Last one in the ring wins.
class SumoGame extends MiniGame {
  SumoGame({required super.humans});
  @override
  int get maxPlayers => 4;
  late double ring;
  final balls = <Blob>[];
  final aim = <Vector2?>[null, null, null, null];
  final alive = <bool>[];

  @override
  int zoneOf(Vector2 w) => n == 2 ? (w.y > 0 ? 0 : 1) : (w.y > 0 ? 0 : 2) + (w.x > 0 ? 1 : 0);

  Vector2 startPos(int i) {
    final d = ring * .45;
    return n == 2 ? Vector2(0, i == 0 ? d : -d) : Vector2(i % 2 == 0 ? -d : d, i < 2 ? d : -d);
  }

  @override
  Future<void> setup() async {
    ring = min(hw - 1, hh - 6);
    world.add(Deco((c) {
      c.drawCircle(Offset.zero, ring, Paint()..color = const Color(0xFF1E2F3F));
      c.drawCircle(
          Offset.zero,
          ring,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .5);
    }));
    for (var i = 0; i < n; i++) {
      alive.add(true);
      balls.add(spawn(Blob(
        pos: startPos(i),
        r: 2.2,
        color: playerColors[i],
        moves: true,
        density: 3,
        bounce: .6,
        friction: .1,
        damping: 1.5,
      )));
    }
  }

  @override
  void onTouch(int p, Vector2 w, int phase) => aim[p] = phase == 2 ? null : w.clone();

  Vector2 botAim(int i) {
    final me = balls[i].p;
    if (me.length > ring - 5) return Vector2.zero();
    Blob? best;
    var bd = 1e9;
    for (var j = 0; j < n; j++) {
      if (j == i || !alive[j]) continue;
      final d = (balls[j].p - me).length;
      if (d < bd) {
        bd = d;
        best = balls[j];
      }
    }
    if (best == null) return Vector2.zero();
    final o = best.p;
    return o + (o.length > .1 ? o.normalized() * 3 : Vector2(3, 0));
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < n; i++) {
      if (!alive[i]) continue;
      final b = balls[i];
      final t = isBot(i) ? botAim(i) : aim[i];
      if (t != null) {
        final d = t - b.p;
        if (d.length > .01) {
          final k = (d.length / 4).clamp(0.0, 1.0).toDouble();
          b.body.applyForce(d.normalized() * (b.body.mass * (isBot(i) ? 36 : 46) * k));
        }
      }
      if (b.p.length > ring + 1) {
        alive[i] = false;
        blobs.remove(b);
        b.removeFromParent();
      }
    }
    final left = [for (var i = 0; i < n; i++) if (alive[i]) i];
    if (left.length <= 1) end(left.isEmpty ? null : left.first);
  }
}
