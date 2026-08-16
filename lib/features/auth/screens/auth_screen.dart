import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tebiyu/core/constants/app_assets.dart';
import 'package:tebiyu/core/router/routes.dart';
import 'package:tebiyu/core/theme/theme.dart';
import 'package:tebiyu/core/widgets/constrained_page.dart';
import 'package:tebiyu/core/widgets/tebiyu_button.dart';
import 'package:tebiyu/features/auth/data/auth_providers.dart';
import 'package:tebiyu/features/auth/data/auth_repository.dart';
import 'package:tebiyu/features/onboarding/widgets/onboarding_illustrations.dart';

/// Whether the form is signing in or creating an account.
enum _AuthMode { signIn, signUp }

/// Sign in and sign up.
///
/// Reached only when a gated action is tapped, never as a wall in front of
/// browsing. [returnTo] carries where the user was heading so the original
/// intent resumes after authenticating.
///
/// On a tablet or desktop the screen splits: a brand panel on one side and the
/// form on the other. On a phone the brand panel is dropped entirely rather
/// than stacked above the form, because pushing the fields below the fold on
/// the one screen where the user has a task to complete is a needless cost.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates the auth screen.
  const AuthScreen({this.returnTo, super.key});

  /// The encoded location to resume after signing in.
  final String? returnTo;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _isBusy = false;
  bool _obscurePassword = true;
  String? _error;

  bool get _isSignUp => _mode == _AuthMode.signUp;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _destination => widget.returnTo == null
      ? Routes.home
      : Uri.decodeComponent(widget.returnTo!);

  void _leave() => context.go(_destination);

  void _dismiss() => context.go(Routes.home);

  /// Runs [action] with a busy flag and surfaces any [AuthFailure].
  ///
  /// Every entry point funnels through here so the button always shows a
  /// spinner while work is in flight. On a slow connection an unresponsive
  /// button invites a second tap, which for sign up means a duplicate account
  /// attempt and a confusing error.
  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      await action();
      if (!mounted) return;
      _leave();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      // A cancelled Google sheet is not an error worth showing.
      setState(() {
        _error = failure.code == 'canceled' ? null : failure.message;
        _isBusy = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isBusy = false;
      });
    }
  }

  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repository = ref.read(authRepositoryProvider);
    final email = _emailController.text;
    final password = _passwordController.text;

    await _run(() async {
      if (_isSignUp) {
        await repository.signUpWithEmail(
          email: email,
          password: password,
          displayName: _nameController.text,
        );
      } else {
        await repository.signInWithEmail(email: email, password: password);
      }
    });
  }

  Future<void> _submitGoogle() async {
    final repository = ref.read(authRepositoryProvider);
    await _run(repository.signInWithGoogle);
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter your email above, then tap reset.');
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    setState(() {
      _isBusy = true;
      _error = null;
    });

    try {
      await repository.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to $email')),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.message;
        _isBusy = false;
      });
    }
  }

  void _comingSoon(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$method sign in is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.wide;

          if (!isWide) {
            return SafeArea(
              child: ColoredBox(
                color: colors.primaryBackground,
                child: _buildForm(showClose: true),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  const Expanded(flex: 5, child: _BrandPanel()),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primaryBackground,
                        borderRadius: AppRadius.allLg,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedPage(
                        child: _buildForm(showClose: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm({required bool showClose}) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (showClose)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: colors.secondaryIcon,
                    onPressed: _dismiss,
                  ),
                const Spacer(),
                TebiyuButton.ghost(
                  label: 'Need help?',
                  trailingIcon: Icons.help_outline,
                  size: TebiyuButtonSize.small,
                  onPressed: () => _comingSoon('Support'),
                ),
              ],
            ),
            AppSpacing.gapXl,

            _SplitHeading(
              leading: _isSignUp ? 'Create your ' : 'Welcome to ',
              accent: _isSignUp ? 'account' : 'Tebiyu',
            ),
            AppSpacing.gapSm,
            Text(
              _isSignUp
                  ? 'Sign up to manage your listings, chat with other buyers '
                        'and sellers, and more.'
                  : 'Log in or sign up to manage your listings, chat with '
                        'other buyers and sellers, and more.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.secondaryText,
              ),
            ),
            AppSpacing.gapXl,

            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              AppSpacing.gapLg,
            ],

            _SocialButton(
              label: 'Continue with Google',
              leading: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: Image.asset(AppAssets.googleIcon),
              ),
              onPressed: _isBusy ? null : _submitGoogle,
            ),

            AppSpacing.gapXl,
            const _OrDivider(),
            AppSpacing.gapXl,

            if (_isSignUp) ...[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Your full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Enter your name';
                  }
                  return null;
                },
              ),
              AppSpacing.gapMd,
            ],

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email';
                if (!email.contains('@') || !email.contains('.')) {
                  return 'That email does not look right';
                }
                return null;
              },
            ),
            AppSpacing.gapMd,

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitEmail(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) return 'Enter your password';
                if (_isSignUp && password.length < 6) {
                  return 'Use at least 6 characters';
                }
                return null;
              },
            ),

            if (!_isSignUp) ...[
              AppSpacing.gapXs,
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TebiyuButton.ghost(
                  label: 'Forgot password?',
                  size: TebiyuButtonSize.small,
                  onPressed: _isBusy ? null : _resetPassword,
                ),
              ),
            ],

            AppSpacing.gapLg,
            TebiyuButton.primary(
              label: _isSignUp ? 'Create account' : 'Continue',
              size: TebiyuButtonSize.large,
              isFullWidth: true,
              isLoading: _isBusy,
              onPressed: _submitEmail,
            ),

            AppSpacing.gapLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUp
                      ? 'Already have an account?'
                      : "Don't have an account?",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                TebiyuButton.ghost(
                  label: _isSignUp ? 'Log in' : 'Sign up',
                  size: TebiyuButtonSize.small,
                  onPressed: _isBusy
                      ? null
                      : () => setState(() {
                          _mode = _isSignUp
                              ? _AuthMode.signIn
                              : _AuthMode.signUp;
                          _error = null;
                        }),
                ),
              ],
            ),

            AppSpacing.gapSm,
            TebiyuButton.ghost(
              label: 'Keep browsing',
              onPressed: _isBusy ? null : _dismiss,
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                // The wide layout carries the badges in the brand panel, so
                // showing them here as well would duplicate them.
                final isNarrow =
                    MediaQuery.sizeOf(context).width < AppBreakpoints.wide;
                if (!isNarrow) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xxl),
                  child: TrustBadges(isCompact: true),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The branded side panel shown beside the form on wide screens.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tebiyu',
            style: AppTextStyles.h1.copyWith(
              color: colors.brand,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Buy. Sell. Everything.',
            style: AppTextStyles.body.copyWith(color: colors.primaryText),
          ),
          Expanded(
            child: Center(
              child: WelcomeIllustration(
                accent: colors.brand,
                surface: colors.primaryBackground,
              ),
            ),
          ),
          const TrustBadges(),
        ],
      ),
    );
  }
}

