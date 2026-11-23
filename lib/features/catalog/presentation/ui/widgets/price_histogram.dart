import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Distribution of the loaded catalogue's real prices, styled like the Figma design.
class PriceHistogram extends StatelessWidget {
  const PriceHistogram({
    required this.prices,
    required this.maximum,
    this.selectedMin,
    this.selectedMax,
    super.key,
  });

  final List<double> prices;
  final double maximum;
  final double? selectedMin;
  final double? selectedMax;

  @override
  Widget build(BuildContext context) {
    const binCount = 28;
    final bins = List.filled(binCount, 0);
    final maxVal = maximum > 0 ? maximum : 1.0;

    for (final price in prices) {
      final idx = (price / maxVal * binCount).floor().clamp(0, binCount - 1);
      bins[idx]++;
    }

    final peak = bins.fold<int>(1, (a, b) => a > b ? a : b);

    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bins.length; i++) ...[
            Expanded(
              child: Builder(
                builder: (context) {
                  final count = bins[i];
                  final heightFactor = count == 0
                      ? 0.08
                      : math.max(0.12, count / peak);

                  final binStart = (i / binCount) * maxVal;
                  final binEnd = ((i + 1) / binCount) * maxVal;
                  final isInRange = (selectedMin == null || binEnd >= selectedMin!) &&
                      (selectedMax == null || binStart <= selectedMax!);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: FractionallySizedBox(
                      heightFactor: heightFactor,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isInRange
                              ? const Color(0xFFC7D9F8)
                              : const Color(0xFFE8EEF5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
