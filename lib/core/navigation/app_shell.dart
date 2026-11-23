import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/catalog/presentation/ui/catalog_screen.dart';
import '../../features/catalog/presentation/ui/filter_sheet.dart';
import '../../features/settings/presentation/cubit/preferences_cubit.dart';
import '../../features/settings/presentation/ui/settings_screen.dart';
import '../config/app_config.dart';
import 'app_bottom_navigation.dart';
import '../localization/context_l10n.dart';
import '../theme/app_theme.dart';
import '../widgets/app_feedback.dart';

enum AppTab { home, explore, profile }

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selected = AppTab.home;
  final _navigators = {
    for (final tab in AppTab.values) tab: GlobalKey<NavigatorState>(),
  };
  final _messengers = {
    for (final tab in AppTab.values) tab: GlobalKey<ScaffoldMessengerState>(),
  };
  final _scroll = {for (final tab in AppTab.values) tab: ScrollController()};
  final _searchFocus = FocusNode();
  final _canHandleBack = {for (final tab in AppTab.values) tab: false};

  @override
  void dispose() {
    for (final controller in _scroll.values) {
      controller.dispose();
    }
    _searchFocus.dispose();
    super.dispose();
  }

  void _select(AppTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    _messengers[_selected]?.currentState?.hideCurrentSnackBar();
    if (tab == _selected) {
      final navigator = _navigators[tab]!.currentState!;
      if (navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
      } else if (_scroll[tab]!.hasClients) {
        _scroll[tab]!.animateTo(
          0,
          duration: AppConfig.motion,
          curve: Curves.easeOut,
        );
      }
      return;
    }
    setState(() => _selected = tab);
  }

  void _openExplore({bool focusSearch = false, bool filters = false}) {
    _select(AppTab.explore);
    _navigators[AppTab.explore]!.currentState!.popUntil(
      (route) => route.isFirst,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selected != AppTab.explore) return;
      if (focusSearch) {
        if (_scroll[AppTab.explore]!.hasClients) {
          _scroll[AppTab.explore]!.jumpTo(0);
        }
        _searchFocus.requestFocus();
      }
      if (filters) {
        showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const FilterSheet(),
        );
      }
    });
  }

  Widget _root(AppTab tab) => switch (tab) {
    AppTab.home => CatalogScreen(
      key: const ValueKey('home'),
      scrollController: _scroll[tab],
      onExplore: _openExplore,
      onSearch: () => _openExplore(focusSearch: true),
      onFilters: () => _openExplore(filters: true),
      onProfile: () => _select(AppTab.profile),
    ),
    AppTab.explore => CatalogScreen(
      key: const ValueKey('explore'),
      explore: true,
      scrollController: _scroll[tab],
      searchFocus: _searchFocus,
    ),
    AppTab.profile => SettingsScreen(
      onExplore: _openExplore,
      scrollController: _scroll[tab],
    ),
  };

  Widget _branch(AppTab tab) => TickerMode(
    enabled: tab == _selected,
    child: NavigatorPopHandler<Object?>(
      enabled: tab == _selected,
      onPopWithResult: (result) {
        final navigator = _navigators[tab]!.currentState!;
        if (tab == _selected && navigator.canPop()) {
          navigator.pop(result);
        }
      },
      child: NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          if (_canHandleBack[tab] != notification.canHandlePop) {
            setState(() => _canHandleBack[tab] = notification.canHandlePop);
          }
          return false;
        },
        child: ScaffoldMessenger(
          key: _messengers[tab],
          child: Navigator(
            key: _navigators[tab],
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              settings: RouteSettings(name: '/${tab.name}'),
              builder: (_) =>
                  Scaffold(body: SafeArea(bottom: false, child: _root(tab))),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final branchHandledBack = _canHandleBack[_selected]!;
    return BlocListener<PreferencesCubit, PreferencesState>(
      listenWhen: (previous, current) =>
          current.failure != null &&
          previous != current &&
          _selected != AppTab.profile,
      listener: (context, state) => AppFeedback.error(
        ScaffoldMessenger.of(context),
        context.failureMessage(state.failure!),
      ),
      child: PopScope(
        canPop: _selected == AppTab.home,
        onPopInvokedWithResult: (didPop, _) {
          // A branch handles its own pop. Only a branch root returns to Home.
          if (!didPop && !branchHandledBack) _select(AppTab.home);
        },
        child: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpace.maxWidth),
              child: IndexedStack(
                index: _selected.index,
                children: [for (final tab in AppTab.values) _branch(tab)],
              ),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: AppBottomNavigation(
              currentIndex: _selected.index,
              onTap: (index) => _select(AppTab.values[index]),
            ),
          ),
        ),
      ),
    );
  }
}
