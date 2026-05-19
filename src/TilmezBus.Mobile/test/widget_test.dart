import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_bus/app.dart';

void main() {
  testWidgets('App boots without throwing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SmartBusApp()),
    );
    await tester.pump();
    expect(find.byType(SmartBusApp), findsOneWidget);
  });
}
