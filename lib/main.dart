import 'package:albayan/fatures/onboarding/screens/splash_screen.dart';
import 'package:albayan/utils/app_navigator.dart';
import 'package:albayan/utils/constants.dart';
import 'package:albayan/utils/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // ── Initialize SharedPreferences before runApp ────────────────
  final prefs = await SharedPreferences.getInstance();
  SharedPrefHelper.init(prefs);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Restore the cached language (onboarding / settings) ───────
  const supportedLocales = [Locale('en'), Locale('ar')];
  final savedLng = await SharedPrefHelper.getLng();
  final startLocale = supportedLocales
      .where((l) => l.languageCode == savedLng)
      .firstOrNull;
  if (startLocale != null) lang = startLocale.languageCode;

  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      // Null on first launch → device language, else the fallback.
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilt whenever the locale changes, so the API's Accept-Language
    // header always matches the app language (incl. the one restored on launch).
    lang = context.locale.languageCode;

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