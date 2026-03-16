import 'package:flutter/material.dart';
import '../../core/config/app_router.dart';
import '../auth/data/supabase_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _opacityController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation controller - shrinks the logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Opacity animation controller - fades out the splash
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation - logo grows then shrinks
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Opacity animation - fade out after scale completes
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _opacityController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animations
    _scaleController.forward().then((_) {
      _opacityController.forward().then((_) {
        if (mounted) {
          _routeUser();
        }
      });
    });
  }

  Future<void> _routeUser() async {
    final hasSession = SupabaseAuthService.currentUser != null;
    if (!hasSession) {
      _goTo(AppRouter.login);
      return;
    }

    try {
      final role = await SupabaseAuthService.determineUserRole().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;

      if (role == 'admin') {
        _goTo(AppRouter.adminHome);
        return;
      }

      _goTo(AppRouter.studentHome);
    } catch (_) {
      try {
        await SupabaseAuthService.signOut();
      } catch (_) {}

      if (!mounted) return;
      _goTo(AppRouter.login);
    }
  }

  void _goTo(String routeName) {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(routeName);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF003DA5), // Royal Blue
        ),
        child: Stack(
          children: [
            // Animated opacity wrapper for fade out effect
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 12),
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('assets/logos/vouch_logo.png', fit: BoxFit.cover),
    );
  }
}
