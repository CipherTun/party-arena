import 'dart:math';
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../core.dart';

abstract class ArcadeGame extends MiniGame {
  ArcadeGame({required super.humans});
  @override
  Future<void> setup() async { world.add(Deco(paintGame)); }
  void paintGame(Canvas c);
  void text(Canvas c, String s, Offset p, {double size = 2.5, Color color = const Color(0xFFFFFFFF)}) {
    final t = TextPainter(text: TextSpan(text:s, style:TextStyle(color:color,fontSize:size,fontWeight:FontWeight.w800)), textDirection:TextDirection.ltr)..layout(maxWidth:hw*2);
    t.paint(c,p-Offset(t.width/2,t.height/2));
  }
  void rule(Canvas c, Offset a, Offset b) => c.drawLine(a,b,Paint()..color=const Color(0x88FFFFFF)..strokeWidth=.3);
}

class QuickTapGame extends ArcadeGame {
  QuickTapGame({required super.humans});
  final score=[0,0]; double left=12, bot=.2;
  @override void paintGame(Canvas c) {
    c.drawRect(Rect.fromLTRB(-hw,-hh,hw,0),Paint()..color=const Color(0xFF382A2A));
    c.drawRect(Rect.fromLTRB(-hw,0,hw,hh),Paint()..color=const Color(0xFF1B3444));
    rule(c,Offset(-hw,0),Offset(hw,0)); text(c,'TAP RACE',Offset(0,-hh+4));
    text(c,'${score[1]}',Offset(0,-hh*.45),size:9,color:playerColors[1]); text(c,'${score[0]}',Offset(0,hh*.45),size:9,color:playerColors[0]); text(c,'${left.ceil()}s',Offset.zero,size:3);
  }
  @override void onTouch(int p,Vector2 w,int phase){if(phase==0)score[p]++;}
  @override void tick(double dt){left-=dt;bot-=dt;if(isBot(1)&&bot<=0){score[1]++;bot=.15+rng.nextDouble()*.25;}if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

class ReactionGame extends ArcadeGame {
  ReactionGame({required super.humans});
  double wait=1.5, elapsed=0, bot=.35; bool go=false; final times=<double?>[null,null]; final early=[false,false];
  @override void paintGame(Canvas c){c.drawCircle(Offset.zero,min(hw,hh)*.34,Paint()..color=go?const Color(0xFF36D477):const Color(0xFFB84242));text(c,go?'TAP!':'WAIT',Offset.zero,size:4);text(c,'REACTION DUEL',Offset(0,-hh+4));text(c,early[0]?'FALSE START':times[0]==null?'BLUE':'${(times[0]!*1000).round()} ms',Offset(0,hh*.55),color:playerColors[0]);text(c,early[1]?'FALSE START':times[1]==null?'ORANGE':'${(times[1]!*1000).round()} ms',Offset(0,-hh*.55),color:playerColors[1]);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||times[p]!=null||early[p])return;if(!go){early[p]=true;}else{times[p]=elapsed;} _finishIfReady();}
  void _finishIfReady(){if(early[0]||early[1]){if(early[0]&&early[1])end(null);else end(early[0]?1:0);return;}if(times[0]!=null&&times[1]!=null)end(times[0]==times[1]?null:times[0]!<times[1]! ? 0:1);}
  @override void tick(double dt){elapsed+=dt;if(!go){wait-=dt;if(wait<=0)go=true;}else if(isBot(1)&&times[1]==null){bot-=dt;if(bot<=0){times[1]=elapsed;_finishIfReady();}}}
}

class ColorMatchGame extends ArcadeGame {
  ColorMatchGame({required super.humans});
  final palette=[const Color(0xFFEF5350),const Color(0xFF42A5F5),const Color(0xFFFFCA28),const Color(0xFF66BB6A)];
  final names=['RED','BLUE','YELLOW','GREEN']; final score=[0,0]; int target=0; double left=15,bot=.5;
  @override Future<void> setup() async {target=rng.nextInt(4);await super.setup();}
  @override void paintGame(Canvas c){text(c,'COLOR CLASH',Offset(0,-hh+3));text(c,'TAP ${names[target]}',Offset(0,-hh+7),size:3,color:palette[target]);for(int p=0;p<2;p++){for(int i=0;i<4;i++){final x=(i%2==0?-1:1)*hw*.27,y=(p==1?-1:1)*(i<2?hh*.14:hh*.36);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(x,y),width:hw*.4,height:hh*.19),const Radius.circular(1)),Paint()..color=palette[i]);text(c,names[i],Offset(x,y),size:1.6,color:const Color(0xFF101820));}}text(c,'${score[1]}  -  ${score[0]}',Offset(0,hh-4),size:3);text(c,'${left.ceil()}s',Offset.zero);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0)return;final row=(w.y.abs()>hh*.25)?1:0;final i=row*2+(w.x<0?0:1);if(i==target)score[p]++;else score[p]=max(0,score[p]-1);target=rng.nextInt(4);}
  @override void tick(double dt){left-=dt;bot-=dt;if(isBot(1)&&bot<=0){score[1]+=rng.nextDouble()<.7?1:0;bot=.4+rng.nextDouble()*.4;}if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

class WhackGame extends ArcadeGame {
  WhackGame({required super.humans}); int active=0;final score=[0,0];double change=.7,left=20;
  @override void paintGame(Canvas c){text(c,'WHACK-A-DOT',Offset(0,-hh+3));for(int i=0;i<6;i++){final p=Offset((i%3-1)*hw*.48,(i<3?-1:1)*hh*.22);c.drawCircle(p,min(hw*.12,hh*.1),Paint()..color=i==active?const Color(0xFFFFD54F):const Color(0xFF334958));if(i==active)c.drawCircle(p,min(hw*.05,hh*.04),Paint()..color=const Color(0xFF17232C));}text(c,'${score[1]}  -  ${score[0]}',Offset(0,0),size:3);text(c,'${left.ceil()}s',Offset(0,hh-4));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0)return;final col=((w.x/(hw*.96)+1)*1.5).floor().clamp(0,2).toInt(),row=w.y<0?0:1;if(row*3+col==active){score[p]++;active=rng.nextInt(6);change=.6;}}
  @override void tick(double dt){left-=dt;change-=dt;if(change<=0){active=rng.nextInt(6);change=.6+rng.nextDouble()*.5;}if(isBot(1)&&rng.nextDouble()<dt*.9)score[1]++;if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

class TicTacToeGame extends ArcadeGame {
  TicTacToeGame({required super.humans}); final board=List<int>.filled(9,0);int turn=1;bool botMoved=false;
  @override void paintGame(Canvas c){text(c,'TIC TAC TOE',Offset(0,-hh+3));final s=min(hw*.78,hh*.65);for(int i=1;i<3;i++){rule(c,Offset(-s/2+i*s/3,-s/2),Offset(-s/2+i*s/3,s/2));rule(c,Offset(-s/2,-s/2+i*s/3),Offset(s/2,-s/2+i*s/3));}for(int i=0;i<9;i++){if(board[i]!=0)text(c,board[i]==1?'X':'O',Offset(-s/2+(i%3+.5)*s/3,-s/2+(i~/3+.5)*s/3),size:s/5,color:playerColors[board[i]-1]);}text(c,humans==1?'YOU: X  ·  BOT: O':turn==1?'BLUE: X TURN':'ORANGE: O TURN',Offset(0,hh-4),size:2);}
  @override int zoneOf(Vector2 w)=>0;
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||(humans==1&&turn!=1))return;_play(w);}
  void _play(Vector2 w){final s=min(hw*.78,hh*.65),col=((w.x+s/2)/(s/3)).floor(),row=((w.y+s/2)/(s/3)).floor();if(col<0||col>2||row<0||row>2)return;final i=row*3+col;if(board[i]!=0)return;board[i]=turn;if(_won(turn)){end(turn-1);return;}if(board.every((v)=>v!=0)){end(null);return;}turn=turn==1?2:1;botMoved=false;}
  bool _won(int p){const ls=[[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];return ls.any((l)=>l.every((i)=>board[i]==p));}
  @override void tick(double dt){if(humans!=1||turn!=2||botMoved)return;botMoved=true;final empty=[for(int i=0;i<9;i++)if(board[i]==0)i];if(empty.isEmpty)return;int pick=empty.first;bool found=false;for(final i in empty){board[i]=2;if(_won(2)){pick=i;found=true;}board[i]=0;if(found)break;}if(!found)for(final i in empty){board[i]=1;if(_won(1)){pick=i;found=true;}board[i]=0;if(found)break;}if(!found)pick=empty.contains(4)?4:empty[rng.nextInt(empty.length)];board[pick]=2;if(_won(2)){end(1);return;}if(board.every((v)=>v!=0)){end(null);return;}turn=1;}
}

class RpsGame extends ArcadeGame {
  RpsGame({required super.humans});final picks=<int?>[null,null];int round=1;final wins=[0,0];
  @override void paintGame(Canvas c){text(c,'ROCK PAPER SCISSORS',Offset(0,-hh+3),size:2.2);text(c,picks[1]==null?'TOP: TAP TO PICK':['ROCK','PAPER','SCISSORS'][picks[1]!],Offset(0,-hh*.4),color:playerColors[1]);text(c,picks[0]==null?'BOTTOM: TAP TO PICK':['ROCK','PAPER','SCISSORS'][picks[0]!],Offset(0,hh*.4),color:playerColors[0]);text(c,'${wins[1]}  -  ${wins[0]}',Offset.zero,size:4);text(c,'ROUND $round / 3',Offset(0,hh-4));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||picks[p]!=null)return;picks[p]=rng.nextInt(3);if(isBot(1))picks[1]=rng.nextInt(3);if(picks.every((v)=>v!=null)){final a=picks[0]!,b=picks[1]!;if(a!=b){if((a-b+3)%3==1)wins[0]++;else wins[1]++;}if(round==3){end(wins[0]==wins[1]?null:wins[0]>wins[1]?0:1);}else{round++;picks[0]=null;picks[1]=null;}}}
  @override void tick(double dt){}
}

