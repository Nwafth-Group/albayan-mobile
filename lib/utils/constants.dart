import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Constants
class ApiConstants {

  static String get baseUrl =>'http://3.68.184.228/api/v1';

  static final navigatorKey = GlobalKey<NavigatorState>();

  // Auth Endpoints
  static const String login = '/owner/auth/login';

}

// App Colors
class AppColors {
  // Primary Colors (Maroon/Wine palette)
  static const Color primary = Color(0xFF82003C);
  static const Color primaryLight = Color(0xFFA61B57);
  static const Color primaryDark = Color(0xFF5C002A);

  // Accent Colors (Terracotta/Peach palette)
  static const Color accent = Color(0xFFF0785A);
  static const Color accentLight = Color(0xFFF59B85);
  static const Color accentPale = Color(0xFFFDE1D9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Background & Card Colors (Neutral creams)
  static const Color background = Color(0xFFFFFCF9);
  static const Color cardColor = Color(0xFFFFF5EB);
  static const Color surface = Color(0xFFFDF0E6);
  static const Color surfaceVariant = Color(0xFFF1E4D8);
  static const Color surfaceDark = Color(0xFFFAE9DC);

  // Functional Colors (Standard defaults if not specified in image)
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
}

class AppImages {
  static String homeIcon = 'assets/icons/home.svg';
}

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingxSmall = 3.0;

  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
}

// Storage Keys
class StorageKeys {
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String fcmToken = 'fcm_token';
  static const String isAdmin = 'is_admin';
}

String lng = 'en';

class AppStrings {
  static const String createNewAccount = 'Create New Account';

}
