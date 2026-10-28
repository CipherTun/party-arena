import 'package:flutter_test/flutter_test.dart';
import 'package:party_arena/main.dart';

void main() {
  testWidgets('Party Arena app launches', (tester) async {
    await tester.pumpWidget(const PartyApp());
    expect(find.text('Party Arena'), findsWidgets);
  });
}
