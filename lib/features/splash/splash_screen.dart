import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final s = ref.read(settingsProvider);
      if (s.lang == null) {
        context.go('/language?first=1');
      } else if (!s.hasLocation) {
        context.go('/location?first=1');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        const CustomPaint(
            painter: FieldPainter(
                top: AppColors.forest, bottom: AppColors.moss, furrow: Colors.white, sun: AppColors.saffron)),
        SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(color: AppColors.paper, shape: BoxShape.circle),
                child: const Icon(Icons.landscape_rounded, size: 60, color: AppColors.forest),
              ),
              const SizedBox(height: 24),
              Text(l.appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontSize: 34)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(l.tagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white.withOpacity(0.92))),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
