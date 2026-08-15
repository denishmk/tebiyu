import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/services/auth_state.dart';
import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/core/widgets/tebiyu_button.dart';

/// Placeholder sign in screen.
///
/// The real providers land in P1.6. The stub button here is functional on
/// purpose: it flips [AuthState] and returns to [returnTo], so the whole
/// deferred auth path can be exercised end to end before Firebase exists.
class AuthScreen extends StatelessWidget {
  /// Creates the auth screen.
  const AuthScreen({this.returnTo, super.key});

  /// The location the user was heading to when the gate fired.
  ///
  /// Null when auth was opened directly rather than by a redirect.
  final String? returnTo;

  void _completeSignIn(BuildContext context) {
    AuthState.instance.signIn();
    final destination = returnTo == null
        ? Routes.home
        : Uri.decodeComponent(returnTo!);
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.screenHorizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: colors.primaryIcon,
                ),
              ),
              AppSpacing.gapLg,
              Text(
                'Welcome to Tebiyu',
                style: AppTextStyles.h2.copyWith(color: colors.primaryText),
              ),
              AppSpacing.gapSm,
              Text(
                'Sign in to message sellers, post listings and manage your '
                'account. Browsing stays open either way.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              AppSpacing.gapXl,
              TebiyuButton.primary(
                label: 'Continue (stub)',
                icon: Icons.login,
                isFullWidth: true,
                onPressed: () => _completeSignIn(context),
              ),
              AppSpacing.gapMd,
              TebiyuButton.ghost(
                label: 'Keep browsing',
                onPressed: () => context.go(Routes.home),
              ),
              if (returnTo != null) ...[
                AppSpacing.gapLg,
                Text(
                  'Will return to ${Uri.decodeComponent(returnTo!)}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
