import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_logo_widget.dart';
import '../providers/app_providers.dart';
import 'main_navigation_view.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  void _navigateAfterSplash() {
    final authAsync = ref.read(authStateProvider);
    User? user;
    if (authAsync.hasValue) {
      user = authAsync.value;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const MainNavigationView() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.headerGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
                child: const AppLogoWidget(size: 140),
              ),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _fadeAnim,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: child,
                ),
                child: Column(
                  children: [
                    Text(
                      'altarDiario',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu hábito diario con Dios',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
