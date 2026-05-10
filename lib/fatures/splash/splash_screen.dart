import 'package:albayan/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/app_navigator.dart';
import '../../utils/constants.dart';
import '../auth/screens/cubit/cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<AuthCubit>().checkAuthStatus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          Future.delayed(const Duration(seconds: 2), () {
            if(state is AuthSuccess){
              // context.read<ProfileCubit>().loadProfile();
              // AppNavigator.pushAndRemoveUntil(MainScreen());
            }
            else {
              // AppNavigator.pushAndRemoveUntil(WelcomeScreen());
            }
          });

        },
        child: Center(
          child: ImageAsset(AppImages.logoSplash, height: 200, width: 200)
        ),
      ),
    );
  }
}
