import 'package:flutter/material.dart';

/// The layered marketplace scene shown on the language slide.
///
/// Drawn rather than shipped as an asset. Every tone is the brand green at a
/// different opacity over a transparent canvas, so the scene composites
/// correctly on a white card and on a dark one without a second artwork.
class LanguageIllustration extends StatelessWidget {
  /// Creates the language slide illustration.
  const LanguageIllustration({
    required this.accent,
    required this.surface,
    super.key,
  });

  /// The brand green the scene is built from.
  final Color accent;

  /// The card colour, used for shapes that must read as light objects.
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 290 / 125,
      child: CustomPaint(
        painter: _LanguageScenePainter(accent: accent, surface: surface),
      ),
    );
  }
}

/// The phone and feature badge scene shown on the welcome slide.
class WelcomeIllustration extends StatelessWidget {
  /// Creates the welcome slide illustration.
  const WelcomeIllustration({
    required this.accent,
    required this.surface,
    super.key,
  });

  /// The brand green the scene is built from.
  final Color accent;

  /// The card colour, used for the phone body.
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 290 / 175,
      child: CustomPaint(
        painter: _WelcomeScenePainter(accent: accent, surface: surface),
      ),
    );
  }
}

/// Shared helpers for the two scene painters.
abstract class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.accent, required this.surface});

  final Color accent;
  final Color surface;

  Paint tint(double opacity) =>
      Paint()..color = accent.withValues(alpha: opacity);

  /// Draws a Material icon glyph centred on [center].
  void drawIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  /// Draws the stylised skyline used behind both scenes.
  void drawSkyline(Canvas canvas, double s, double baseline, Paint paint) {
    void block(double x, double w, double top) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x * s, top * s, (x + w) * s, baseline * s),
          Radius.circular(2 * s),
        ),
        paint,
      );
    }

    void spire(double x, double w, double shoulder, double peak) {
      final path = Path()
        ..moveTo(x * s, baseline * s)
        ..lineTo(x * s, shoulder * s)
        ..lineTo((x + w / 2) * s, peak * s)
        ..lineTo((x + w) * s, shoulder * s)
        ..lineTo((x + w) * s, baseline * s)
        ..close();
      canvas.drawPath(path, paint);
    }

    block(26, 10, 20);
    block(42, 14, 34);
    spire(64, 16, 38, 22);
    block(90, 16, 28);
    block(112, 11, 16);
    spire(132, 16, 30, 2);
    block(158, 18, 36);
    block(182, 12, 24);
    block(200, 20, 40);
    block(228, 13, 28);
    block(248, 17, 46);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.surface != surface;
}

class _LanguageScenePainter extends _ScenePainter {
  const _LanguageScenePainter({required super.accent, required super.surface});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 290;

    final backHill = Path()
      ..moveTo(0, 80 * s)
      ..quadraticBezierTo(50 * s, 20 * s, 110 * s, 42 * s)
      ..quadraticBezierTo(160 * s, 60 * s, 200 * s, 28 * s)
      ..quadraticBezierTo(245 * s, -6 * s, 290 * s, 28 * s)
      ..lineTo(290 * s, 102 * s)
      ..lineTo(0, 102 * s)
      ..close();
    canvas.drawPath(backHill, tint(0.08));

    final frontHill = Path()
      ..moveTo(0, 84 * s)
      ..quadraticBezierTo(60 * s, 52 * s, 118 * s, 70 * s)
      ..quadraticBezierTo(176 * s, 88 * s, 230 * s, 62 * s)
      ..quadraticBezierTo(265 * s, 46 * s, 290 * s, 60 * s)
      ..lineTo(290 * s, 102 * s)
      ..lineTo(0, 102 * s)
      ..close();
    canvas.drawPath(frontHill, tint(0.13));

    drawSkyline(canvas, s, 82, tint(0.22));

