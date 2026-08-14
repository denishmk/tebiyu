import 'package:flutter/material.dart';

/// Layout width thresholds for Tebiyu.
///
/// Values are logical pixels, not fractions of the viewport. A percentage
/// based cap still fails on a large display: 85% of a 1900px window is a
/// 1615px button. Single column content has an absolute readable width, and
/// past it the extra space should become margin rather than stretch.
abstract final class AppBreakpoints {
  /// Upper bound for a phone sized single column. Content screens such as
  /// splash, onboarding and auth stay at this width and centre themselves on
  /// anything wider.
  static const double content = 480;

  /// Upper bound for a two column tablet layout, used by browse and detail
  /// screens that can spread out.
  static const double wide = 900;

  /// Below this width, dense rows should fold. The feature row on the welcome
  /// slide uses this threshold.
  static const double compact = 340;
}

/// Centres [child] and caps its width.
///
/// Wrap the body of any single column screen in this. On a phone it is a no
/// op, because the viewport is already narrower than the cap. On a tablet or
/// in a browser it keeps the layout phone shaped instead of stretching
/// illustrations and buttons across the full window.
class ConstrainedPage extends StatelessWidget {
  /// Creates a width constrained, centred page body.
  const ConstrainedPage({
    required this.child,
    this.maxWidth = AppBreakpoints.content,
    super.key,
  });

  /// The content to constrain.
  final Widget child;

  /// Maximum width in logical pixels.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
