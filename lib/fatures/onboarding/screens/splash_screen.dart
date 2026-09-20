
import 'dart:async';
import 'package:albayan/fatures/auth/screens/login_screen.dart';
import 'package:albayan/fatures/main/screens/main_screen.dart';
import 'package:albayan/fatures/onboarding/screens/select_language_screen.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      final bool hasLaunchedBefore = SharedPrefHelper.hasLaunchedBefore();

      // First install ever → language selection screen.
      if (!hasLaunchedBefore) {
        SharedPrefHelper.setLaunchedBefore();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      // Not the first launch → route by login state.
      final bool isLoggedIn = SharedPrefHelper.isLoggedIn();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const MainScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(AppImages.splash, fit: BoxFit.contain,),
      ),
    );
  }
}