import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Resolution-independent custom vector illustrations for Learno Home.
///
/// Crafted using Flutter canvas painting to avoid external network/asset dependencies
/// while delivering an expressive, premium visual identity.

/// Hero artwork featuring an orbital curiosity spark and celestial discovery rings.
class HeroDiscoveryArtwork extends StatelessWidget {
  const HeroDiscoveryArtwork({super.key, this.size = 110});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HeroDiscoveryPainter()),
    );
  }
}

class _HeroDiscoveryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.48);
    final baseRadius = size.width * 0.42;

    // 1. Soft atmospheric back-glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.lavender.withValues(alpha: 0.35),
          AppColors.skyBlue.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.1));
    canvas.drawCircle(center, baseRadius * 1.1, glowPaint);

    // 2. Orbital Ring 1 (tilted oval, dashed)
    final orbit1Paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 5.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: baseRadius * 2.1,
        height: baseRadius * 0.85,
      ),
      orbit1Paint,
    );
    canvas.restore();

    // 3. Orbital Ring 2 (counter-tilted)
    final orbit2Paint = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: baseRadius * 1.7,
        height: baseRadius * 0.65,
      ),
      orbit2Paint,
    );
    canvas.restore();

    // 4. Central Companion Core (Playful Curiosity Spark)
    final coreGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.sunnyYellow, Color(0xFFFF9E44)],
    ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 0.42));

    final corePaint = Paint()
      ..shader = coreGradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.38, corePaint);

    // Core highlight
    final highlightPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - baseRadius * 0.12, center.dy - baseRadius * 0.12),
      baseRadius * 0.09,
      highlightPaint,
    );

    // 5. Star-burst sparkle facets
    _drawSparkle(canvas, center, baseRadius * 0.6, AppColors.white);

    // 6. Floating satellite satellites
    final sat1 = Offset(
      center.dx + baseRadius * 0.82,
      center.dy - baseRadius * 0.25,
    );
    canvas.drawCircle(
      sat1,
      size.width * 0.05,
      Paint()..color = AppColors.coral,
    );
    canvas.drawCircle(
      sat1,
      size.width * 0.02,
      Paint()..color = AppColors.white,
    );

    final sat2 = Offset(
      center.dx - baseRadius * 0.72,
      center.dy + baseRadius * 0.42,
    );
    canvas.drawCircle(
      sat2,
      size.width * 0.04,
      Paint()..color = AppColors.lavender,
    );

    final sat3 = Offset(
      center.dx + baseRadius * 0.35,
      center.dy + baseRadius * 0.78,
    );
    canvas.drawCircle(
      sat3,
      size.width * 0.03,
      Paint()..color = AppColors.skyBlue,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    const arms = 4;
    final outerR = radius * 0.42;
    final innerR = radius * 0.1;

    for (int i = 0; i < arms * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / arms) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Architectural layered isometric vector art for "Flutter Production Architecture".
class ArchitectureJourneyArtwork extends StatelessWidget {
  const ArchitectureJourneyArtwork({
    super.key,
    this.width = 96,
    this.height = 96,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _ArchitecturePainter()),
    );
  }
}

