import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tebiyu/core/constants/app_assets.dart';
import 'package:tebiyu/core/theme/theme.dart';

/// Tebiyu's splash screen.
///
/// Deliberately theme independent. Like most brand splashes it keeps a fixed
/// light canvas in both light and dark mode, because it is a brand moment
/// rather than a themed surface, and nothing follows it visually that would
/// make the fixed palette feel inconsistent.
///
/// Layout is driven by fractions of the available space rather than fixed
/// offsets, so the scattered icons hold their composition from a 320px budget
/// phone through to a tablet. Sizes are clamped at both ends so the badge
/// neither overwhelms a small screen nor floats lost on a large one.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _canvas = Color(0xFFF4F7F5);
  static const Color _badge = Color(0xFF4CAF50);
  static const Color _scatter = Color(0xFF4CAF50);
  static const Color _tagline = Color(0xFF14181B);

  /// Minimum time the splash stays on screen.
  ///
  /// Startup checks usually finish far sooner than this on a warm start. A
  /// splash that flashes for 200ms reads as a rendering glitch rather than a
  /// brand moment, so the floor is fixed and only the ceiling varies with how
  /// long the checks actually take.
  static const Duration _minimumDisplay = Duration(milliseconds: 2200);

  late final AnimationController _entrance;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    unawaited(_entrance.forward());

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    unawaited(_pulse.repeat());

    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();

    // P1.6 restores Firebase Auth state here too, though auth does not gate
    // navigation: browsing is open, and sign in is requested only when a
    // seller or account action is tapped.
    final nextRoute = await _resolveNextRoute();

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumDisplay - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    // P1.5 replaces this with a go_router call.
    debugPrint('Splash resolved next route: $nextRoute');
  }

  Future<String> _resolveNextRoute() async {
    final hasCompletedOnboarding = await _readOnboardingFlag();
    return hasCompletedOnboarding ? '/home' : '/onboarding';
  }

  // P1.4 replaces this with a shared_preferences read.
  Future<bool> _readOnboardingFlag() async => false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final shortest = math.min(width, height);

          final badgeSize = (shortest * 0.30).clamp(96.0, 168.0);
          final logoWidth = badgeSize * 0.62;
          final scatterSize = (shortest * 0.055).clamp(16.0, 30.0);

          // Landscape and very short viewports lose the scattered layer. There
          // is not enough vertical room to place icons clear of the badge, and
          // a crowded splash reads worse than a plain one.
          final showScatter = height > 520 && height > width;

          return Stack(
            children: [
              if (showScatter)
                ..._scatterIcons.map(
                  (item) => _ScatterIcon(
                    item: item,
                    width: width,
                    height: height,
                    size: scatterSize,
                    color: _scatter,
                    animation: _entrance,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBadge(badgeSize, logoWidth),
                    SizedBox(height: badgeSize * 0.18),
                    _buildTagline(),
                    SizedBox(height: badgeSize * 0.30),
                    _buildLoader(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(double badgeSize, double logoWidth) {
    final scale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.10, 0.60, curve: Curves.easeOutBack),
    );
    final fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.10, 0.45, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.72, end: 1).animate(scale),
        child: Container(
          width: badgeSize,
          height: badgeSize,
          decoration: const BoxDecoration(
            color: _badge,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Image.asset(
            AppAssets.logo,
            width: logoWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    final fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(fade),
        child: Text(
          'Buy. Sell. Everything.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: _tagline),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    final fade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.70, 1, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final offset = index * 0.18;
              final t = (_pulse.value + 1 - offset) % 1.0;
              final opacity = 0.25 + (math.sin(t * math.pi) * 0.65);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _badge.withValues(alpha: opacity.clamp(0.2, 0.9)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  /// Scattered category icons, positioned as fractions of the viewport.
  ///
  /// Each entry keeps clear of the centre so the badge never collides with an
  /// icon regardless of screen proportions.
  static const List<_ScatterItem> _scatterIcons = [
    _ScatterItem(Icons.devices_outlined, 0.11, 0.08, 0.55),
    _ScatterItem(Icons.directions_car_filled_outlined, 0.62, 0.06, 0.75),
    _ScatterItem(Icons.storefront_outlined, 0.45, 0.20, 0.60),
    _ScatterItem(Icons.apartment_outlined, 0.84, 0.20, 0.70),
    _ScatterItem(Icons.shopping_cart_outlined, 0.18, 0.31, 0.65),
    _ScatterItem(Icons.sports_esports_outlined, 0.81, 0.40, 0.70),
    _ScatterItem(Icons.restaurant_outlined, 0.22, 0.58, 0.55),
    _ScatterItem(Icons.weekend_outlined, 0.73, 0.66, 0.75),
    _ScatterItem(Icons.two_wheeler_outlined, 0.23, 0.80, 0.65),
    _ScatterItem(Icons.shopping_bag_outlined, 0.74, 0.87, 0.60),
  ];
}

class _ScatterItem {
  const _ScatterItem(this.icon, this.dx, this.dy, this.opacity);

  final IconData icon;
  final double dx;
  final double dy;
  final double opacity;
}

class _ScatterIcon extends StatelessWidget {
  const _ScatterIcon({
    required this.item,
    required this.width,
    required this.height,
    required this.size,
    required this.color,
    required this.animation,
  });

  final _ScatterItem item;
  final double width;
  final double height;
  final double size;
  final Color color;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // Stagger the fade by horizontal position so the icons settle in from the
    // edges rather than all at once.
    final delay = (item.dx * 0.25).clamp(0.0, 0.25);
    final fade = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.45).clamp(0.0, 1.0)),
    );

    return Positioned(
      left: width * item.dx - size / 2,
      top: height * item.dy - size / 2,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: item.opacity).animate(fade),
        child: Icon(item.icon, size: size, color: color),
      ),
    );
  }
}
