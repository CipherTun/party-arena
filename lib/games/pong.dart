import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

/// Physics pong: the ball keeps its speed, paddle motion adds spin/angle, rallies speed up.
class PongGame extends MiniGame {
  PongGame({required super.humans});
  late Blob ball;
  final pads = <Blob>[];
  final tx = [0.0, 0.0];
  final score = [0, 0];
  double speed = 24;

  @override
  Future<void> setup() async {
    wall(-hw - 1, 0, 1, hh + 10);
    wall(hw + 1, 0, 1, hh + 10);
    for (var i = 0; i < 2; i++) {
      pads.add(spawn(Blob(
        pos: Vector2(0, i == 0 ? hh - 4 : -(hh - 4)),
        half: Vector2(4, .7),
        color: playerColors[i],
        moves: true,
        fixedRot: true,
        density: 20,
        bounce: 1,
        friction: .3,
      )));
    }
    ball = spawn(Blob(pos: Vector2.zero(), r: .9, color: const Color(0xFFFFFFFF), moves: true, bounce: 1, friction: 0));
    serve(rng.nextBool() ? 1 : -1);
  }

  void serve(int dir) {
    speed = 24;
    ball.body.setTransform(Vector2.zero(), 0);
    ball.body.linearVelocity = Vector2((rng.nextDouble() - .5) * 16, dir * speed);
  }

  @override
  void onTouch(int p, Vector2 w, int phase) => tx[p] = w.x;

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      final pad = pads[p];
      final home = p == 0 ? hh - 4 : -(hh - 4);
      var goal = tx[p];
      if (isBot(p)) goal = ball.p.x * .92;
      goal = goal.clamp(-hw + 4, hw - 4).toDouble();
      var vx = (goal - pad.p.x) * 14;
      final cap = isBot(p) ? 20.0 : 60.0;
      vx = vx.clamp(-cap, cap).toDouble();
      pad.body.linearVelocity = Vector2(vx, (home - pad.p.y) * 30);
    }
    speed = (speed + dt * .5).clamp(24, 44).toDouble();
    var v = ball.v.clone();
    if (v.length > .1 && v.length < speed) v = v.normalized() * speed;
    if (v.y.abs() < 8) v.y = v.y >= 0 ? 8 : -8;
    ball.body.linearVelocity = v;
    final y = ball.p.y;
    if (y > hh + 1) {
      score[1]++;
      score[1] >= 7 ? end(1) : serve(1);
    } else if (y < -hh - 1) {
      score[0]++;
      score[0] >= 7 ? end(0) : serve(-1);
    }
    hud.value = '${score[1]}  :  ${score[0]}';
  }
}