/// Tap to accelerate; reach the finish first. Works with one or two players.
class RacingGame extends ArcadeGame {
  RacingGame({required super.humans});
  final progress = [0.0, 0.0];
  double botClock = .18;
  @override void paintGame(Canvas c) {
    text(c, 'SPRINT RACE', Offset(0, -hh + 3));
    for (var p=0; p<2; p++) {
      final y = p == 0 ? hh*.35 : -hh*.35;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-hw*.8,y-hh*.09,hw*.8,y+hh*.09),const Radius.circular(1)),Paint()..color=const Color(0xFF263A49));
      final x = -hw*.8 + progress[p]*hw*1.6;
      c.drawCircle(Offset(x,y), min(hw*.08,hh*.08), Paint()..color=playerColors[p]);
      text(c, '${(progress[p]*100).round()}%', Offset(-hw*.65,y+hh*.14),size:2,color:playerColors[p]);
    }
    rule(c, Offset(hw*.8,-hh*.58), Offset(hw*.8,hh*.58));
    text(c,'TAP YOUR HALF TO ACCELERATE',Offset(0,0),size:2);
  }
  @override void onTouch(int p,Vector2 w,int phase) { if(phase==0) progress[p]=min(1,progress[p]+.035); }
  @override void tick(double dt) {
    if(isBot(1)){botClock-=dt;if(botClock<=0){progress[1]=min(1,progress[1]+.012+rng.nextDouble()*.02);botClock=.12+rng.nextDouble()*.18;}}
    if(progress[0]>=1||progress[1]>=1) end(progress[0]==progress[1]?null:progress[0]>progress[1]?0:1);
  }
}

/// Tank duel uses visible moving shells; the shell must reach the opposing tank to score.
class TankDuelGame extends ArcadeGame {
  TankDuelGame({required super.humans});

  final hp = [3, 3];
  final cooldown = [0.0, 0.0];
  final shells = <_TankShell>[];
  double botClock = .8;

  Offset _tank(int p) => Offset(p == 0 ? -hw * .42 : hw * .42,
      p == 0 ? hh * .38 : -hh * .38);

  @override
  void paintGame(Canvas c) {
    text(c, 'TANK DUEL', Offset(0, -hh + 3));
    for (var p = 0; p < 2; p++) {
      final pos = _tank(p);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: hw * .28, height: hh * .16),
          const Radius.circular(1),
        ),
        Paint()..color = playerColors[p],
      );
      rule(c, pos, Offset(pos.dx + (p == 0 ? hw * .24 : -hw * .24), pos.dy));
      for (var i = 0; i < 3; i++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-hw * .7 + i * hw * .5,
                p == 0 ? hh * .64 : -hh * .72, hw * .35, hh * .045),
            const Radius.circular(.5),
          ),
          Paint()..color = i < hp[p]
              ? playerColors[p]
              : const Color(0xFF26323C),
        );
      }
      text(c, '${hp[p]} HP', Offset(pos.dx, pos.dy + hh * .13), size: 2);
    }
    for (final shell in shells) {
      c.drawCircle(Offset(shell.x, shell.y), .8,
          Paint()..color = const Color(0xFFFFD54F));
    }
    text(c, 'TAP YOUR HALF TO FIRE', Offset(0, 0), size: 2.4);
  }

  void _fire(int p) {
    if (cooldown[p] > 0 || hp[p] <= 0) return;
    cooldown[p] = .65;
    final from = _tank(p);
    final to = _tank(1 - p);
    const travelTime = .55;
    shells.add(_TankShell(
      p,
      from.dx,
      from.dy,
      (to.dx - from.dx) / travelTime,
      (to.dy - from.dy) / travelTime,
    ));
  }

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (phase == 0) _fire(p);
  }

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      cooldown[p] = max(0, cooldown[p] - dt);
    }
    if (isBot(1) && hp[1] > 0) {
      botClock -= dt;
      if (botClock <= 0) {
        _fire(1);
        botClock = .75;
      }
    }
    for (final shell in List<_TankShell>.of(shells)) {
      shell.x += shell.vx * dt;
      shell.y += shell.vy * dt;
      final target = _tank(1 - shell.owner);
      if ((Offset(shell.x, shell.y) - target).distance < min(hw * .12, hh * .08)) {
        hp[1 - shell.owner] = max(0, hp[1 - shell.owner] - 1);
        shells.remove(shell);
      } else if (shell.x.abs() > hw || shell.y.abs() > hh) {
        shells.remove(shell);
      }
    }
    if (hp[0] <= 0 || hp[1] <= 0) {
      end(hp[0] == hp[1] ? null : hp[0] > hp[1] ? 0 : 1);
    }
  }
}

