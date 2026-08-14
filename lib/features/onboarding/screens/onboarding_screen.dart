import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tebiyu/core/services/preferences_service.dart';
import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/core/widgets/constrained_page.dart';
import 'package:tebiyu/core/widgets/tebiyu_button.dart';
import 'package:tebiyu/features/onboarding/widgets/flag_circle.dart';
import 'package:tebiyu/features/onboarding/widgets/onboarding_illustrations.dart';

/// Tebiyu's two slide onboarding.
///
/// Slide one picks a language and cannot be skipped, so the preference is
/// always explicit rather than silently defaulted. Slide two introduces the
/// marketplace and completes onboarding.
///
/// Each slide scrolls independently while the action button and progress dots
/// stay pinned, so the primary action is reachable on a short screen without
/// the content being compressed to fit.
class OnboardingScreen extends StatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _page = 0;
  String _language = 'en';
  bool _isFinishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPrimaryAction() async {
    if (_page == 0) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() => _isFinishing = true);
    await PreferencesService.completeOnboarding(_language);

    if (!mounted) return;
    setState(() => _isFinishing = false);

    // P1.5 replaces this with a go_router call to the home shell.
    debugPrint('Onboarding complete. Language: $_language');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _page = index),
                children: [
                  _LanguageSlide(
                    selected: _language,
                    onSelect: (code) => setState(() => _language = code),
                  ),
                  const _WelcomeSlide(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  TebiyuButton.primary(
                    label: _page == 0 ? 'Continue' : 'Get Started',
                    trailingIcon: Icons.arrow_forward,
                    size: TebiyuButtonSize.large,
                    isFullWidth: true,
                    isLoading: _isFinishing,
                    onPressed: () => unawaited(_onPrimaryAction()),
                  ),
                  AppSpacing.gapLg,
                  _Dots(count: 2, active: _page),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSlide extends StatelessWidget {
  const _LanguageSlide({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.gapXl,
          const _Wordmark(),
          AppSpacing.gapXl,
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.secondaryBackground,
              borderRadius: AppRadius.allMd,
            ),
            child: Icon(
              Icons.language_outlined,
              size: 30,
              color: context.colors.primaryIcon,
            ),
          ),
          AppSpacing.gapLg,
          _SplitHeading(
            leading: 'Choose Your ',
            accent: 'Language',
            style: AppTextStyles.h1,
          ),
          AppSpacing.gapSm,
          Text(
            "Select the language you'd like to use in Tebiyu. "
            'You can change it anytime in Settings.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
          AppSpacing.gapXl,
          _LanguageCard(
            flag: Flag.unitedKingdom,
            name: 'English',
            subtitle: 'Continue in English',
            isSelected: selected == 'en',
            onTap: () => onSelect('en'),
          ),
          AppSpacing.gapMd,
          _LanguageCard(
            flag: Flag.saudiArabia,
            name: 'العربية',
            subtitle: 'المتابعة باللغة العربية',
            isSelected: selected == 'ar',
            onTap: () => onSelect('ar'),
          ),
          AppSpacing.gapXl,
          LanguageIllustration(
            accent: context.colors.brand,
            surface: context.colors.primaryBackground,
          ),
          AppSpacing.gapMd,
        ],
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.gapXl,
          const _Wordmark(),
          AppSpacing.gapLg,
          WelcomeIllustration(
            accent: context.colors.brand,
            surface: context.colors.primaryBackground,
          ),
          AppSpacing.gapXl,
          _SplitHeading(
            leading: 'Welcome to ',
            accent: 'Tebiyu',
            style: AppTextStyles.h1,
          ),
          AppSpacing.gapMd,
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: context.colors.brand,
              borderRadius: AppRadius.allPill,
            ),
          ),
          AppSpacing.gapMd,
          Text(
            'Buy, sell, discover opportunities, and connect with your '
            'community — all in one trusted marketplace.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
          AppSpacing.gapXl,
          const _FeatureRow(),
          AppSpacing.gapMd,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  static const List<_Feature> _features = [
    _Feature(
      Icons.shopping_bag_outlined,
      'Buy',
      'Find great products and services near you.',
    ),
    _Feature(
      Icons.sell_outlined,
      'Sell',
      'List in minutes and reach more buyers.',
    ),
    _Feature(
      Icons.chat_bubble_outline,
      'Connect',
      'Chat easily and make deals faster.',
    ),
    _Feature(
      Icons.verified_user_outlined,
      'Trust',
      'Verified profiles and safer trading.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Four columns need roughly 80px each to avoid clipping the labels.
        // Narrower than that and the row folds into two rows of two.
        final isWide = constraints.maxWidth >= AppBreakpoints.compact;
        final rows = isWide
            ? [_features]
            : [_features.sublist(0, 2), _features.sublist(2)];

        return Column(
          children: [
            for (final row in rows) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0)
                        VerticalDivider(
                          width: AppSpacing.sm,
                          thickness: 0.5,
                          color: context.colors.border,
                        ),
                      Expanded(child: _FeatureColumn(feature: row[i])),
                    ],
                  ],
                ),
              ),
              if (row != rows.last) AppSpacing.gapLg,
            ],
          ],
        );
      },
    );
  }
}

class _FeatureColumn extends StatelessWidget {
  const _FeatureColumn({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.secondaryBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            feature.icon,
            size: 22,
            color: context.colors.primaryIcon,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          feature.label,
          style: AppTextStyles.h4.copyWith(color: context.colors.brand),
        ),
        AppSpacing.gapXs,
        Text(
          feature.description,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: context.colors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.label, this.description);

  final IconData icon;
  final String label;
  final String description;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final Flag flag;
  final String name;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? colors.secondaryBackground : Colors.transparent,
      borderRadius: AppRadius.allMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allMd,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.allMd,
            border: Border.all(
              color: isSelected ? colors.brand : colors.border,
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.appBackground,
                    borderRadius: AppRadius.allMd,
                  ),
                  alignment: Alignment.center,
                  child: FlagCircle(flag: flag, size: 36),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.h4.copyWith(
                          color: colors.primaryText,
                        ),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapSm,
                _SelectionMark(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected ? colors.brand : Colors.transparent,
        shape: BoxShape.circle,
        border: isSelected
            ? null
            : Border.all(color: colors.border, width: 1.5),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 16, color: colors.onBrand)
          : null,
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tebiyu',
          style: AppTextStyles.h1.copyWith(
            color: context.colors.brand,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Find what you need',
          style: AppTextStyles.body.copyWith(color: context.colors.primaryText),
        ),
      ],
    );
  }
}

class _SplitHeading extends StatelessWidget {
  const _SplitHeading({
    required this.leading,
    required this.accent,
    required this.style,
  });

  final String leading;
  final String accent;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: leading,
        style: style.copyWith(color: context.colors.primaryText),
        children: [
          TextSpan(
            text: accent,
            style: style.copyWith(color: context.colors.brand),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? colors.brand : colors.border,
            borderRadius: AppRadius.allPill,
          ),
        );
      }),
    );
  }
}
