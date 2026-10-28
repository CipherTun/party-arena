import 'dart:math';
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

/// Basketball with real gravity. Drag back like a slingshot and release; a dotted guide shows the arc.
class HoopsGame extends MiniGame {
  HoopsGame({required int humans}) : super(humans: humans, gravity: Vector2(0, g));
  static const g = 28.0;
  final balls = <Blob>[];
  final score = [0, 0];
  final state = [0, 0]; // 0 ready, 1 flying, 2 scored
  final timer = [0.0, 0.0];
  final prevY = [0.0, 0.0];
  final start = <Vector2?>[null, null];
  final cur = <Vector2?>[null, null];
  final wait = [1.5, 2.2];

  double sgn(int p) => p == 0 ? -1 : 1;
  double rimCx(int p) => sgn(p) * (hw - 4.7);
  double get rimY => hh * .15;
  Vector2 home(int p) => Vector2(sgn(p) * hw * .5, hh - 6);

  @override
  int zoneOf(Vector2 w) => w.x < 0 ? 0 : 1;

  Vector2 shotVel(Vector2 s, Vector2 e) {
    var v = (s - e) * 2.5;
    if (v.length > 55) v = v.normalized() * 55;
    return v;
  }

  @override
  Future<void> setup() async {
    wall(0, hh + 1, hw + 2, 1, bounce: .6, friction: .6);
    wall(0, -hh - 1, hw + 2, 1);
    wall(-hw - 1, 0, 1, hh + 2);
    wall(hw + 1, 0, 1, hh + 2);
    wall(0, 0, .4, hh);
    for (var p = 0; p < 2; p++) {
      wall(sgn(p) * (hw - 1), rimY - 4, .6, 5, bounce: .5);
      for (final s in [-1, 1]) {
        spawn(Blob(pos: Vector2(rimCx(p) + s * 2.6, rimY), r: .45, bounce: .4, color: playerColors[p]));
      }
      balls.add(spawn(Blob(
        pos: home(p),
        r: 1.2,
        color: playerColors[p],
        moves: true,
        bounce: .75,
        friction: .5,
        damping: .05,
      )));
      prevY[p] = home(p).y;
    }
    world.add(Deco((c) {
      for (var p = 0; p < 2; p++) {
        final s = start[p], e = cur[p];
        if (s == null || e == null || state[p] != 0 || balls.length < 2) continue;
        final v = shotVel(s, e), b = balls[p].p;
        final dot = Paint()..color = const Color(0x99FFFFFF);
        for (var k = 1; k <= 14; k++) {
          final t = k * .08;
          c.drawCircle(Offset(b.x + v.x * t, b.y + v.y * t + .5 * g * t * t), .25, dot);
        }
      }
    }));
  }

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (phase == 0) {
      start[p] = w.clone();
      cur[p] = w.clone();
    } else if (phase == 1) {
      cur[p] = w.clone();
    } else {
      final s = start[p], e = cur[p];
      if (s != null && e != null && state[p] == 0) {
        final v = shotVel(s, e);
        if (v.length > 8 && v.y < 0) shoot(p, v);
      }
      start[p] = null;
      cur[p] = null;
    }
  }

  void shoot(int p, Vector2 v) {
    state[p] = 1;
    timer[p] = 0;
    balls[p].body.linearVelocity = v;
  }

  Vector2 botVel(int p) {
    final b = home(p);
    final dx = rimCx(p) - b.x, h = b.y - rimY;
    final vy = sqrt(2 * g * (h + 3.5));
    final t = (vy + sqrt(vy * vy - 2 * g * h)) / g;
    return Vector2(dx / t * (1 + (rng.nextDouble() - .5) * .8), -vy * (1 + (rng.nextDouble() - .5) * .03));
  }

  void reset(int p) {
    state[p] = 0;
    balls[p].body.setTransform(home(p), 0);
    balls[p].body.linearVelocity = Vector2.zero();
    balls[p].body.angularVelocity = 0;
    prevY[p] = home(p).y;
  }

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      final b = balls[p];
      if (state[p] == 0) {
        b.body.setTransform(home(p), 0);
        b.body.linearVelocity = Vector2.zero();
        if (isBot(p) && (wait[p] -= dt) <= 0) {
          shoot(p, botVel(p));
          wait[p] = 1.2 + rng.nextDouble() * 1.5;
        }
        continue;
      }
      timer[p] += dt;
      final y = b.p.y;
      if (state[p] == 1 &&
          prevY[p] < rimY &&
          y >= rimY &&
          b.v.y > 0 &&
          (b.p.x - rimCx(p)).abs() < 2.1) {
        state[p] = 2;
        timer[p] = 0;
        score[p]++;
        if (score[p] >= 5) return end(p);
      }
      prevY[p] = y;
      if (timer[p] > (state[p] == 2 ? 1.0 : 3.2)) reset(p);
    }
    hud.value = '${score[0]}  :  ${score[1]}';
  }
}
