// Smoke test: the splash screen must render with no network dependency.
// (We pump SplashScreen directly rather than MyApp because AppRoot mounts
// the store WebView from frame one, and the WebView platform implementation
// does not exist in the test environment.)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beautyontapp/splash_screen.dart';

void main() {
  testWidgets('Splash screen boots and animates', (WidgetTester tester) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(home: SplashScreen(onFinished: () => finished = true)),
    );
    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the tagline typing animation run a few frames.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.textContaining('BEAUT'), findsOneWidget);
    expect(finished, isFalse);

    // Tear down before the splash hands over, then flush any pending
    // splash timers so none leak from the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 7));
  });
}
