import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/movies/domain/entities/movie.dart';
import '../../features/movies/presentation/screens/movie_details_screen.dart';
import '../../features/navigation/presentation/screens/app_shell.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

abstract final class AppRouter {
  static const splash='/';
  static const onboarding='/onboarding';
  static const login='/login';
  static const register='/register';
  static const forgotPassword='/forgot-password';
  static const shell='/app';
  static const details='/movie';
  static const editProfile='/edit-profile';
  static Route<dynamic> onGenerateRoute(RouteSettings settings){
    final page=switch(settings.name){
      splash=>const SplashScreen(),
      onboarding=>const OnboardingScreen(),
      login=>const LoginScreen(),
      register=>const RegisterScreen(),
      forgotPassword=>const ForgotPasswordScreen(),
      shell=>const AppShell(),
      editProfile=>const EditProfileScreen(),
      details=>_details(settings.arguments),
      _=>throw FlutterError('Unregistered route: ${settings.name}'),
    };
    return MaterialPageRoute<void>(settings:settings,builder:(_)=>page);
  }
  static Widget _details(Object? args){
    if(args is Movie)return MovieDetailsScreen(movieId:args.id,initial:args);
    if(args is int && args>0)return MovieDetailsScreen(movieId:args);
    throw FlutterError('Movie Details requires a valid Movie or movieId.');
  }
}
