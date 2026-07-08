import 'package:flutter_test/flutter_test.dart';
import 'package:loop_fx_journal/app.dart';

void main() {
  testWidgets('LoopApp builds', (tester) async {
    await tester.pumpWidget(LoopApp());
    expect(find.byType(LoopApp), findsOneWidget);
  });
}
