import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the XML vector to a Flutter CustomPaint widget
    // Based on the ic_launcher_foreground.xml
    return CustomPaint(
      size: Size(size, size),
      painter: _AppLogoPainter(color: color),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final Color? color;

  _AppLogoPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color ?? const Color(0xFF5B13EC);

    final path1 = Path();
    path1.moveTo(size.width * 0.222, size.height * 0.778);
    path1.cubicTo(
      size.width * 0.389, size.height * 0.648,
      size.width * 0.667, size.height * 0.556,
      size.width * 0.852, size.height * 0.389,
    );
    path1.cubicTo(
      size.width * 0.815, size.height * 0.630,
      size.width * 0.574, size.height * 0.722,
      size.width * 0.370, size.height * 0.833,
    );
    path1.close();

    final path2 = Path();
    path2.moveTo(size.width * 0.204, size.height * 0.630);
    path2.cubicTo(
      size.width * 0.370, size.height * 0.500,
      size.width * 0.630, size.height * 0.426,
      size.width * 0.796, size.height * 0.278,
    );
    path2.cubicTo(
      size.width * 0.741, size.height * 0.519,
      size.width * 0.537, size.height * 0.611,
      size.width * 0.315, size.height * 0.704,
    );
    path2.close();

    final path3 = Path();
    path3.moveTo(size.width * 0.185, size.height * 0.481);
    path3.cubicTo(
      size.width * 0.352, size.height * 0.352,
      size.width * 0.593, size.height * 0.296,
      size.width * 0.741, size.height * 0.167,
    );
    path3.cubicTo(
      size.width * 0.667, size.height * 0.407,
      size.width * 0.481, size.height * 0.500,
      size.width * 0.278, size.height * 0.574,
    );
    path3.close();

    // Draw the paths with the paint
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
