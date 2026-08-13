import 'package:flutter/material.dart';

import 'package:tebiyu/core/theme/app_colors.dart';
import 'package:tebiyu/core/theme/app_radius.dart';
import 'package:tebiyu/core/theme/app_spacing.dart';
import 'package:tebiyu/core/theme/app_text_styles.dart';

/// The visual weight of a [TebiyuButton].
enum TebiyuButtonVariant {
  /// Filled brand green. The single main action on a screen.
  primary,

  /// Outlined. Secondary actions sitting beside a primary button.
  secondary,

  /// Text only. Tertiary actions such as View all or Skip.
  ghost,

  /// Outlined in the error colour. Delete, remove and report actions.
  destructive,
}

/// The height and type size of a [TebiyuButton].
enum TebiyuButtonSize {
  /// 36px. Inline card actions such as Edit and Delete.
  small,

  /// 48px. The default, and the minimum comfortable touch target.
  medium,

  /// 56px. Sticky bottom bar actions such as Post listing.
  large,
}

/// Tebiyu's button.
///
/// Wraps the themed Material buttons and adds what they cannot express on
/// their own: a loading state that holds its width so the layout does not jump
/// mid request, leading and trailing icon slots, and a destructive variant.
///
/// While [isLoading] is true the button ignores taps, which prevents the
/// double submit that otherwise creates duplicate listings or repeated
/// payment attempts on a slow connection.
class TebiyuButton extends StatelessWidget {
  /// Creates a button. Prefer the named constructors.
  const TebiyuButton({
    required this.label,
    required this.onPressed,
    this.variant = TebiyuButtonVariant.primary,
    this.size = TebiyuButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  /// A filled brand green button. Use one per screen.
  const TebiyuButton.primary({
    required this.label,
    required this.onPressed,
    this.size = TebiyuButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  }) : variant = TebiyuButtonVariant.primary;

  /// An outlined button for actions beside a primary button.
  const TebiyuButton.secondary({
    required this.label,
    required this.onPressed,
    this.size = TebiyuButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  }) : variant = TebiyuButtonVariant.secondary;

  /// A text only button for tertiary actions.
  const TebiyuButton.ghost({
    required this.label,
    required this.onPressed,
    this.size = TebiyuButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  }) : variant = TebiyuButtonVariant.ghost;

  /// An outlined error coloured button for destructive actions.
  ///
  /// Deliberately outlined rather than filled. A filled red button is heavy
  /// enough to draw the eye before the label is read, which invites the
  /// mistap it is meant to prevent.
  const TebiyuButton.destructive({
    required this.label,
    required this.onPressed,
    this.size = TebiyuButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  }) : variant = TebiyuButtonVariant.destructive;

  /// The button text.
  final String label;

  /// Tap handler. Pass null to disable the button.
  final VoidCallback? onPressed;

  /// The visual weight.
  final TebiyuButtonVariant variant;

  /// The height and type size.
  final TebiyuButtonSize size;

  /// Optional icon shown before the label.
  final IconData? icon;

  /// Optional icon shown after the label.
  final IconData? trailingIcon;

  /// Whether to show a spinner in place of the label.
  ///
  /// Taps are ignored while true.
  final bool isLoading;

  /// Whether the button should fill the width of its parent.
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null && !isLoading;

    final foreground = switch (variant) {
      TebiyuButtonVariant.primary => colors.onBrand,
      TebiyuButtonVariant.secondary => colors.brand,
      TebiyuButtonVariant.ghost => colors.brand,
      TebiyuButtonVariant.destructive => colors.error,
    };

    final disabledForeground = variant == TebiyuButtonVariant.primary
        ? colors.disabledText
        : colors.disabledText;

    final activeForeground = isEnabled ? foreground : disabledForeground;

    final background = switch (variant) {
      TebiyuButtonVariant.primary =>
        isEnabled ? colors.brand : colors.brandDisabled,
      _ => Colors.transparent,
    };

    final border = switch (variant) {
      TebiyuButtonVariant.secondary => BorderSide(color: activeForeground),
      TebiyuButtonVariant.destructive => BorderSide(color: activeForeground),
      _ => BorderSide.none,
    };

    final height = switch (size) {
      TebiyuButtonSize.small => 36.0,
      TebiyuButtonSize.medium => 48.0,
      TebiyuButtonSize.large => 56.0,
    };

    final textStyle = size == TebiyuButtonSize.small
        ? AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)
        : AppTextStyles.button;

    final iconSize = size == TebiyuButtonSize.small ? 16.0 : 18.0;

    final horizontalPadding = switch (size) {
      TebiyuButtonSize.small => AppSpacing.md,
      TebiyuButtonSize.medium => AppSpacing.xl,
      TebiyuButtonSize.large => AppSpacing.xl,
    };

    final content = isLoading
        ? SizedBox(
            height: iconSize,
            width: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(activeForeground),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: activeForeground),
                AppSpacing.hGapSm,
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle.copyWith(color: activeForeground),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (trailingIcon != null) ...[
                AppSpacing.hGapSm,
                Icon(trailingIcon, size: iconSize, color: activeForeground),
              ],
            ],
          );

    final button = Material(
      color: background,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: AppRadius.allSm,
        splashColor: colors.secondaryBackground,
        highlightColor: colors.secondaryBackground,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.allSm,
            border: border == BorderSide.none
                ? null
                : Border.fromBorderSide(border),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              widthFactor: isFullWidth ? null : 1,
              child: content,
            ),
          ),
        ),
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
