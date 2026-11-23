import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_views.dart';
import '../../../catalog/presentation/ui/manage_collection_screen.dart';
import '../../../favorites/presentation/ui/favorites_screen.dart';
import '../cubit/preferences_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onExplore,
    this.scrollController,
    super.key,
  });
  final VoidCallback onExplore;
  final ScrollController? scrollController;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<PreferencesCubit, PreferencesState>(
    builder: (context, state) {
      final l = context.l10n;
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpace.page),
        children: [
          Text(l.settings, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpace.xxl),
          const Center(
            child: CircleAvatar(
              radius: DesignMetrics.profileAvatarSize / 2,
              backgroundColor: AppColors.paleBlue,
              child: Icon(
                Icons.person_outline_rounded,
                size: DesignMetrics.avatarSize,
                color: AppColors.blue,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Center(
            child: Text(
              l.appTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          const Divider(),
          if (state.failure != null)
            InlineFailure(
              failure: state.failure!,
              retry: () => context.read<PreferencesCubit>().restore(),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.favorite_border_rounded),
            title: Text(l.saved),
            trailing: const RotatedBox(
              quarterTurns: 2,
              child: BackButtonIcon(),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(l.saved)),
                  body: FavoritesScreen(
                    explore: () {
                      Navigator.of(context).pop();
                      onExplore();
                    },
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.grid_view_outlined),
            title: Text(l.manage),
            trailing: const RotatedBox(
              quarterTurns: 2,
              child: BackButtonIcon(),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ManageCollectionScreen(),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: AppSpace.xl),
          LanguageSelectorCard(
            currentLocale: state.locale,
            disabled: state.saving,
            onSelect: (value) =>
                context.read<PreferencesCubit>().selectLocale(value),
          ),
          const SizedBox(height: AppSpace.xxl),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l.aboutApp),
            trailing: const RotatedBox(
              quarterTurns: 2,
              child: BackButtonIcon(),
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(l.demoTitle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.demoBody),
                      const SizedBox(height: AppSpace.lg),
                      Text(
                        l.simulationTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(l.simulationBody),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: Text(l.back),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// A premium, interactive language selection card with native typography and visual feedback.
class LanguageSelectorCard extends StatelessWidget {
  const LanguageSelectorCard({
    required this.currentLocale,
    required this.onSelect,
    this.disabled = false,
    super.key,
  });

  final Locale currentLocale;
  final ValueChanged<String> onSelect;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final isArabic = currentLocale.languageCode == 'ar';
    final l = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpace.xl),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.language,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? 'العربية (Arabic)' : 'English (US)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  isArabic ? 'العربية' : 'English',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(
                child: _LanguageOptionCard(
                  title: l.english,
                  code: 'en',
                  subtitle: l.ltrDirection,
                  isSelected: !isArabic,
                  onTap: disabled || !isArabic ? null : () => onSelect('en'),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _LanguageOptionCard(
                  title: l.arabic,
                  code: 'ar',
                  subtitle: l.rtlDirection,
                  isSelected: isArabic,
                  onTap: disabled || isArabic ? null : () => onSelect('ar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.title,
    required this.code,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String code;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSpace.lg),
        border: Border.all(
          color: isSelected ? AppColors.blue : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpace.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blue
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blue : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.blue
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.blue
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

