import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Network image shimmers can animate while the interface is already usable.
// Advance the route transition; callers wait for the specific resulting UI.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  final clock = Stopwatch()..start();
  const timeout = Duration(seconds: 40);
  while (finder.evaluate().isEmpty && clock.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
  await settle(tester);
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(tester);
  if (finder.evaluate().isEmpty) {
    final scrollable = find
        .descendant(
          of: find
              .byWidgetPredicate((w) => w is ListView || w is CustomScrollView)
              .hitTestable()
              .last,
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
  await settle(tester);
}

Future<void> waitUntilGone(WidgetTester tester, Finder finder) async {
  final clock = Stopwatch()..start();
  const timeout = Duration(seconds: 40);
  while (finder.evaluate().isNotEmpty && clock.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsNothing);
  await settle(tester);
}