    final bridge = Paint()
      ..color = accent.withValues(alpha: 0.26)
      ..strokeWidth = 3 * s
      ..style = PaintingStyle.stroke;
    final bridgePath = Path()
      ..moveTo(14 * s, 78 * s)
      ..lineTo(14 * s, 56 * s)
      ..quadraticBezierTo(40 * s, 38 * s, 66 * s, 56 * s)
      ..lineTo(66 * s, 78 * s);
    canvas
      ..drawPath(bridgePath, bridge)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(145 * s, 112 * s),
          width: 256 * s,
          height: 20 * s,
        ),
        tint(0.06),
      );

    _armchair(canvas, s, left: 180, top: 58);
    _giftBox(canvas, s, left: 238, top: 82);
    _shoppingBag(canvas, s, left: 102, top: 66);
    _plant(canvas, s, left: 72, bottom: 106);
  }

  void _armchair(
    Canvas canvas,
    double s, {
    required double left,
    required double top,
  }) {
    final body = tint(0.85);
    final arm = tint(1);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left * s, (top + 12) * s, 54 * s, 34 * s),
          Radius.circular(4 * s),
        ),
        body,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((left + 8) * s, top * s, 38 * s, 16 * s),
          Radius.circular(6 * s),
        ),
        arm,
      )
      ..drawRect(
        Rect.fromLTWH(left * s, (top + 12) * s, 54 * s, 7 * s),
        arm,
      )
      ..drawCircle(
        Offset((left + 27) * s, (top + 32) * s),
        8 * s,
        Paint()..color = surface.withValues(alpha: 0.55),
      );
  }

  void _giftBox(
    Canvas canvas,
    double s, {
    required double left,
    required double top,
  }) {
    final box = tint(0.55);
    final ribbon = Paint()..color = surface.withValues(alpha: 0.75);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left * s, top * s, 26 * s, 22 * s),
          Radius.circular(3 * s),
        ),
        box,
      )
      ..drawRect(
        Rect.fromLTWH(left * s, (top + 6) * s, 26 * s, 3.5 * s),
        ribbon,
      )
      ..drawRect(
        Rect.fromLTWH((left + 11) * s, top * s, 3.5 * s, 22 * s),
        ribbon,
      );
  }

  void _shoppingBag(
    Canvas canvas,
    double s, {
    required double left,
    required double top,
  }) {
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left * s, (top + 26) * s, 52 * s, 40 * s),
          Radius.circular(6 * s),
        ),
        Paint()..color = surface,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left * s, (top + 26) * s, 52 * s, 40 * s),
          Radius.circular(6 * s),
        ),
        Paint()
          ..color = accent.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 * s,
      );

    final handle = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..strokeWidth = 2.5 * s
      ..style = PaintingStyle.stroke;
    final handlePath = Path()
      ..moveTo((left + 12) * s, (top + 26) * s)
      ..lineTo((left + 12) * s, (top + 8) * s)
      ..quadraticBezierTo(
        (left + 26) * s,
        top * s,
        (left + 40) * s,
        (top + 8) * s,
      )
      ..lineTo((left + 40) * s, (top + 26) * s);
    canvas.drawPath(handlePath, handle);

    final letter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: 'T',
        style: TextStyle(
          fontSize: 20 * s,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      )
      ..layout();
    letter.paint(
      canvas,
      Offset(
        (left + 26) * s - letter.width / 2,
        (top + 46) * s - letter.height / 2,
      ),
    );
  }

  void _plant(
    Canvas canvas,
    double s, {
    required double left,
    required double bottom,
  }) {
    final pot = Path()
      ..moveTo(left * s, bottom * s)
      ..lineTo((left + 4) * s, (bottom - 22) * s)
      ..lineTo((left + 22) * s, (bottom - 22) * s)
      ..lineTo((left + 26) * s, bottom * s)
      ..close();
    canvas
      ..drawPath(pot, tint(0.18))
      ..drawLine(
        Offset((left + 13) * s, (bottom - 22) * s),
        Offset((left + 13) * s, (bottom - 42) * s),
        Paint()
          ..color = accent.withValues(alpha: 0.6)
          ..strokeWidth = 2 * s,
      );

    final leafLeft = Path()
      ..moveTo((left + 13) * s, (bottom - 34) * s)
      ..quadraticBezierTo(
        left * s,
        (bottom - 40) * s,
        (left + 2) * s,
        (bottom - 52) * s,
      )
      ..quadraticBezierTo(
        (left + 14) * s,
        (bottom - 50) * s,
        (left + 13) * s,
        (bottom - 34) * s,
      );
    final leafRight = Path()
      ..moveTo((left + 13) * s, (bottom - 36) * s)
      ..quadraticBezierTo(
        (left + 26) * s,
        (bottom - 44) * s,
        (left + 26) * s,
        (bottom - 56) * s,
      )
      ..quadraticBezierTo(
        (left + 12) * s,
        (bottom - 52) * s,
        (left + 13) * s,
        (bottom - 36) * s,
      );
    canvas
      ..drawPath(leafLeft, tint(0.7))
      ..drawPath(leafRight, tint(0.9));
  }
}

