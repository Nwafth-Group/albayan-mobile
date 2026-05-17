// ============================================
// FILE: lib/utils/constants.dart  (updated)
// ============================================

import 'package:flutter/material.dart';

// API Constants
class ApiConstants {
  static String get baseUrl => 'http://3.68.184.228/api/v1';
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Auth Endpoints
  static const String login    = '/owner/auth/login';
  static const String register = '/owner/auth/register';
  static const String verifyOtp = '/owner/auth/verify-otp';
  static const String resendOtp = '/owner/auth/resend-otp';
}

// App Colors
class AppColors {
  // Primary Colors (Maroon/Wine palette)
  static const Color primary      = Color(0xFF82003C);
  static const Color primaryLight = Color(0xFFA61B57);
  static const Color primaryDark  = Color(0xFF5C002A);

  // Accent Colors (Terracotta/Peach palette)
  static const Color accent      = Color(0xFFF0785A);
  static const Color accentLight = Color(0xFFF59B85);
  static const Color accentPale  = Color(0xFFFDE1D9);

  // Text Colors
  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight     = Color(0xFF9CA3AF);

  // Background & Card Colors
  static const Color background    = Color(0xFFFFFCF9);
  static const Color cardColor     = Color(0xFFFFF5EB);
  static const Color surface       = Color(0xFFFDF0E6);
  static const Color surfaceVariant= Color(0xFFF1E4D8);
  static const Color surfaceDark   = Color(0xFFFAE9DC);

  // Functional
  static const Color white   = Color(0xFFFFFFFF);
  static const Color error   = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
}

// App Images
class AppImages {
  static const String logo       = 'assets/images/logo.png';
  static const String splash       = 'assets/images/splash.png';
  static const String appleIcon  = 'assets/icons/apple.png';
  static const String googleIcon = 'assets/icons/google.png';
  static const String guestIcon  = 'assets/icons/guest.png';
  static const String successIllustration = 'assets/images/success.png';

  static const String onboarding1       = 'assets/images/onboarding1.png';
  static const String onboarding2       = 'assets/images/onboarding2.png';
  static const String onboarding3       = 'assets/images/onboarding3.png';
  static const String onboardingLogo       = 'assets/images/onboardingLogo2.png';
}

// App Dimensions
class AppDimensions {
  static const double paddingxSmall = 3.0;
  static const double paddingSmall  = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge  = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSizeSmall  = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge  = 32.0;

  static const double fontSizeSmall   = 12.0;
  static const double fontSizeMedium  = 14.0;
  static const double fontSizeLarge   = 16.0;
  static const double fontSizeXLarge  = 20.0;
  static const double fontSizeXXLarge = 24.0;
}

// Storage Keys
class StorageKeys {
  static const String token        = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId       = 'user_id';
  static const String userEmail    = 'user_email';
  static const String userName     = 'user_name';
  static const String isLoggedIn   = 'is_logged_in';
  static const String fcmToken     = 'fcm_token';
  static const String isAdmin      = 'is_admin';
}

String lng = 'en';

class AppStrings {
  // ── Onboarding ────────────────────────────────────────────
  static const String onboarding1Title    = 'onboarding_1_title';
  static const String onboarding1Subtitle = 'onboarding_1_subtitle';
  static const String onboarding2Title    = 'onboarding_2_title';
  static const String onboarding2Subtitle = 'onboarding_2_subtitle';
  static const String onboarding3Title    = 'onboarding_3_title';
  static const String onboarding3Subtitle = 'onboarding_3_subtitle';
  static const String onboardingSkip      = 'onboarding_skip';
  static const String onboardingGetStarted= 'onboarding_get_started';

  // ── Shared tabs ───────────────────────────────────────────
  static const String tabEmail  = 'tab_email';
  static const String tabMobile = 'tab_mobile';

  // ── Login ─────────────────────────────────────────────────
  static const String loginTitle     = 'login_title';
  static const String loginSubtitle  = 'login_subtitle';
  static const String rememberMe     = 'remember_me';
  static const String forgotPassword = 'forgot_password';
  static const String btnLogin       = 'btn_login';
  static const String noAccount      = 'no_account';
  static const String signUp         = 'sign_up';

