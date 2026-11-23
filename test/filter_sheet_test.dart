import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_task/features/catalog/presentation/ui/filter_sheet.dart';

void main() {
  testWidgets(
    'range labels stay inside a narrow RTL sheet when thumbs are close',
    (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: 280,
                child: ModernRangeSliderWithLabels(
                  values: const RangeValues(102, 327),
                  min: 0,
                  max: 2000,
                  formatLabel: (value) => '\$${value.round()}',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final label = find.textContaining('327');
      expect(label, findsOneWidget);
      final rect = tester.getRect(label);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(280));
    },
  );

  testWidgets('range labels stay inside a narrow LTR sheet at the edges', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: ModernRangeSliderWithLabels(
              values: const RangeValues(0, 2000),
              min: 0,
              max: 2000,
              formatLabel: (value) => '\$${value.round()}',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final text in [r'$0', r'$2000']) {
      final rect = tester.getRect(find.text(text));
      expect(rect.left, greaterThanOrEqualTo(0), reason: text);
      expect(rect.right, lessThanOrEqualTo(280), reason: text);
    }
  });
}