class _TankShell {
  _TankShell(this.owner, this.x, this.y, this.vx, this.vy);
  final int owner;
  double x;
  double y;
  final double vx;
  final double vy;
}

/// Aim by tapping left/right of the centre; score points for shots near the bullseye.
class ArcheryGame extends ArcadeGame {
  ArcheryGame({required super.humans});
  final score=[0,0]; final shots=[0,0]; final last=[0,0];
  @override void paintGame(Canvas c){text(c,'ARCHERY DUEL',Offset(0,-hh+3));final center=Offset.zero;for(var i=4;i>=1;i--)c.drawCircle(center,min(hw*.34,hh*.3)*i/4,Paint()..color=[const Color(0xFFE64A4A),const Color(0xFFF7F7F7),const Color(0xFF42A5F5),const Color(0xFFFFD54F)][(4-i)%4]);c.drawCircle(center,min(hw*.34,hh*.3)*.12,Paint()..color=const Color(0xFF263238));text(c,'${score[1]}  -  ${score[0]}',Offset(0,hh*.58),size:3);text(c,'${shots[1]}/5 SHOTS',Offset(0,-hh*.55),size:2,color:playerColors[1]);text(c,'${shots[0]}/5 SHOTS',Offset(0,hh*.72),size:2,color:playerColors[0]);text(c,'TAP TO AIM & SHOOT',Offset(0,0),size:2);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||shots[p]>=5)return;shots[p]++;final error=(w.x/hw).abs()*.65+(w.y.abs()/hh)*.35;final points=error<.2?10:error<.42?7:error<.68?4:1;last[p]=points;score[p]+=points;if(shots.every((s)=>s>=5))end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
  @override void tick(double dt){if(isBot(1)&&shots[1]<5&&rng.nextDouble()<dt*.7){shots[1]++;score[1]+=[1,4,7,10][rng.nextInt(4)];if(shots.every((s)=>s>=5))end(score[0]==score[1]?null:score[0]>score[1]?0:1);}}
}

/// Turn-based memory match. Tap two tiles per turn; matched pairs score a point.
class MemoryGridGame extends ArcadeGame {
  MemoryGridGame({required super.humans});
  final tiles=<int>[]; final revealed=<int>{}; final matched=<int>{}; final points=[0,0];
  int turn=0; int? first; double lock=0; double botClock=.5;
  @override Future<void> setup() async {final vals=[0,0,1,1,2,2,3,3,4,4,5,5]..shuffle(rng);tiles.addAll(vals);await super.setup();}
  @override void paintGame(Canvas c){text(c,'MEMORY MATCH',Offset(0,-hh+3));final cw=hw*.24,ch=hh*.19;for(var i=0;i<12;i++){final x=(i%4-1.5)*hw*.43,y=(i~/4-1)*hh*.31;final open=revealed.contains(i)||matched.contains(i);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(x,y),width:cw,height:ch),const Radius.circular(1)),Paint()..color=open?const Color(0xFFECEFF1):const Color(0xFF31566D));if(open)text(c,'${tiles[i]+1}',Offset(x,y),size:3,color:const Color(0xFF17232C));}text(c,'BLUE ${points[0]}  ·  ORANGE ${points[1]}',Offset(0,hh*.78),size:2.2);text(c,turn==0?'BLUE TURN':'ORANGE TURN',Offset(0,-hh*.7),size:2,color:playerColors[turn]);}
  @override int zoneOf(Vector2 w)=>0;
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||lock>0|| (humans==1&&turn==1))return;final col=((w.x/(hw*.86)+1)*2).floor().clamp(0,3).toInt();final row=((w.y/(hh*.62)+1)*1.5).floor().clamp(0,2).toInt();final i=row*4+col;if(matched.contains(i)||revealed.contains(i))return;revealed.add(i);if(first==null){first=i;}else{final a=first!;if(tiles[a]==tiles[i]){matched.add(a);matched.add(i);points[turn]++;if(matched.length==12){end(points[0]==points[1]?null:points[0]>points[1]?0:1);return;}}else{lock=.75;}first=null;turn=1-turn;}}
  @override void tick(double dt){if(lock>0){lock-=dt;if(lock<=0)revealed.removeWhere((i)=>!matched.contains(i));}if(isBot(1)&&turn==1&&lock<=0){botClock-=dt;if(botClock<=0){final available=[for(var i=0;i<12;i++)if(!matched.contains(i)&&!revealed.contains(i))i];if(available.isNotEmpty){final a=available[rng.nextInt(available.length)];revealed.add(a);first=a;final rest=[for(var i=0;i<12;i++)if(i!=a&&!matched.contains(i)&&!revealed.contains(i))i];if(rest.isNotEmpty){final b=rest.firstWhere((i)=>tiles[i]==tiles[a],orElse:()=>rest[rng.nextInt(rest.length)]);revealed.add(b);if(tiles[a]==tiles[b]){matched.add(a);matched.add(b);points[1]++;}else lock=.75;first=null;turn=0;}}botClock=1.0;}}}
}

class ConnectFourGame extends ArcadeGame {
  ConnectFourGame({required super.humans});
  final board=List<int>.filled(42,0); int turn=1;
  @override void paintGame(Canvas c){text(c,'CONNECT FOUR',Offset(0,-hh+3));final cw=hw*.23,ch=hh*.15;for(var r=0;r<6;r++)for(var col=0;col<7;col++){final x=(col-3)*cw,y=(r-2.5)*ch;final v=board[r*7+col];c.drawCircle(Offset(x,y),min(cw,ch)*.38,Paint()..color=v==0?const Color(0xFF314452):playerColors[v-1]);}text(c,humans==1?'YOU: BLUE  ·  BOT: ORANGE':turn==1?'BLUE TURN':'ORANGE TURN',Offset(0,hh-4),size:2);}
  @override int zoneOf(Vector2 w)=>0;
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||(humans==1&&turn==2))return;_drop(((w.x/hw+1)*3.5).floor().clamp(0,6).toInt());}
  void _drop(int col){for(var r=5;r>=0;r--){final i=r*7+col;if(board[i]==0){board[i]=turn;if(_win(turn)){end(turn-1);return;}if(board.every((v)=>v!=0)){end(null);return;}turn=3-turn;return;}}}
  bool _win(int p){for(var r=0;r<6;r++)for(var c=0;c<7;c++){for(final d in [[0,1],[1,0],[1,1],[1,-1]]){var ok=true;for(var k=0;k<4;k++){final rr=r+d[0]*k,cc=c+d[1]*k;if(rr<0||rr>=6||cc<0||cc>=7||board[rr*7+cc]!=p){ok=false;break;}}if(ok)return true;}}return false;}
  @override void tick(double dt){if(humans!=1||turn!=2)return;final legal=[for(var c=0;c<7;c++)if(board[c]==0)c];if(legal.isEmpty)return;int pick=legal[rng.nextInt(legal.length)];for(final c in legal){final r=List<int>.generate(6,(i)=>board[i*7+c]).lastIndexWhere((v)=>v==0);if(r>=0){board[r*7+c]=2;if(_win(2)){end(1);return;}board[r*7+c]=0;}}_drop(pick);}
}

