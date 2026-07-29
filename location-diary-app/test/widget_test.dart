import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:location_diary_app/main.dart';

void main() {
  testWidgets('App launches and shows the bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LocationDiaryApp()));
    await tester.pump();

    expect(find.text('今日の記録'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('日記一覧'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
