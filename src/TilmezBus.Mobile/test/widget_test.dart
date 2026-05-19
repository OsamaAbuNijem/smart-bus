import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tilmez_bus/app.dart';

void main() {
  testWidgets('App boots without throwing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TilmezBusApp()),
    );
    await tester.pump();
    expect(find.byType(TilmezBusApp), findsOneWidget);
  });
}