class DotsBoxesGame extends ArcadeGame {
  DotsBoxesGame({required super.humans});
  // 3 x 3 dots make four boxes; edges are selected by tapping near them.
  final edges=<String>{}; final boxes=<int,int>{}; int turn=0; int moves=0;
  @override void paintGame(Canvas c){text(c,'DOTS & BOXES',Offset(0,-hh+3));final s=min(hw*.8,hh*.62);Offset pt(int x,int y)=>Offset(-s/2+x*s/2,-s/2+y*s/2);for(var y=0;y<2;y++)for(var x=0;x<2;x++){final owner=boxes[y*2+x];if(owner!=null)c.drawRect(Rect.fromLTRB(pt(x,y).dx,pt(x,y).dy,pt(x+1,y+1).dx,pt(x+1,y+1).dy),Paint()..color=playerColors[owner].withOpacity(.3));}for(var y=0;y<3;y++)for(var x=0;x<3;x++)c.drawCircle(pt(x,y),.65,Paint()..color=const Color(0xFFFFFFFF));for(var y=0;y<3;y++)for(var x=0;x<2;x++)if(edges.contains('h$x,$y'))rule(c,pt(x,y),pt(x+1,y));for(var y=0;y<2;y++)for(var x=0;x<3;x++)if(edges.contains('v$x,$y'))rule(c,pt(x,y),pt(x,y+1));text(c,'BLUE ${boxes.values.where((v)=>v==0).length}  ·  ORANGE ${boxes.values.where((v)=>v==1).length}',Offset(0,hh*.72),size:2);text(c,turn==0?'BLUE DRAW A LINE':'ORANGE DRAW A LINE',Offset(0,hh-4),size:2,color:playerColors[turn]);}
  @override int zoneOf(Vector2 w)=>0;
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||(humans==1&&turn==1))return;final s=min(hw*.8,hh*.62);final gx=((w.x+s/2)/(s/2)).clamp(0,2),gy=((w.y+s/2)/(s/2)).clamp(0,2);final x=gx.floor().clamp(0,2).toInt(),y=gy.floor().clamp(0,2).toInt();final fx=gx-x,fy=gy-y;String key;if(fx>fy&&fx+fy<1)key='h${x.clamp(0,1)},${y.clamp(0,2)}';else if(fx<fy&&fx+fy>1)key='h${x.clamp(0,1)},${(y+1).clamp(0,2)}';else if(fx>fy)key='v${(x+1).clamp(0,2)},${y.clamp(0,1)}';else key='v${x.clamp(0,2)},${y.clamp(0,1)}';if(edges.contains(key))return;edges.add(key);moves++;final got=_claim();if(!got)turn=1-turn;if(boxes.length==4){final a=boxes.values.where((v)=>v==0).length,b=boxes.values.where((v)=>v==1).length;end(a==b?null:a>b?0:1);}}
  bool _claim(){bool got=false;for(var y=0;y<2;y++)for(var x=0;x<2;x++){final id=y*2+x;if(boxes.containsKey(id))continue;if(edges.contains('h$x,$y')&&edges.contains('h$x,${y+1}')&&edges.contains('v$x,$y')&&edges.contains('v${x+1},$y')){boxes[id]=turn;got=true;}}return got;}
  @override void tick(double dt){if(humans!=1||turn!=1||edges.length>=12)return;final candidates=<String>[];for(var y=0;y<3;y++)for(var x=0;x<2;x++)if(!edges.contains('h$x,$y'))candidates.add('h$x,$y');for(var y=0;y<2;y++)for(var x=0;x<3;x++)if(!edges.contains('v$x,$y'))candidates.add('v$x,$y');if(candidates.isEmpty)return;edges.add(candidates[rng.nextInt(candidates.length)]);final got=_claim();if(!got)turn=0;if(boxes.length==4){final a=boxes.values.where((v)=>v==0).length,b=boxes.values.where((v)=>v==1).length;end(a==b?null:a>b?0:1);}}
}

/// Mini golf uses velocity and friction: drag backward and release to putt.
class MiniGolfGame extends ArcadeGame {
  MiniGolfGame({required super.humans});

  final strokes = [0, 0];
  final ballX = [0.0, 0.0];
  final velocity = [0.0, 0.0];
  final done = [false, false];
  final dragStart = <Vector2?>[null, null];
  final dragCurrent = <Vector2?>[null, null];
  double botClock = .8;
  double get startX => -hw * .65;
  double get holeX => hw * .58;
  double get holeRadius => min(hw * .055, hh * .055);

  @override
  Future<void> setup() async {
    ballX[0] = startX;
    ballX[1] = startX;
    await super.setup();
  }

  @override
  void paintGame(Canvas c) {
    text(c, 'MINI GOLF', Offset(0, -hh + 3));
    for (var p = 0; p < 2; p++) {
      final y = p == 0 ? hh * .3 : -hh * .3;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-hw * .75, y - hh * .12, hw * .75, y + hh * .12),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF28533F),
      );
      c.drawCircle(Offset(holeX, y), holeRadius, Paint()..color = const Color(0xFF101820));
      c.drawCircle(Offset(ballX[p], y), holeRadius * .62, Paint()..color = playerColors[p]);
      text(c, done[p] ? 'HOLED' : 'STROKES ${strokes[p]}',
          Offset(-hw * .35, y + hh * .16), size: 2, color: playerColors[p]);
      final a = dragStart[p], b = dragCurrent[p];
      if (a != null && b != null) {
        rule(c, Offset(ballX[p], y), Offset(ballX[p] + (a.x - b.x) * .45, y));
      }
    }
    text(c, 'DRAG BACK, RELEASE TO PUTT', Offset(0, 0), size: 2);
  }

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (done[p]) return;
    if (phase == 0 && velocity[p].abs() < .1) {
      dragStart[p] = w.clone();
      dragCurrent[p] = w.clone();
    } else if (phase == 1 && dragStart[p] != null) {
      dragCurrent[p] = w.clone();
    } else if (phase == 2 && dragStart[p] != null) {
      final a = dragStart[p]!;
      final b = dragCurrent[p] ?? w;
      var shot = (a.x - b.x) * 2.8;
      if (shot.abs() < 2) shot = holeX >= ballX[p] ? 7 : -7;
      velocity[p] = shot.clamp(-18.0, 18.0).toDouble();
      strokes[p]++;
      dragStart[p] = null;
      dragCurrent[p] = null;
      if (strokes[p] >= 5) done[p] = true;
    }
  }

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      if (velocity[p].abs() > .05) {
        ballX[p] += velocity[p] * dt;
        velocity[p] -= velocity[p].sign * 7.5 * dt;
        if (velocity[p].abs() < .5 && ballX[p] < holeX - holeRadius) {
          velocity[p] = 0;
        }
        if ((ballX[p] - holeX).abs() <= holeRadius && velocity[p].abs() < 5) {
          ballX[p] = holeX;
          velocity[p] = 0;
          done[p] = true;
        }
        if (ballX[p] < -hw * .72 || ballX[p] > hw * .72) {
          ballX[p] = ballX[p].clamp(-hw * .72, hw * .72).toDouble();
          velocity[p] = -velocity[p] * .35;
        }
      } else {
        velocity[p] = 0;
      }
    }
    if (isBot(1) && !done[1] && velocity[1].abs() < .1) {
      botClock -= dt;
      if (botClock <= 0) {
        velocity[1] = (holeX - ballX[1]).sign * (7 + rng.nextDouble() * 3);
        strokes[1]++;
        botClock = 1.3;
        if (strokes[1] >= 5) done[1] = true;
      }
    }
    if (done.every((value) => value)) {
      end(strokes[0] == strokes[1]
          ? null
          : strokes[0] < strokes[1]
              ? 0
              : 1);
    }
  }
}

