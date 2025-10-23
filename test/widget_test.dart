import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/features/home/screens/home_screen.dart';

void main() {
  testWidgets('앱이 정상적으로 렌더링된다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
