import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/catalog_query.dart';
import '../cubit/catalog_cubit.dart';
import 'widgets/price_histogram.dart';

/// Pixel-perfect redesign of the Filter bottom sheet matching the Figma specifications.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _ceiling;
  late double _minPrice;
  late double _maxPrice;
  late Set<String> _propertyTypes;
  late int _bedrooms;
  late int _bathrooms;
  late double _minBuildingSize;
  late double _maxBuildingSize;
  late CatalogSort _sort;
  String? _category;

  static const double _defaultMinSize = 500;
  static const double _defaultMaxSize = 4000;

  @override
  void initState() {
    super.initState();
    final state = context.read<CatalogCubit>().state;
    final query = state.query;

    _ceiling = state.products
        .fold<double>(0, (value, p) => math.max(value, p.price))
        .ceilToDouble();
    if (_ceiling <= 0) _ceiling = 1000;

    _minPrice = (query.minPrice ?? 102).clamp(0.0, _ceiling);
    _maxPrice = (query.maxPrice ?? math.min(327.0, _ceiling)).clamp(
      0.0,
      _ceiling,
    );
    if (_minPrice > _maxPrice) _minPrice = 0;

    _propertyTypes = query.propertyTypes.isNotEmpty
        ? Set<String>.from(query.propertyTypes)
        : {'Apartments', 'Townhomes'};

    _bedrooms = query.bedrooms ?? 2;
    _bathrooms = query.bathrooms ?? 1;

    _minBuildingSize = (query.minBuildingSize ?? 1370).clamp(
      _defaultMinSize,
      _defaultMaxSize,
    );
    _maxBuildingSize = (query.maxBuildingSize ?? 2720).clamp(
      _defaultMinSize,
      _defaultMaxSize,
    );
    if (_minBuildingSize > _maxBuildingSize) {
      _minBuildingSize = _defaultMinSize;
      _maxBuildingSize = _defaultMaxSize;
    }

    _sort = query.sort;
    _category = query.category;
  }

  void _reset() {
    setState(() {
      _minPrice = 0;
      _maxPrice = _ceiling;
      _propertyTypes.clear();
      _bedrooms = 0;
      _bathrooms = 0;
      _minBuildingSize = _defaultMinSize;
      _maxBuildingSize = _defaultMaxSize;
      _sort = CatalogSort.recommended;
      _category = null;
    });
  }

  void _apply() {
    final catalog = context.read<CatalogCubit>();
    catalog.setQuery(
      CatalogQuery(
        text: catalog.state.query.text,
        category: _category,
        propertyTypes: _propertyTypes,
        minPrice: _minPrice > 0 ? _minPrice : null,
        maxPrice: _maxPrice < _ceiling ? _maxPrice : null,
        bedrooms: _bedrooms > 0 ? _bedrooms : null,
        bathrooms: _bathrooms > 0 ? _bathrooms : null,
        minBuildingSize: _minBuildingSize > _defaultMinSize
            ? _minBuildingSize
            : null,
        maxBuildingSize: _maxBuildingSize < _defaultMaxSize
            ? _maxBuildingSize
            : null,
        sort: _sort,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final catalog = context.read<CatalogCubit>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Header: Back Button, Filter Title, Reset Action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.page,
                vertical: AppSpace.xs,
              ),
              child: Row(
                children: [
                  Material(
                    color: const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        // arrow_back_rounded has matchTextDirection, so
                        // it flips to point right in RTL automatically.
                        // Choosing arrow_forward manually in RTL would
                        // double-flip it back to the left.
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l.filter,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l.reset),
                  ),
                ],
              ),
            ),

            // Main Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.page,
                  AppSpace.sm,
                  AppSpace.page,
                  AppSpace.page,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. Price Range ---
                    Text(
                      l.priceRange,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    if (_ceiling > 0) ...[
                      SizedBox(
                        height: 60,
                        child: PriceHistogram(
                          prices: catalog.state.products
                              .map((p) => p.price)
                              .toList(),
                          maximum: _ceiling,
                          selectedMin: _minPrice,
                          selectedMax: _maxPrice,
                        ),
                      ),
                      ModernRangeSliderWithLabels(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: _ceiling,
                        formatLabel: (val) => '\$${val.round()}',
                        onChanged: (vals) => setState(() {
                          _minPrice = vals.start;
                          _maxPrice = vals.end;
                        }),
                      ),
                    ],

                    const SizedBox(height: AppSpace.xl),

                    // --- 2. Property Type ---
                    Text(
                      l.propertyType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _propertyTypePill('Apartments', l.apartments),
                        _propertyTypePill('Townhomes', l.townhomes),
                        _propertyTypePill('Homes', l.homes),
                        _propertyTypePill('Condos', l.condos),
                        _propertyTypePill('Duplexes', l.duplexes),
                        _propertyTypePill('Studios', l.studios),
                      ],
                    ),

                    const SizedBox(height: AppSpace.xxl),

                    // --- 3. Home Details ---
                    Text(
                      l.homeDetails,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _StepperRow(
                      label: l.bedrooms,
                      value: _bedrooms,
                      minValue: 0,
                      displayValue: _bedrooms == 0 ? '-' : '$_bedrooms',
                      onDecrement: () => setState(() {
                        if (_bedrooms > 0) _bedrooms--;
                      }),
                      onIncrement: () => setState(() {
                        if (_bedrooms < 10) _bedrooms++;
                      }),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _StepperRow(
                      label: l.bathrooms,
                      value: _bathrooms,
                      minValue: 0,
                      displayValue: _bathrooms == 0 ? '-' : '$_bathrooms',
                      onDecrement: () => setState(() {
                        if (_bathrooms > 0) _bathrooms--;
                      }),
                      onIncrement: () => setState(() {
                        if (_bathrooms < 8) _bathrooms++;
                      }),
                    ),

                    const SizedBox(height: AppSpace.xl),

                    // --- 4. Building Size ---
                    Text(
                      l.buildingSize,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    ModernRangeSliderWithLabels(
                      values: RangeValues(_minBuildingSize, _maxBuildingSize),
                      min: _defaultMinSize,
                      max: _defaultMaxSize,
                      formatLabel: (val) => '${val.round()}',
                      onChanged: (vals) => setState(() {
                        _minBuildingSize = vals.start;
                        _maxBuildingSize = vals.end;
                      }),
                    ),

                    const SizedBox(height: AppSpace.lg),
                  ],
                ),
              ),
            ),

            // Bottom Action Button: Set Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.page,
                AppSpace.sm,
                AppSpace.page,
                AppSpace.page,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l.setFilter),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyTypePill(String key, String title) {
    final isSelected = _propertyTypes.contains(key);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _propertyTypes.remove(key);
          } else {
            _propertyTypes.add(key);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF334155),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// A modern dual-thumb RangeSlider with blue labels positioned under the thumbs.