class _ArchitecturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final w = size.width * 0.46;
    final h = size.height * 0.22;

    // Draw three stacked isometric slabs representing architectural tiers:
    _drawIsoSlab(
      canvas,
      Offset(center.dx, center.dy + size.height * 0.22),
      w,
      h,
      thickness: 10,
      topColor: AppColors.lavender,
      leftColor: const Color(0xFF9E8CD9),
      rightColor: const Color(0xFFB4A3EE),
    );

    _drawIsoSlab(
      canvas,
      Offset(center.dx, center.dy),
      w * 0.88,
      h * 0.88,
      thickness: 10,
      topColor: AppColors.skyBlue,
      leftColor: const Color(0xFF88C8EC),
      rightColor: const Color(0xFFA5DCF8),
    );

    _drawIsoSlab(
      canvas,
      Offset(center.dx, center.dy - size.height * 0.22),
      w * 0.72,
      h * 0.72,
      thickness: 8,
      topColor: AppColors.sunnyYellow,
      leftColor: const Color(0xFFE4B33C),
      rightColor: const Color(0xFFFFDB7D),
    );

    final nodeOffset = Offset(center.dx, center.dy - size.height * 0.38);
    canvas.drawCircle(nodeOffset, 4.5, Paint()..color = AppColors.cobalt);
    canvas.drawCircle(nodeOffset, 2.0, Paint()..color = AppColors.white);
  }

  void _drawIsoSlab(
    Canvas canvas,
    Offset pos,
    double w,
    double h, {
    required double thickness,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
  }) {
    final topPath = Path()
      ..moveTo(pos.dx, pos.dy - h)
      ..lineTo(pos.dx + w, pos.dy)
      ..lineTo(pos.dx, pos.dy + h)
      ..lineTo(pos.dx - w, pos.dy)
      ..close();

    final leftPath = Path()
      ..moveTo(pos.dx - w, pos.dy)
      ..lineTo(pos.dx, pos.dy + h)
      ..lineTo(pos.dx, pos.dy + h + thickness)
      ..lineTo(pos.dx - w, pos.dy + thickness)
      ..close();

    final rightPath = Path()
      ..moveTo(pos.dx, pos.dy + h)
      ..lineTo(pos.dx + w, pos.dy)
      ..lineTo(pos.dx + w, pos.dy + thickness)
      ..lineTo(pos.dx, pos.dy + h + thickness)
      ..close();

    canvas.drawPath(leftPath, Paint()..color = leftColor);
    canvas.drawPath(rightPath, Paint()..color = rightColor);
    canvas.drawPath(topPath, Paint()..color = topColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact vector illustration for Backend Engineering journey.
class BackendJourneyArtwork extends StatelessWidget {
  const BackendJourneyArtwork({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BackendPainter()),
    );
  }
}

class _BackendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final r = size.width * 0.44;

    final bgPaint = Paint()..color = AppColors.coral.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    final cylinderPaint = Paint()..color = AppColors.coral;
    final highlightPaint = Paint()..color = AppColors.sunnyYellowLight;

    _drawCylinder(
      canvas,
      Offset(cx, cy - 8),
      size.width * 0.28,
      9,
      cylinderPaint,
      highlightPaint,
    );
    _drawCylinder(
      canvas,
      Offset(cx, cy + 8),
      size.width * 0.28,
      9,
      cylinderPaint,
      highlightPaint,
    );

    canvas.drawCircle(
      Offset(cx + size.width * 0.15, cy - 8),
      2.2,
      Paint()..color = AppColors.white,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.15, cy + 8),
      2.2,
      Paint()..color = AppColors.sunnyYellow,
    );
  }

  void _drawCylinder(
    Canvas canvas,
    Offset pos,
    double radiusX,
    double height,
    Paint bodyPaint,
    Paint topPaint,
  ) {
    final radiusY = radiusX * 0.35;
    final rect = Rect.fromCenter(
      center: pos,
      width: radiusX * 2,
      height: height,
    );

    canvas.drawRect(rect, bodyPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy + height / 2),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pos.dx, pos.dy - height / 2),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      topPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact vector illustration for System Design journey.
class SystemDesignArtwork extends StatelessWidget {
  const SystemDesignArtwork({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SystemDesignPainter()),
    );
  }
}

class _SystemDesignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final r = size.width * 0.44;

    final bgPaint = Paint()
      ..color = AppColors.sunnyYellow.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    final n1 = Offset(cx, cy - size.height * 0.22);
    final n2 = Offset(cx - size.width * 0.24, cy + size.height * 0.18);
    final n3 = Offset(cx + size.width * 0.24, cy + size.height * 0.18);

    final linePaint = Paint()
      ..color = AppColors.deepInk.withValues(alpha: 0.3)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(n1, n2, linePaint);
    canvas.drawLine(n1, n3, linePaint);
    canvas.drawLine(n2, n3, linePaint);

    final nodePaint = Paint()..color = AppColors.cobalt;
    final centerPaint = Paint()..color = AppColors.sunnyYellow;

    canvas.drawCircle(n1, 6.0, nodePaint);
    canvas.drawCircle(n1, 2.5, Paint()..color = AppColors.white);

    canvas.drawCircle(n2, 5.0, centerPaint);
    canvas.drawCircle(n3, 5.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
