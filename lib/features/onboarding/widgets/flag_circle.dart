import 'package:flutter/material.dart';

/// A circular flag drawn as vector, sized to [size].
///
/// Drawn rather than shipped as an asset so the flags stay crisp at any
/// density and add nothing to the bundle. At the sizes used on the language
/// slide the detail is suggestive rather than exact, which is the right level
/// for a 44px avatar.
class FlagCircle extends StatelessWidget {
  /// Creates a circular flag.
  const FlagCircle({required this.flag, this.size = 44, super.key});

  /// Which flag to draw.
  final Flag flag;

  /// Diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CustomPaint(
          size: Size.square(size),
          painter: switch (flag) {
            Flag.unitedKingdom => _UnionJackPainter(),
            Flag.saudiArabia => _SaudiPainter(),
          },
        ),
      ),
    );
  }
}

/// The flags Tebiyu draws.
enum Flag {
  /// Union Jack, shown beside English.
  unitedKingdom,

  /// Saudi Arabian flag, shown beside Arabic.
  saudiArabia,
}

class _UnionJackPainter extends CustomPainter {
  static const Color _blue = Color(0xFF012169);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _red = Color(0xFFC8102E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = _blue);

    // Diagonals are drawn oversized and clipped by the parent ClipOval, which
    // avoids computing exact chord intersections for the circular crop.
    final whiteDiagonal = Paint()
      ..color = _white
      ..strokeWidth = h * 0.20
      ..strokeCap = StrokeCap.butt;
    canvas
      ..drawLine(Offset.zero, Offset(w, h), whiteDiagonal)
      ..drawLine(Offset(w, 0), Offset(0, h), whiteDiagonal);

    final redDiagonal = Paint()
      ..color = _red
      ..strokeWidth = h * 0.09
      ..strokeCap = StrokeCap.butt;
    canvas
      ..drawLine(Offset.zero, Offset(w, h), redDiagonal)
      ..drawLine(Offset(w, 0), Offset(0, h), redDiagonal)
      ..drawRect(
        Rect.fromLTWH(0, h * 0.35, w, h * 0.30),
        Paint()..color = _white,
      )
      ..drawRect(
        Rect.fromLTWH(w * 0.35, 0, w * 0.30, h),
        Paint()..color = _white,
      )
      ..drawRect(
        Rect.fromLTWH(0, h * 0.41, w, h * 0.18),
        Paint()..color = _red,
      )
      ..drawRect(
        Rect.fromLTWH(w * 0.41, 0, w * 0.18, h),
        Paint()..color = _red,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SaudiPainter extends CustomPainter {
  static const Color _green = Color(0xFF006C35);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = _green);

    final script = Paint()
      ..color = _white
      ..strokeWidth = h * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The shahada is calligraphic and cannot be rendered faithfully at this
    // scale. These strokes read as Arabic script at a glance, which is what a
    // 44px avatar communicates.
    final line = Path()
      ..moveTo(w * 0.18, h * 0.40)
      ..cubicTo(w * 0.30, h * 0.31, w * 0.38, h * 0.48, w * 0.50, h * 0.38)
      ..cubicTo(w * 0.60, h * 0.30, w * 0.70, h * 0.46, w * 0.82, h * 0.37);
    canvas.drawPath(line, script);

    final tail = Path()
      ..moveTo(w * 0.26, h * 0.52)
      ..cubicTo(w * 0.38, h * 0.45, w * 0.52, h * 0.58, w * 0.70, h * 0.49);
    canvas.drawPath(tail, script);

    final sword = Paint()
      ..color = _white
      ..strokeWidth = h * 0.055
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(w * 0.22, h * 0.70), Offset(w * 0.72, h * 0.70), sword)
      ..drawLine(
        Offset(w * 0.72, h * 0.70),
        Offset(w * 0.84, h * 0.65),
        Paint()
          ..color = _white
          ..strokeWidth = h * 0.030
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        Offset(w * 0.20, h * 0.63),
        Offset(w * 0.20, h * 0.77),
        Paint()
          ..color = _white
          ..strokeWidth = h * 0.045
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
