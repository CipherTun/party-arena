import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

/// Air hockey and soccer share one engine: a puck/ball, two driven mallets/players, two goals.
class PuckGame extends MiniGame {
  PuckGame({required super.humans, required this.soccer});
  final bool soccer;
  late Blob puck;
  final mallets = <Blob>[];
  final target = <Vector2>[];
  final score = [0, 0];
  double get mr => soccer ? 2.0 : 2.2;

  @override
  Future<void> setup() async {
    final g = area.x * (soccer ? .3 : .22); // goal half-width
    wall(-hw - 1, 0, 1, hh + 1);
    wall(hw + 1, 0, 1, hh + 1);
    for (final s in [-1, 1]) {
      for (final x in [-1, 1]) {
        wall(x * (hw + g) / 2, s * (hh + 1), (hw - g) / 2, 1);
      }
    }
    world.add(Deco((c) {
      final line = Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .25;
      c.drawLine(Offset(-hw, 0), Offset(hw, 0), line);
      c.drawCircle(Offset.zero, 5, line);
      final goal = Paint()
        ..color = const Color(0x88FFFFFF)
        ..strokeWidth = .6;
      c.drawLine(Offset(-g, -hh), Offset(g, -hh), goal);
      c.drawLine(Offset(-g, hh), Offset(g, hh), goal);
    }));
    puck = spawn(Blob(
      pos: Vector2.zero(),
      r: soccer ? 1.4 : 1.1,
      color: const Color(0xFFFFFFFF),
      moves: true,
      bounce: soccer ? .6 : .92,
      friction: 0,
      damping: soccer ? .6 : .12,
    ));
    for (var i = 0; i < 2; i++) {
      final home = Vector2(0, i == 0 ? hh * .6 : -hh * .6);
      target.add(home.clone());
      mallets.add(spawn(Blob(
        pos: home,
        r: mr,
        color: playerColors[i],
        moves: true,
        density: 20,
        bounce: .3,
        friction: 0,
        fixedRot: true,
      )));
    }
  }

  Vector2 clampTarget(int p, double x, double y) {
    final lim = hh - mr, lx = hw - mr;
    var cy = y.clamp(-lim, lim).toDouble();
    if (!soccer) cy = p == 0 ? cy.clamp(mr, lim).toDouble() : cy.clamp(-lim, -mr).toDouble();
    return Vector2(x.clamp(-lx, lx).toDouble(), cy);
  }

  @override
  void onTouch(int p, Vector2 w, int phase) => target[p] = clampTarget(p, w.x, w.y);

  void bot(int p) {
    final pp = puck.p, m = mallets[p].p;
    final dir = p == 0 ? -1.0 : 1.0; // direction of opponent goal
    final mine = soccer || (p == 0 ? pp.y > 0 : pp.y < 0);
    if (!mine) {
      target[p] = clampTarget(p, pp.x * .4, p == 0 ? hh * .65 : -hh * .65);
      return;
    }
    final behind = (m.y - pp.y) * -dir > .8;
    final ty = (behind && (m.x - pp.x).abs() < 2.5) ? pp.y + dir * 4 : pp.y - dir * 4;
    target[p] = clampTarget(p, pp.x, ty);
  }

  void point(int s) {
    score[s]++;
    if (score[s] >= 5) return end(s);
    puck.body.setTransform(Vector2.zero(), 0);
    puck.body.linearVelocity = Vector2.zero();
    puck.body.angularVelocity = 0;
  }

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      if (isBot(p)) bot(p);
      final m = mallets[p];
      var d = (target[p] - m.p) * 14.0;
      final cap = isBot(p) ? 24.0 : 55.0;
      if (d.length > cap) d = d.normalized() * cap;
      m.body.linearVelocity = d;
    }
    final y = puck.p.y;
    if (y > hh + 1) {
      point(1);
    } else if (y < -hh - 1) {
      point(0);
    }
    hud.value = '${score[1]}  :  ${score[0]}';
  }
}