/// Boat race: tap rapidly to paddle to the finish line.
class BoatRaceGame extends ArcadeGame {
  BoatRaceGame({required super.humans});final progress=[0.0,0.0];double bot=.2;
  @override void paintGame(Canvas c){c.drawRect(Rect.fromLTRB(-hw,-hh,hw,hh),Paint()..color=const Color(0xFF174A66));for(var i=0;i<5;i++)rule(c,Offset(-hw+i*hw*.5,-hh),Offset(-hw+i*hw*.5,hh));text(c,'BOAT RACE',Offset(0,-hh+3));for(var p=0;p<2;p++){final y=p==0?hh*.32:-hh*.32,x=-hw*.78+progress[p]*hw*1.55;c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(x,y),width:hw*.18,height:hh*.12),const Radius.circular(2)),Paint()..color=playerColors[p]);text(c,'${(progress[p]*100).round()}%',Offset(x,y+hh*.12),size:2);}rule(c,Offset(hw*.8,-hh*.6),Offset(hw*.8,hh*.6));text(c,'TAP TO PADDLE',Offset(0,0),size:2);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase==0)progress[p]=min(1,progress[p]+.025);}
  @override void tick(double dt){if(isBot(1)){bot-=dt;if(bot<=0){progress[1]=min(1,progress[1]+.012+rng.nextDouble()*.018);bot=.15+rng.nextDouble()*.2;}}if(progress.any((v)=>v>=1))end(progress[0]==progress[1]?null:progress[0]>progress[1]?0:1);}
}

/// Jump the moving barrier; survive to the end of the round.
class ObstacleRunGame extends ArcadeGame {
  ObstacleRunGame({required super.humans});final alive=[true,true],score=[0,0],jump=[0.0,0.0];double obstacle=1,left=25,bot=.3;
  @override void paintGame(Canvas c){text(c,'OBSTACLE RUN',Offset(0,-hh+3));for(var p=0;p<2;p++){final y=p==0?hh*.32:-hh*.32,x=hw*.65-obstacle*hw*1.3;c.drawRect(Rect.fromLTRB(-hw*.8,y-hh*.035,hw*.8,y+hh*.035),Paint()..color=const Color(0xFF3D5362));c.drawRect(Rect.fromLTRB(x-hw*.04,y-hh*.09,x+hw*.04,y+hh*.09),Paint()..color=const Color(0xFFFF7043));c.drawCircle(Offset(-hw*.45,y-(jump[p]>0?hh*.12:0)),min(hw*.06,hh*.06),Paint()..color=playerColors[p]);text(c,alive[p]?'${score[p]}':'OUT',Offset(-hw*.65,y+hh*.12),size:2,color:playerColors[p]);}text(c,'TAP YOUR HALF TO JUMP',Offset(0,0),size:2);text(c,'${left.ceil()}s',Offset(0,hh-4));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase==0&&alive[p]&&jump[p]<=0)jump[p]=.38;}
  @override void tick(double dt){left-=dt;obstacle-=dt*.45;for(var p=0;p<2;p++){if(jump[p]>0)jump[p]-=dt;if(obstacle<.18&&obstacle>-.02&&jump[p]<=0)alive[p]=false;if(obstacle<=0)score[p]++;}if(obstacle<=0)obstacle=1;if(isBot(1)&&alive[1]){bot-=dt;if(bot<=0){jump[1]=.38;bot=.5+rng.nextDouble()*.3;}}if(left<=0||alive.every((v)=>!v))end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

/// Throw visible snowball projectiles; hits require the shot to cross the rival's target.
class SnowballGame extends ArcadeGame {
  SnowballGame({required super.humans});

  final hp = [5, 5];
  final cool = [0.0, 0.0];
  final shots = <_SnowballShot>[];
  double botClock = .8;

  @override
  void paintGame(Canvas c) {
    text(c, 'SNOWBALL FIGHT', Offset(0, -hh + 3));
    for (var p = 0; p < 2; p++) {
      final y = p == 0 ? hh * .38 : -hh * .38;
      c.drawCircle(Offset(0, y), min(hw * .17, hh * .14),
          Paint()..color = playerColors[p]);
      text(c, '${hp[p]} HP', Offset(0, y + hh * .2), size: 3,
          color: playerColors[p]);
    }
    for (final shot in shots) {
      c.drawCircle(Offset(shot.x, shot.y), .8,
          Paint()..color = const Color(0xFFF4FAFF));
    }
    text(c, 'AIM WITH YOUR TAP POSITION', Offset(0, 0), size: 2.4);
  }

  void _throw(int p, double x) {
    if (cool[p] > 0 || hp[p] <= 0) return;
    cool[p] = .55;
    shots.add(_SnowballShot(
      p,
      x.clamp(-hw * .8, hw * .8).toDouble(),
      p == 0 ? hh * .22 : -hh * .22,
      p == 0 ? -28 : 28,
    ));
  }

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (phase == 0) _throw(p, w.x);
  }

  @override
  void tick(double dt) {
    for (var p = 0; p < 2; p++) {
      cool[p] = max(0, cool[p] - dt);
    }
    if (isBot(1) && hp[1] > 0) {
      botClock -= dt;
      if (botClock <= 0) {
        _throw(1, (rng.nextDouble() - .5) * hw * .7);
        botClock = .7 + rng.nextDouble() * .45;
      }
    }

    for (final shot in List<_SnowballShot>.of(shots)) {
      shot.y += shot.vy * dt;
      final targetY = shot.owner == 0 ? -hh * .29 : hh * .29;
      final crossedTarget = shot.owner == 0 ? shot.y <= targetY : shot.y >= targetY;
      if (crossedTarget) {
        if (shot.x.abs() <= hw * .17) {
          hp[1 - shot.owner] = max(0, hp[1 - shot.owner] - 1);
        }
        shots.remove(shot);
      } else if (shot.y < -hh || shot.y > hh) {
        shots.remove(shot);
      }
    }
    if (hp[0] <= 0 || hp[1] <= 0) {
      end(hp[0] == hp[1] ? null : hp[0] > hp[1] ? 0 : 1);
    }
  }
}

class _SnowballShot {
  _SnowballShot(this.owner, this.x, this.y, this.vy);
  final int owner;
  final double x;
  double y;
  final double vy;
}

/// A shared balance beam with momentum, damping and a CPU opponent.
class BallBalanceGame extends ArcadeGame {
  BallBalanceGame({required super.humans});

  double ball = 0;
  double velocity = 0;
  double left = 20;
  double botClock = .5;
  final taps = [0, 0];

  @override
  void paintGame(Canvas c) {
    text(c, 'BALL BALANCE', Offset(0, -hh + 3));
    final tilt = ball * hh * .12;
    rule(c, Offset(-hw * .78, hh * .05 + tilt),
        Offset(hw * .78, hh * .05 - tilt));
    c.drawCircle(
      Offset(ball * hw * .68, hh * .05 - tilt),
      min(hw * .07, hh * .07),
      Paint()..color = const Color(0xFFFFD54F),
    );
    text(c, 'BLUE ${taps[0]}  ·  ORANGE ${taps[1]}',
        Offset(0, hh * .55), size: 2.2);
    text(c, 'TAP LEFT OR RIGHT TO TILT', Offset(0, hh - 4), size: 1.8);
    text(c, '${left.ceil()}s', Offset(0, -hh + 7));
  }