class _WelcomeScenePainter extends _ScenePainter {
  const _WelcomeScenePainter({required super.accent, required super.surface});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 290;

    final hill = Path()
      ..moveTo(0, 134 * s)
      ..quadraticBezierTo(60 * s, 86 * s, 120 * s, 112 * s)
      ..quadraticBezierTo(180 * s, 138 * s, 240 * s, 104 * s)
      ..lineTo(290 * s, 124 * s)
      ..lineTo(290 * s, 164 * s)
      ..lineTo(0, 164 * s)
      ..close();
    canvas.drawPath(hill, tint(0.09));

    drawSkyline(canvas, s, 144, tint(0.18));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(140 * s, 172 * s),
        width: 264 * s,
        height: 20 * s,
      ),
      tint(0.06),
    );

    _armchair(canvas, s, left: 26, top: 124);
    _plant(canvas, s, left: 2, bottom: 164);
    _phone(canvas, s);

    _badge(canvas, s, const Offset(54, 54), Icons.shopping_bag_outlined);
    _badge(canvas, s, const Offset(232, 40), Icons.handshake_outlined);
    _badge(canvas, s, const Offset(240, 120), Icons.work_outline);
  }

  void _phone(Canvas canvas, double s) {
    const left = 96.0;
    const top = 14.0;
    const w = 88.0;
    const h = 152.0;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(left * s, top * s, w * s, h * s),
      Radius.circular(12 * s),
    );
    canvas
      ..drawRRect(frame, Paint()..color = surface)
      ..drawRRect(
        frame,
        Paint()
          ..color = accent.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((left + 26) * s, (top + 6) * s, 36 * s, 6 * s),
          Radius.circular(3 * s),
        ),
        tint(0.20),
      );

    void bar(
      double x,
      double y,
      double bw,
      double bh,
      double o, {
      double r = 2,
    }) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((left + x) * s, (top + y) * s, bw * s, bh * s),
          Radius.circular(r * s),
        ),
        tint(o),
      );
    }

    bar(10, 22, 34, 7, 0.85);
    bar(52, 20, 28, 11, 0.18, r: 5);
    bar(10, 40, 70, 13, 0.09, r: 5);
    bar(10, 60, 32, 11, 0.85, r: 5);
    bar(46, 60, 34, 11, 0.09, r: 5);
    bar(10, 80, 33, 30, 0.16, r: 4);
    bar(47, 80, 33, 30, 0.24, r: 4);
    bar(10, 116, 33, 26, 0.24, r: 4);
    bar(47, 116, 33, 26, 0.16, r: 4);
  }

  void _badge(Canvas canvas, double s, Offset center, IconData icon) {
    final c = Offset(center.dx * s, center.dy * s);
    canvas.drawCircle(c, 24 * s, tint(0.14));
    drawIcon(canvas, icon, c, 22 * s, accent);
  }

  void _armchair(
    Canvas canvas,
    double s, {
    required double left,
    required double top,
  }) {
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left * s, (top + 8) * s, 44 * s, 32 * s),
          Radius.circular(6 * s),
        ),
        tint(0.75),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((left + 6) * s, top * s, 32 * s, 12 * s),
          Radius.circular(5 * s),
        ),
        tint(0.95),
      );
  }

  void _plant(
    Canvas canvas,
    double s, {
    required double left,
    required double bottom,
  }) {
    final pot = Path()
      ..moveTo(left * s, bottom * s)
      ..lineTo((left + 4) * s, (bottom - 20) * s)
      ..lineTo((left + 20) * s, (bottom - 20) * s)
      ..lineTo((left + 24) * s, bottom * s)
      ..close();
    canvas
      ..drawPath(pot, tint(0.18))
      ..drawLine(
        Offset((left + 12) * s, (bottom - 20) * s),
        Offset((left + 12) * s, (bottom - 38) * s),
        Paint()
          ..color = accent.withValues(alpha: 0.6)
          ..strokeWidth = 2 * s,
      );

    final leaf = Path()
      ..moveTo((left + 12) * s, (bottom - 30) * s)
      ..quadraticBezierTo(
        left * s,
        (bottom - 36) * s,
        (left + 2) * s,
        (bottom - 47) * s,
      )
      ..quadraticBezierTo(
        (left + 13) * s,
        (bottom - 45) * s,
        (left + 12) * s,
        (bottom - 30) * s,
      );
    canvas.drawPath(leaf, tint(0.8));
  }
}
