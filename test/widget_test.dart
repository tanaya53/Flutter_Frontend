import 'package:flutter_test/flutter_test.dart';
import 'package:mazi_shala/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaziShalaApp());
    expect(find.byType(MaziShalaApp), findsOneWidget);
  });
}
