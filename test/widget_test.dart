import 'package:flutter_test/flutter_test.dart';
import 'package:itr_proj/main.dart';
import 'package:itr_proj/splashscreen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(Spshsc), findsOneWidget);
  });
}