/// The three reassurance badges shown at the foot of the auth screen.
class TrustBadges extends StatelessWidget {
  /// Creates the badge row.
  const TrustBadges({this.isCompact = false, super.key});

  /// Whether to drop the descriptions and show labels only.
  final bool isCompact;

  static const List<(IconData, String, String)> _badges = [
    (
      Icons.shield_outlined,
      'Safe & Secure',
      'Your data is encrypted and protected',
    ),
    (
      Icons.verified_outlined,
      'Trusted Community',
      'Join thousands of verified buyers and sellers',
    ),
    (
      Icons.support_agent_outlined,
      '24/7 Support',
      "We're here to help you anytime",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, label, description) in _badges)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  Icon(icon, size: 22, color: colors.primaryText),
                  AppSpacing.gapSm,
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isCompact) ...[
                    AppSpacing.gapXs,
                    Text(
                      description,
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
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled ? colors.brand : colors.brandDisabled,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.allSm,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              AppSpacing.hGapMd,
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: isEnabled ? colors.onBrand : colors.disabledText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitHeading extends StatelessWidget {
  const _SplitHeading({required this.leading, required this.accent});

  final String leading;
  final String accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700);

    return Text.rich(
      TextSpan(
        text: leading,
        style: style.copyWith(color: colors.primaryText),
        children: [
          TextSpan(
            text: accent,
            style: style.copyWith(color: colors.brand),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorBackground,
        borderRadius: AppRadius.allSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: colors.error),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Or',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 0.5)),
      ],
    );
  }
}
