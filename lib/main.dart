import 'package:albayan/utils/app_navigator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'fatures/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Alaqd Al-Amin',
    debugShowCheckedModeBanner: false,
    navigatorKey: AppNavigator.navigatorKey,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    theme: ThemeData(
    primarySwatch: Colors.teal,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: Colors.grey.shade50,
    ),
    home: const SplashScreen(),
    );
  }
}
