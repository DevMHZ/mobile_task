import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

/// Paint feedback above images, where a Material ink splash would be hidden.
/// The overlay ignores input so nested actions such as Save remain independent.
class InteractiveSurface extends StatefulWidget {
  const InteractiveSurface({
    required this.onTap,
    required this.child,
    this.color = Colors.white,
    this.radius = AppSpace.radius,
    super.key,
  });
  final VoidCallback onTap;
  final Widget child;
  final Color color;
  final double radius;
  @override
  State<InteractiveSurface> createState() => _InteractiveSurfaceState();
}

class _InteractiveSurfaceState extends State<InteractiveSurface> {
  final _states = WidgetStatesController();
  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    color: widget.color,
    borderRadius: BorderRadius.circular(widget.radius),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: widget.onTap,
      statesController: _states,
      mouseCursor: SystemMouseCursors.click,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<Set<WidgetState>>(
                valueListenable: _states,
                builder: (_, states, _) => AnimatedContainer(
                  key: const ValueKey('surface_feedback'),
                  duration: AppConfig.motion,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(
                      alpha: states.contains(WidgetState.pressed)
                          ? InteractionTokens.surfacePressedOpacity
                          : states.contains(WidgetState.hovered)
                          ? InteractionTokens.surfaceHoverOpacity
                          : 0,
                    ),
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(
                      color: states.contains(WidgetState.focused)
                          ? AppColors.blue
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
