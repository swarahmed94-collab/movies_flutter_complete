import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_config.dart';
import 'core/di/dependency_injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/library/presentation/cubit/library_cubit.dart';
import 'features/settings/presentation/cubit/language_cubit.dart';
import 'features/user_data/presentation/cubit/profile_cubit.dart';

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});
  @override
  Widget build(BuildContext context)=>ScreenUtilInit(
    designSize:AppConfig.designSize,minTextAdapt:true,splitScreenMode:true,
    builder:(_,child)=>MultiBlocProvider(providers:[
      BlocProvider<AuthCubit>(create:(_)=>getIt<AuthCubit>()),
      BlocProvider<LibraryCubit>(create:(_)=>getIt<LibraryCubit>()),
      BlocProvider<ProfileCubit>(create:(_)=>getIt<ProfileCubit>()),
      BlocProvider<LanguageCubit>(create:(_)=>getIt<LanguageCubit>()),
    ],child:BlocBuilder<LanguageCubit,String>(builder:(context,lang)=>MaterialApp(
      title:'Movies',debugShowCheckedModeBanner:false,
      theme:AppTheme.dark,locale:Locale(lang),
      supportedLocales:const [Locale('en'),Locale('ar')],
      localizationsDelegates:const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute:AppRouter.splash,onGenerateRoute:AppRouter.onGenerateRoute,
    ))),
  );
}
