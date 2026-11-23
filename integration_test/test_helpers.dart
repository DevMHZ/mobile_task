import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  final clock = Stopwatch()..start();
  const timeout = Duration(seconds: 40);
  while (finder.evaluate().isEmpty && clock.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  if (finder.evaluate().isEmpty) {
    final scrollable = find
        .descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      finder,
      250,
      maxScrolls: 30,
      scrollable: scrollable,
    );
  } else {
    await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  }
  await tester.pumpAndSettle();
}
