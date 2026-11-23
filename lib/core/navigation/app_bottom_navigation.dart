import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../localization/context_l10n.dart';
import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          _item(
            context,
            0,
            context.l10n.discover,
            Icons.home_outlined,
            Icons.home_rounded,
          ),
          _item(
            context,
            1,
            context.l10n.exploreTab,
            Icons.search_rounded,
            Icons.search_rounded,
          ),
          _item(
            context,
            2,
            context.l10n.settings,
            Icons.person_outline_rounded,
            Icons.person_rounded,
          ),
        ],
      ),
    ),
  );
  Widget _item(
    BuildContext context,
    int index,
    String label,
    IconData icon,
    IconData activeIcon,
  ) => Expanded(
    child: _Destination(
      index: index,
      label: label,
      icon: currentIndex == index ? activeIcon : icon,
      selected: currentIndex == index,
      onTap: () => onTap(index),
    ),
  );
}

class _Destination extends StatefulWidget {
  const _Destination({
    required this.index,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<_Destination> createState() => _DestinationState();
}

class _DestinationState extends State<_Destination> {
  final _states = WidgetStatesController();
  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    selected: widget.selected,
    label:
        '${widget.label}, ${MaterialLocalizations.of(context).tabLabel(tabIndex: widget.index + 1, tabCount: 3)}',
    onTap: widget.onTap,
    child: ExcludeSemantics(
      child: InkWell(
        key: ValueKey('nav_${widget.index}'),
        onTap: widget.onTap,
        statesController: _states,
        mouseCursor: SystemMouseCursors.click,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<Set<WidgetState>>(
                valueListenable: _states,
                builder: (_, states, _) => AnimatedContainer(
                  key: ValueKey('nav_feedback_${widget.index}'),
                  duration: AppConfig.motion,
                  width: DesignMetrics.minimumTapTarget,
                  height: AppSpace.xxl,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(
                      alpha: states.contains(WidgetState.pressed)
                          ? InteractionTokens.navigationPressedOpacity
                          : states.contains(WidgetState.hovered)
                          ? InteractionTokens.navigationHoverOpacity
                          : 0,
                    ),
                    borderRadius: BorderRadius.circular(AppSpace.lg),
                    border: Border.all(
                      color: states.contains(WidgetState.focused)
                          ? AppColors.blue
                          : Colors.transparent,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: AppConfig.motion,
                    child: Icon(
                      widget.icon,
                      key: ValueKey((widget.selected, widget.icon)),
                      color: widget.selected ? AppColors.blue : AppColors.muted,
                      size: InteractionTokens.navigationIconSize,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              AnimatedDefaultTextStyle(
                duration: AppConfig.motion,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: widget.selected ? AppColors.blue : AppColors.muted,
                  fontSize: InteractionTokens.navigationLabelSize,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                child: Text(widget.label, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