  // ── Register ──────────────────────────────────────────────
  static const String registerTitle    = 'register_title';
  static const String registerSubtitle = 'register_subtitle';
  static const String btnSignUp        = 'btn_sign_up';
  static const String orSignUpWith     = 'or_sign_up_with';
  static const String agreeToTerms     = 'agree_to_terms';

  // ── Forgot Password ───────────────────────────────────────
  static const String forgotPasswordTitle    = 'forgot_password_title';
  static const String forgotPasswordSubtitle = 'forgot_password_subtitle';
  static const String btnContinue            = 'btn_continue';

  // ── Reset Password ────────────────────────────────────────
  static const String resetPasswordTitle    = 'reset_password_title';
  static const String resetPasswordSubtitle = 'reset_password_subtitle';
  static const String btnSave               = 'btn_save';

  // ── Shared fields ─────────────────────────────────────────
  static const String labelFirstName       = 'label_first_name';
  static const String hintFirstName        = 'hint_first_name';
  static const String labelLastName        = 'label_last_name';
  static const String hintLastName         = 'hint_last_name';
  static const String labelEmail           = 'label_email';
  static const String hintEmail            = 'hint_email';
  static const String labelPassword        = 'label_password';
  static const String hintPassword         = 'hint_password';
  static const String labelConfirmPassword = 'label_confirm_password';
  static const String hintConfirmPassword  = 'hint_confirm_password';
  static const String labelCountry         = 'label_country';
  static const String hintCountry          = 'hint_country';
  static const String labelMobilePhone     = 'label_mobile_phone';
  static const String hintMobilePhone      = 'hint_mobile_phone';

  // ── Social / Guest ────────────────────────────────────────
  static const String orContinueWith     = 'or_continue_with';
  static const String continueWithApple  = 'continue_with_apple';
  static const String continueWithGoogle = 'continue_with_google';
  static const String continueAsGuest    = 'continue_as_guest';

  // ── OTP ───────────────────────────────────────────────────
  static const String otpTitle     = 'otp_title';
  static const String otpSubtitle  = 'otp_subtitle';
  static const String otpCodeSent  = 'otp_code_sent';
  static const String otpResend    = 'otp_resend';
  static const String otpResendNow = 'otp_resend_now';
  static const String btnSubmit    = 'btn_submit';

  // ── Terms ─────────────────────────────────────────────────
  static const String termsTitle        = 'terms_title';
  static const String termsClause1Title = 'terms_clause_1_title';
  static const String termsClause1Body  = 'terms_clause_1_body';
  static const String termsClause2Title = 'terms_clause_2_title';
  static const String termsClause2Body  = 'terms_clause_2_body';
  static const String termsClause3Title = 'terms_clause_3_title';
  static const String termsClause3Body  = 'terms_clause_3_body';
  static const String termsClause4Title = 'terms_clause_4_title';
  static const String termsClause4Body  = 'terms_clause_4_body';
  static const String btnDone           = 'btn_done';

  // ── Success ───────────────────────────────────────────────
  static const String successTitle    = 'success_title';
  static const String successSubtitle = 'success_subtitle';

  // ── Validation ────────────────────────────────────────────
  static const String validationEmailRequired           = 'validation_email_required';
  static const String validationEmailInvalid            = 'validation_email_invalid';
  static const String validationPasswordRequired        = 'validation_password_required';
  static const String validationPasswordMin             = 'validation_password_min';
  static const String validationConfirmPasswordRequired = 'validation_confirm_password_required';
  static const String validationPasswordMismatch        = 'validation_password_mismatch';
  static const String validationPhoneRequired           = 'validation_phone_required';
  static const String validationPhoneInvalid            = 'validation_phone_invalid';
  static const String validationFirstNameRequired       = 'validation_first_name_required';
  static const String validationLastNameRequired        = 'validation_last_name_required';
  static const String validationCountryRequired         = 'validation_country_required';
  static const String validationAgreeTerms              = 'validation_agree_terms';
  static const String validationOtpRequired             = 'validation_otp_required';
}