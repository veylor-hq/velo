import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Stark brutalist splash regardless of theme
      body: Center(
        child: const Text(
          'VELO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: 15,
          ),
        ).animate()
         .fadeIn(duration: 800.ms, curve: Curves.easeOut)
         .scaleXY(begin: 0.95, end: 1.0, duration: 1000.ms, curve: Curves.easeOutQuart)
         .then(delay: 200.ms)
         .slideY(end: 0.05, duration: 400.ms, curve: Curves.easeIn)
         .fadeOut(duration: 400.ms),
      ),
    );
  }
}
