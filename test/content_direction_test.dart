import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_task/core/localization/content_direction.dart';

void main() {
  test(
    'content keeps its writing direction independently of the UI locale',
    () {
      expect(
        contentDirection('English description.', TextDirection.rtl),
        TextDirection.ltr,
      );
      expect(contentDirection('123 USD', TextDirection.rtl), TextDirection.ltr);
      expect(
        contentDirection('https://example.com/image.png', TextDirection.rtl),
        TextDirection.ltr,
      );
      expect(
        contentDirection('\u0648\u0635\u0641 Flutter', TextDirection.ltr),
        TextDirection.rtl,
      );
      expect(contentDirection('  ', TextDirection.rtl), TextDirection.rtl);
    },
  );
}
