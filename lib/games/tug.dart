import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

/// Tap fast! Each tap is a real impulse on a heavy, damped block. Drag it over your line.
class TugGame extends MiniGame {
  TugGame({required super.humans});
  late Blob flag;
  double botTimer = .5;
  double get line => hh - 5;

  @override
  Future<void> setup() async {
    world.add(Deco((c) {
      c.drawLine(
          Offset(0, -hh),
          Offset(0, hh),
          Paint()
            ..color = const Color(0x44FFFFFF)
            ..strokeWidth = .4);
      for (var i = 0; i < 2; i++) {
        final y = i == 0 ? line : -line;
        c.drawLine(Offset(-hw, y), Offset(hw, y), Paint()..color = playerColors[i]..strokeWidth = .6);
      }
    }));
    flag = spawn(Blob(
      pos: Vector2.zero(),
      half: Vector2(5, 1.3),
      color: const Color(0xFFFFFFFF),
      moves: true,
      fixedRot: true,
      density: 4,
      damping: 2.2,
    ));
  }

  // Bottom player (0) pulls upward; top player (1) pulls downward.
  void pull(int p) => flag.body.applyLinearImpulse(Vector2(0, (p == 0 ? -1 : 1) * flag.body.mass * 3));

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (phase == 0) pull(p);
  }

  @override
  void tick(double dt) {
    flag.body.linearVelocity = Vector2(0, flag.v.y);
    for (var p = 0; p < 2; p++) {
      if (!isBot(p)) continue;
      botTimer -= dt;
      if (botTimer <= 0) {
        pull(p);
        botTimer = .2 + rng.nextDouble() * .1;
      }
    }
    if (flag.p.y > line) end(1);
    if (flag.p.y < -line) end(0);
  }
}