  @override
  void onTouch(int p, Vector2 w, int phase) {
    if (phase != 0) return;
    velocity += (w.x < 0 ? -1 : 1) * (p == 0 ? .55 : -.55);
    taps[p]++;
  }

  @override
  void tick(double dt) {
    left -= dt;
    velocity *= pow(.985, dt * 60).toDouble();
    ball += velocity * dt;
    if (ball.abs() > 1) {
      // The player on the opposite side wins when the ball falls off an edge.
      end(ball < 0 ? 1 : 0);
      return;
    }
    if (isBot(1)) {
      botClock -= dt;
      if (botClock <= 0) {
        velocity -= .2;
        botClock = .3 + rng.nextDouble() * .4;
      }
    }
    if (left <= 0) end(taps[0] == taps[1] ? null : taps[0] > taps[1] ? 0 : 1);
  }
}

/// Move your catcher by dragging; fruit scores and bombs cost a point.
class FruitCatchGame extends ArcadeGame {
  FruitCatchGame({required super.humans});
  final x = [-0.45, 0.45];
  final score = [0, 0];
  final drops = <_FruitDrop>[];
  double spawnClock = .2, left = 25, botClock = 0;
  @override void paintGame(Canvas c) {
    text(c, 'FRUIT CATCH', Offset(0, -hh + 3));
    rule(c, Offset(0, -hh), Offset(0, hh));
    for (var p=0;p<2;p++) {
      final y = p==0 ? hh*.72 : -hh*.72;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x[p]*hw,y), width: hw*.24, height: hh*.08), const Radius.circular(2)), Paint()..color=playerColors[p]);
      text(c, '${score[p]}', Offset(p==0?-hw*.55:hw*.55,y-hh*.13), size:3, color:playerColors[p]);
    }
    for(final d in drops) { c.drawCircle(Offset(d.x*hw,d.y), min(hw*.045,hh*.035), Paint()..color=d.bomb?const Color(0xFFEF5350):const Color(0xFFFFD54F)); text(c,d.bomb?'!':'●',Offset(d.x*hw,d.y),size:1.6,color:const Color(0xFF17232C)); }
    text(c,'DRAG YOUR HALF',Offset(0,0),size:2); text(c,'${left.ceil()}s',Offset(0,hh-3));
  }
  @override void onTouch(int p, Vector2 w, int phase) { if(p<2) x[p]=(w.x/hw).clamp(-.88,.88).toDouble(); }
  @override void tick(double dt) {
    left-=dt; spawnClock-=dt; botClock-=dt;
    if(spawnClock<=0){final lane=rng.nextInt(2); drops.add(_FruitDrop(lane,(rng.nextDouble()*1.65-.825),lane==0?0.0:-0.0,rng.nextDouble()<.22));spawnClock=.42+rng.nextDouble()*.42;}
    if(isBot(1)){final target=drops.where((d)=>d.p==1).toList(); if(target.isNotEmpty)x[1]=target.reduce((a,b)=>(a.y<b.y?a:b)).x; x[1]=x[1].clamp(-.88,.88).toDouble();}
    for(final d in List<_FruitDrop>.of(drops)) { d.y+=(d.p==0?1:-1)*dt*hh*.72; final caught=d.p==0?d.y>hh*.68:d.y< -hh*.68; if(caught){if((d.x-x[d.p]).abs()<.18){if(d.bomb)score[d.p]=max(0,score[d.p]-1);else score[d.p]++;}drops.remove(d);} }
    if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);
  }
}
class _FruitDrop { _FruitDrop(this.p,this.x,this.y,this.bomb); final int p; final double x; double y; final bool bomb; }

/// A real arithmetic quiz: select one of four answers on your half of the screen.
class MathSprintGame extends ArcadeGame {
  MathSprintGame({required super.humans}) { _next(); }
  final score=[0,0]; final answered=[false,false]; int a=3,b=4,answer=7; final options=<int>[]; double left=25,botClock=.7;
  void _next(){a=1+rng.nextInt(12);b=1+rng.nextInt(12);answer=a+b;options..clear()..add(answer);while(options.length<4){final v=max(0,answer+rng.nextInt(13)-6);if(!options.contains(v))options.add(v);}options.shuffle(rng);}
  @override void paintGame(Canvas c){text(c,'MATH SPRINT',Offset(0,-hh+3));text(c,'$a + $b = ?',Offset(0,-hh*.15),size:6);for(int p=0;p<2;p++){final cy=p==0?hh*.36:-hh*.36;for(int i=0;i<4;i++){final pos=Offset((i%2==0?-.5:.5)*hw,cy+(i<2?-1:1)*hh*.12);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:pos,width:hw*.38,height:hh*.17),const Radius.circular(2)),Paint()..color=playerColors[p].withOpacity(.8));text(c,'${options[i]}',pos,size:3,color:const Color(0xFF101820));}text(c,'${score[p]}',Offset(p==0?-hw*.7:hw*.7,cy),size:3); }text(c,'${left.ceil()}s',Offset(0,hh-3));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||answered[p])return;final localY=p==0?w.y-hh*.36:w.y+hh*.36;final row=localY<0?0:1;final col=w.x<0?0:1;final i=row*2+col;if(i>=0&&i<options.length){if(options[i]==answer)score[p]++;else score[p]=max(0,score[p]-1);answered[p]=true;_advanceIfReady();}}
  void _advanceIfReady(){if(answered.every((v)=>v)){answered[0]=false;answered[1]=false;_next();botClock=.7;}}
  @override void tick(double dt){left-=dt;botClock-=dt;if(isBot(1)&&!answered[1]&&botClock<=0){final choice=rng.nextDouble()<.78?answer:options[rng.nextInt(options.length)];if(choice==answer)score[1]++;else score[1]=max(0,score[1]-1);answered[1]=true;_advanceIfReady();}if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

/// Split-screen dodgeball: drag to move; throws travel and can hit the rival.
class DodgeballGame extends ArcadeGame {
  DodgeballGame({required super.humans});
  final x=[-.45,.45], hp=[3,3], cooldown=[0.0,0.0]; final shots=<_DodgeShot>[]; double botClock=.7;
  @override void paintGame(Canvas c){text(c,'DODGEBALL',Offset(0,-hh+3));rule(c,Offset(0,-hh),Offset(0,hh));for(int p=0;p<2;p++){final y=p==0?hh*.58:-hh*.58;c.drawCircle(Offset(x[p]*hw,y),min(hw*.08,hh*.07),Paint()..color=playerColors[p]);text(c,'${hp[p]} HP',Offset(x[p]*hw,y+(p==0?hh*.11:-hh*.11)),size:2);}for(final s in shots)c.drawCircle(Offset(s.x*hw,s.y),min(hw*.035,hh*.025),Paint()..color=const Color(0xFFFFD54F));text(c,'DRAG TO DODGE · AUTO THROW',Offset(0,0),size:2);}
  @override void onTouch(int p,Vector2 w,int phase){if(p<2)x[p]=(w.x/hw).clamp(-.85,.85).toDouble();}
  @override void tick(double dt){for(int p=0;p<2;p++)cooldown[p]=max(0,cooldown[p]-dt);if(isBot(1)){botClock-=dt;if(botClock<=0){x[1]=(rng.nextDouble()*1.5-.75);botClock=.55;} }for(int p=0;p<2;p++){if(cooldown[p]<=0&&hp[p]>0){shots.add(_DodgeShot(p,x[p],p==0?hh*.48:-hh*.48,p==0?-1:1));cooldown[p]=.9;}}for(final s in List<_DodgeShot>.of(shots)){s.y+=s.dir*dt*hh*1.15;final target=1-s.owner;if((s.x-x[target]).abs()<.14&&(s.y-(target==0?hh*.58:-hh*.58)).abs()<hh*.1){hp[target]--;shots.remove(s);if(hp[target]<=0){end(s.owner);return;}}else if(s.y.abs()>hh)shots.remove(s);}}
}
class _DodgeShot{_DodgeShot(this.owner,this.x,this.y,this.dir);final int owner;final double x;double y;final int dir;}

/// Curling-style sliding stones use velocity, friction and target-distance scoring.
class CurlingGame extends ArcadeGame {
  CurlingGame({required super.humans});
  final stones=<_CurlStone>[]; final score=[0,0]; final launched=[0,0]; double left=35,botClock=.8;
  @override void paintGame(Canvas c){text(c,'CURLING',Offset(0,-hh+3));c.drawCircle(Offset(0,0),min(hw*.3,hh*.25),Paint()..color=const Color(0xFF24465A));c.drawCircle(Offset(0,0),min(hw*.19,hh*.15),Paint()..color=const Color(0xFFB8D9E8));c.drawCircle(Offset(0,0),min(hw*.08,hh*.065),Paint()..color=const Color(0xFFEF5350));for(final s in stones)c.drawCircle(Offset(s.x,s.y),min(hw*.055,hh*.045),Paint()..color=playerColors[s.p]);text(c,'TAP YOUR HALF TO SLIDE',Offset(0,hh*.7),size:2);text(c,'${score[0]} - ${score[1]}',Offset(0,hh-3),size:3);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0)return;_launch(p,(w.x/hw).clamp(-.6,.6).toDouble());}
  void _launch(int p,double aim){if(launched[p]>=3)return;launched[p]++;final dir=p==0?-1.0:1.0;stones.add(_CurlStone(p,aim*hw,dir*hh*.72,aim*hw*.45,dir*hh*.65));}
  @override void tick(double dt){left-=dt;botClock-=dt;if(isBot(1)&&launched[1]<3&&botClock<=0){_launch(1,(rng.nextDouble()-.5)*.6);botClock=.8;}for(final s in stones){s.x+=s.vx*dt;s.y+=s.vy*dt;s.vx*=pow(.985,dt*60).toDouble();s.vy*=pow(.985,dt*60).toDouble();if(s.x.abs()>hw*.85){s.x=s.x.sign*hw*.85;s.vx=-s.vx*.45;}if(s.y.abs()>hh*.85){s.y=s.y.sign*hh*.85;s.vy=-s.vy*.45;}}if(left<=0||launched.every((v)=>v>=3)&&stones.every((s)=>s.vx.abs()+s.vy.abs()<.8)){final sums=[0.0,0.0];for(final s in stones){if(s.x.abs()+s.y.abs()<min(hw*.3,hh*.25))sums[s.p]+=1/(1+(Offset(s.x,s.y)).distance);}score[0]=sums[0].round();score[1]=sums[1].round();end(score[0]==score[1]?null:score[0]>score[1]?0:1);}}
}
class _CurlStone{_CurlStone(this.p,this.x,this.y,this.vx,this.vy);final int p;double x,y,vx,vy;}

