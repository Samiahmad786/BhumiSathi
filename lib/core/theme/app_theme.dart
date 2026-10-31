import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Earthy green + saffron palette.
class AppColors {
  static const forest = Color(0xFF2E5E3E);
  static const moss = Color(0xFF6B8E3D);
  static const saffron = Color(0xFFE8832A);
  static const turmeric = Color(0xFFF2B544);
  static const clay = Color(0xFFB5603A);
  static const soil = Color(0xFF3B2E22);
  static const grain = Color(0xFFF7F2E4);
  static const paper = Color(0xFFFFFCF4);
}

class AppTheme {
  static ThemeData light() => _build(const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.forest,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD7E6C6),
        onPrimaryContainer: Color(0xFF12301B),
        secondary: AppColors.saffron,
        onSecondary: Color(0xFF2B1706),
        secondaryContainer: Color(0xFFFFDDB8),
        onSecondaryContainer: Color(0xFF3A1D00),
        tertiary: AppColors.clay,
        onTertiary: Colors.white,
        error: Color(0xFFB3261E),
        onError: Colors.white,
        surface: AppColors.grain,
        onSurface: Color(0xFF241F18),
        surfaceContainerHighest: Color(0xFFE9E2CF),
        outline: Color(0xFF7A7260),
      ));

  static ThemeData dark() => _build(const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF9CCB9F),
        onPrimary: Color(0xFF0D2915),
        primaryContainer: Color(0xFF244B30),
        onPrimaryContainer: Color(0xFFD7E6C6),
        secondary: Color(0xFFF4A460),
        onSecondary: Color(0xFF2B1706),
        secondaryContainer: Color(0xFF5A3410),
        onSecondaryContainer: Color(0xFFFFDDB8),
        tertiary: Color(0xFFE29A78),
        onTertiary: Color(0xFF2E1205),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        surface: Color(0xFF16201A),
        onSurface: Color(0xFFEDE8D8),
        surfaceContainerHighest: Color(0xFF26352B),
        outline: Color(0xFF9A9582),
      ));

  static ThemeData _build(ColorScheme s) {
    final base = ThemeData(colorScheme: s, useMaterial3: true);
    final isLight = s.brightness == Brightness.light;
    final tt = base.textTheme.copyWith(
      headlineSmall: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 18, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 16, height: 1.4),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ).apply(bodyColor: s.onSurface, displayColor: s.onSurface);
    return base.copyWith(
      textTheme: tt,
      scaffoldBackgroundColor: s.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.forest : s.primaryContainer,
        foregroundColor: isLight ? Colors.white : s.onPrimaryContainer,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            tt.titleLarge?.copyWith(color: isLight ? Colors.white : s.onPrimaryContainer),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: tt.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: tt.labelLarge,
          side: BorderSide(color: s.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.paper : s.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isLight ? AppColors.paper : const Color(0xFF1B2820),
        indicatorColor: s.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(tt.labelLarge?.copyWith(fontSize: 14)),
        iconTheme: WidgetStatePropertyAll(IconThemeData(size: 28, color: s.onSurface)),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12, minTileHeight: 56),
    );
  }
}

/// Terraced-field header: green slopes, curved furrows and a saffron sun.
class FieldPainter extends CustomPainter {
  final Color top, bottom, furrow, sun;
  const FieldPainter({required this.top, required this.bottom, required this.furrow, required this.sun});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom])
              .createShader(rect));
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.28), size.shortestSide * 0.2,
        Paint()..color = sun.withOpacity(0.95));
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.52 + i * 0.1);
      final amp = 10.0 + i * 3;
      final path = Path()..moveTo(0, y);
      path.cubicTo(size.width * 0.3, y - amp, size.width * 0.6, y + amp, size.width, y - amp * 0.5);
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 - i * 0.3
            ..color = furrow.withOpacity(0.18 + 0.1 * math.min(i, 3)));
    }
  }

  @override
  bool shouldRepaint(covariant FieldPainter old) => false;
}
