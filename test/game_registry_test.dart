import 'package:flutter_test/flutter_test.dart';
import 'package:party_arena/main.dart';

void main() {
  test('every registered game has a unique name and a working constructor', () {
    expect(games, hasLength(32));
    expect(games.map((game) => game.name).toSet(), hasLength(games.length));

    final categories = {'Sports & Physics', 'Racing & Action', 'Quick Play', 'Strategy & Puzzle', 'Brain & Trivia'};
    for (final game in games) {
      expect(game.name.trim(), isNotEmpty);
      expect(categories, contains(game.category), reason: game.name);
      expect(game.maxPlayers, inInclusiveRange(2, 4));
      expect(() => game.build(1), returnsNormally, reason: game.name);
    }
  });
}
