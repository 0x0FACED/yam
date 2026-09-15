import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/app.dart';
import 'package:yam/app/theme/app_motion.dart';

void main() {
  testWidgets('startup animation reveals app content', (tester) async {
    await tester.pumpWidget(const YamApp());

    expect(find.byKey(const ValueKey('startup-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-content')), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppMotion.logoIntro);
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-screen')), findsNothing);
    expect(find.byKey(const ValueKey('app-content')), findsOneWidget);
  });
}
