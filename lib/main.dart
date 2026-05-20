import 'package:albayan/fatures/auth/screens/login_screen.dart';
import 'package:albayan/fatures/onboarding/screens/splash_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // ── Initialize SharedPreferences before runApp ────────────────
  final prefs = await SharedPreferences.getInstance();
  SharedPrefHelper.init(prefs);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albayan',
      debugShowCheckedModeBanner: false,

      navigatorKey: AppNavigator.navigatorKey,

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        fontFamily: 'Rubik',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}