/// Four-option trivia round with deterministic scoring and a simple CPU answerer.
class TriviaBlitzGame extends ArcadeGame {
  TriviaBlitzGame({required super.humans}){_next();}
  final score=[0,0]; final answered=[false,false]; int q=0; double left=30,botClock=.8; final questions=<List<Object>>[
    ['How many sides has a hexagon?',6,[4,5,6,8]],['Which planet is known as the Red Planet?',1,['Venus','Mars','Jupiter','Mercury']],['How many minutes are in an hour?',2,[30,45,60,90]],['What is H2O commonly called?',1,['Salt','Water','Oxygen','Hydrogen']],['Which animal is a mammal?',0,['Dolphin','Trout','Frog','Ant']]
  ];
  List<Object> current=[]; void _next(){current=questions[q%questions.length];q++;}
  @override void paintGame(Canvas c){text(c,'TRIVIA BLITZ',Offset(0,-hh+3));text(c,current[0] as String,Offset(0,-hh*.04),size:2.7);final opts=current[2] as List;for(int p=0;p<2;p++){final cy=p==0?hh*.38:-hh*.38;for(int i=0;i<4;i++){final at=Offset((i%2==0?-.5:.5)*hw,cy+(i<2?-1:1)*hh*.12);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:at,width:hw*.42,height:hh*.16),const Radius.circular(2)),Paint()..color=playerColors[p].withOpacity(.85));text(c,'${opts[i]}',at,size:2.4,color:const Color(0xFF101820));}}text(c,'${score[0]} - ${score[1]}',Offset(0,0),size:3);text(c,'${left.ceil()}s',Offset(0,hh-3));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0||answered[p])return;final localY=p==0?w.y-hh*.38:w.y+hh*.38;final row=localY<0?0:1,col=w.x<0?0:1;final i=row*2+col;if(i==(current[1] as int))score[p]++;else score[p]=max(0,score[p]-1);answered[p]=true;_advanceIfReady();}
  void _advanceIfReady(){if(answered.every((v)=>v)){answered[0]=false;answered[1]=false;_next();botClock=.8;}}
  @override void tick(double dt){left-=dt;botClock-=dt;if(isBot(1)&&!answered[1]&&botClock<=0){final correct=current[1] as int;final choice=rng.nextDouble()<.65?correct:rng.nextInt(4);if(choice==correct)score[1]++;else score[1]=max(0,score[1]-1);answered[1]=true;_advanceIfReady();}if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

/// Tap the lit tile's position before the target changes; CPU plays on its own timer.
class SimonSequenceGame extends ArcadeGame {
  SimonSequenceGame({required super.humans});
  int active=0; final score=[0,0]; double change=.8,left=25,botClock=.45;
  @override void paintGame(Canvas c){text(c,'SIMON TILES',Offset(0,-hh+3));for(int p=0;p<2;p++){for(int i=0;i<4;i++){final tileY=p==0?(i<2?hh*.18:hh*.4):(i<2?-hh*.4:-hh*.18);final pos=Offset((i%2==0?-.5:.5)*hw,tileY);final on=i==active; c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:pos,width:hw*.38,height:hh*.16),const Radius.circular(2)),Paint()..color=on?const Color(0xFF66BB6A):const Color(0xFF304453));}text(c,'${score[p]}',Offset(p==0?-hw*.7:hw*.7,p==0?hh*.35:-hh*.35),size:3);}text(c,'TAP THE LIT TILE',Offset(0,0),size:2);text(c,'${left.ceil()}s',Offset(0,hh-3));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0)return;final localY=p==0?w.y-hh*.29:w.y+hh*.29;final row=localY<0?0:1;final col=w.x<0?0:1;final i=row*2+col;if(i==active)score[p]++;else score[p]=max(0,score[p]-1);active=rng.nextInt(4);change=.7;}
  @override void tick(double dt){left-=dt;change-=dt;botClock-=dt;if(change<=0){active=rng.nextInt(4);change=.7+rng.nextDouble()*.5;}if(isBot(1)&&botClock<=0){if(rng.nextDouble()<.72)score[1]++;botClock=.45+rng.nextDouble()*.45;}if(left<=0)end(score[0]==score[1]?null:score[0]>score[1]?0:1);}
}