class ModernRangeSliderWithLabels extends StatelessWidget {
  const ModernRangeSliderWithLabels({
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.formatLabel,
    this.divisions,
    super.key,
  });

  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final String Function(double) formatLabel;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const horizontalPadding = 24.0;
        final trackWidth = math.max(0.0, width - horizontalPadding * 2);

        final range = max - min;
        final startPercent = range > 0
            ? ((values.start - min) / range).clamp(0.0, 1.0)
            : 0.0;
        final endPercent = range > 0
            ? ((values.end - min) / range).clamp(0.0, 1.0)
            : 1.0;

        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final visualStartPercent = isRtl ? (1.0 - startPercent) : startPercent;
        final visualEndPercent = isRtl ? (1.0 - endPercent) : endPercent;

        final leftPercent = math.min(visualStartPercent, visualEndPercent);
        final rightPercent = math.max(visualStartPercent, visualEndPercent);

        final leftX = horizontalPadding + trackWidth * leftPercent;
        final rightX = horizontalPadding + trackWidth * rightPercent;

        final isTooClose = (rightX - leftX).abs() < 60;

        // Keep every label fully inside the track width. Without the upper
        // clamp a label centred near an edge (common in RTL, where the
        // minimum thumb sits at the right) is clipped by the sheet.
        double labelLeft(double centre, double labelWidth) =>
            (centre - labelWidth / 2)
                .clamp(0.0, math.max(0.0, width - labelWidth))
                .toDouble();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.5,
                activeTrackColor: AppColors.blue,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                rangeThumbShape: const ModernRingThumbShape(
                  thumbRadius: 10.5,
                  borderWidth: 3.5,
                ),
                overlayColor: AppColors.blue.withValues(alpha: 0.12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              ),
              child: RangeSlider(
                values: values,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              height: 22,
              width: width,
              child: Stack(
                children: [
                  if (isTooClose)
                    Positioned(
                      left: labelLeft((leftX + rightX) / 2, 110),
                      width: 110,
                      child: Text(
                        // Isolate the Latin range so its order stays
                        // readable inside an RTL paragraph.
                        '\u2066${formatLabel(values.start)} - ${formatLabel(values.end)}\u2069',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else ...[
                    Positioned(
                      left: labelLeft(leftX, 70),
                      width: 70,
                      child: Text(
                        formatLabel(isRtl ? values.end : values.start),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Positioned(
                      left: labelLeft(rightX, 70),
                      width: 70,
                      child: Text(
                        formatLabel(isRtl ? values.start : values.end),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom RangeSlider thumb shape with white fill, vibrant blue ring border and drop shadow.
class ModernRingThumbShape extends RangeSliderThumbShape {
  const ModernRingThumbShape({
    this.thumbRadius = 10.5,
    this.borderWidth = 3.5,
    this.borderColor = AppColors.blue,
    this.fillColor = Colors.white,
  });

  final double thumbRadius;
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final canvas = context.canvas;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(center.translate(0, 1.2), thumbRadius, shadowPaint);

    // White body
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, fillPaint);

    // Blue ring border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, thumbRadius - borderWidth / 2, borderPaint);
  }
}

/// Counter stepper row for Home Details (Bedrooms & Bathrooms).
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.minValue = 0,
    this.displayValue,
  });

  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int minValue;
  final String? displayValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepperButton(
                icon: Icons.remove,
                onPressed: value > minValue ? onDecrement : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  displayValue ?? value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _stepperButton(icon: Icons.add, onPressed: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onPressed}) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? AppColors.blue : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