/// A small maze race: each tap moves one step toward the goal; walls block movement.
class MazeEscapeGame extends ArcadeGame {
  MazeEscapeGame({required super.humans});
  final pos=[12,0]; final steps=[0,0]; final goal=15; final walls=<int>{2,6,10}; double botClock=.3;
  @override void paintGame(Canvas c){text(c,'MAZE ESCAPE',Offset(0,-hh+3));final s=min(hw*.78,hh*.72)/4;final ox=-2*s,oy=-2*s;for(int i=0;i<16;i++){final r=i~/4,col=i%4,center=Offset(ox+(col+.5)*s,oy+(r+.5)*s);c.drawRect(Rect.fromCenter(center:center,width:s*.92,height:s*.92),Paint()..color=walls.contains(i)?const Color(0xFF43505B):const Color(0xFF1D3442));if(i==goal)text(c,'★',center,size:s*.45,color:const Color(0xFFFFD54F));for(int p=0;p<2;p++)if(pos[p]==i)text(c,p==0?'B':'O',center,size:s*.4,color:playerColors[p]);}text(c,'TAP LEFT EDGE, RIGHT EDGE OR CENTER TO MOVE',Offset(0,hh-3),size:1.8);}
  @override void onTouch(int p,Vector2 w,int phase){if(phase!=0)return;final dir=w.x< -hw*.4?0:w.x>hw*.4?1:w.x<0?2:3;_move(p,dir);}
  void _move(int p,int dir){final cur=pos[p],row=cur~/4,col=cur%4;var next=cur;if(dir==0&&col>0)next=cur-1;if(dir==1&&col<3)next=cur+1;if(dir==2&&row>0)next=cur-4;if(dir==3&&row<3)next=cur+4;if(!walls.contains(next)){pos[p]=next;steps[p]++;}if(pos[p]==goal)end(p);}
  @override void tick(double dt){if(isBot(1)){botClock-=dt;if(botClock<=0){final cur=pos[1],row=cur~/4,col=cur%4;final candidates=[if(col<3)cur+1,if(col>0)cur-1,if(row<3)cur+4,if(row>0)cur-4].where((v)=>!walls.contains(v)).toList();if(candidates.isNotEmpty){candidates.sort((a,b)=>(goal-a).abs().compareTo((goal-b).abs()));pos[1]=candidates.first;}botClock=.45;if(pos[1]==goal)end(1);}}}
}

/// Paddle-and-ball breakout: drag your paddle, break bricks with real ball movement.
class BrickBreakerGame extends ArcadeGame {
  BrickBreakerGame({required super.humans});
  double paddle=0,bx=0,by=0,vx=3.4,vy=4.2; int bricks=0,lives=3; final removed=<int>{};
  @override void paintGame(Canvas c){text(c,'BRICK BREAKER',Offset(0,-hh+3));for(int i=0;i<24;i++){if(removed.contains(i))continue;final x=-hw*.82+(i%6)*hw*.32,y=-hh*.63+(i~/6)*hh*.11;c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(x,y),width:hw*.27,height:hh*.075),const Radius.circular(.6)),Paint()..color=playerColors[i%4]);}c.drawCircle(Offset(bx,by),min(hw*.035,hh*.025),Paint()..color=const Color(0xFFFFD54F));c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(paddle,hh*.72),width:hw*.3,height:hh*.055),const Radius.circular(1)),Paint()..color=playerColors[0]);text(c,'LIVES $lives',Offset(0,hh-3),size:2.5);}
  @override void onTouch(int p,Vector2 w,int phase){paddle=w.x.clamp(-hw*.82,hw*.82).toDouble();}
  @override void tick(double dt){bx+=vx*dt;by+=vy*dt;if(bx.abs()>hw*.92){bx=bx.sign*hw*.92;vx=-vx;}if(vy<0&&by> -hh*.72&&by< -hh*.2){final col=((bx/hw+.82)/.32).round().clamp(0,5).toInt(),row=((by/hh+.63)/.11).round().clamp(0,3).toInt();final idx=row*6+col;final brickX=-hw*.82+col*hw*.32,brickY=-hh*.63+row*hh*.11;if(!removed.contains(idx)&&(bx-brickX).abs()<hw*.15&&(by-brickY).abs()<hh*.06){removed.add(idx);bricks++;vy=vy.abs();}}if(vy>0&&by>hh*.65&&by<hh*.78&&(bx-paddle).abs()<hw*.19){vy=-vy.abs();vx+=(bx-paddle)*.5;}if(by>hh){lives--;bx=0;by=0;vy=-4.2;if(lives<=0){end(1);return;}}if(removed.length>=24)end(0);}
}

/// A lane-based hop game. Tap to jump; collision and progress are state-driven.
class PlatformHopperGame extends ArcadeGame {
  PlatformHopperGame({required super.humans});
  final progress=[0.0,0.0], y=[0.0,0.0], vy=[0.0,0.0], hits=[0,0],nextObstacle=[0,0]; final obstacles=[.22,.43,.66,.84]; double left=25,botClock=.6;
  @override void paintGame(Canvas c){text(c,'PLATFORM HOPPER',Offset(0,-hh+3));for(int p=0;p<2;p++){final base=p==0?hh*.48:-hh*.48;for(int i=0;i<5;i++){final px=-hw*.72+i*hw*.36;final py=base-(i%2)*hh*.12;c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(px,py),width:hw*.25,height:hh*.045),const Radius.circular(1)),Paint()..color=const Color(0xFF435B69));}for(final obstacle in obstacles){final ox=-hw*.75+obstacle*hw*1.5;c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(ox,base-hh*.07),width:hw*.055,height:hh*.14),const Radius.circular(.8)),Paint()..color=const Color(0xFFE57373));}final px=-hw*.75+progress[p]*hw*1.5;c.drawCircle(Offset(px,base-y[p]),min(hw*.06,hh*.045),Paint()..color=playerColors[p]);text(c,'${(progress[p]*100).round()}%',Offset(p==0?-hw*.65:hw*.65,base+hh*.12),size:2);}text(c,'TAP TO JUMP',Offset(0,0),size:2);text(c,'${left.ceil()}s',Offset(0,hh-3));}
  @override void onTouch(int p,Vector2 w,int phase){if(phase==0&&y[p]<=0)vy[p]=hh*.8;}
  @override void tick(double dt){left-=dt;for(int p=0;p<2;p++){final old=progress[p];y[p]+=vy[p]*dt;vy[p]-=hh*2.1*dt;if(y[p]<=0){y[p]=0;vy[p]=0;progress[p]=min(1,progress[p]+dt*.07);}if(nextObstacle[p]<obstacles.length&&old<obstacles[nextObstacle[p]]&&progress[p]>=obstacles[nextObstacle[p]]){if(y[p]<hh*.08){progress[p]=max(0,progress[p]-.08);hits[p]++;}nextObstacle[p]++;}}if(isBot(1)){botClock-=dt;if(botClock<=0){vy[1]=hh*.8;botClock=.65;}}if(progress[0]>=1||progress[1]>=1)end(progress[0]==progress[1]?null:progress[0]>progress[1]?0:1);if(left<=0)end(progress[0]==progress[1]?null:progress[0]>progress[1]?0:1);}
}
