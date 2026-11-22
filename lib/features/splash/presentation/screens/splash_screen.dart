import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/startup_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>StartupCubit(getIt(),getIt())..decide(),
    child:BlocListener<StartupCubit,StartupDestination>(
      listener:(context,destination){
        final route=switch(destination){
          StartupDestination.onboarding=>AppRouter.onboarding,
          StartupDestination.login=>AppRouter.login,
          StartupDestination.app=>AppRouter.shell,
          StartupDestination.initial=>null,
        };
        if(route!=null) Navigator.pushNamedAndRemoveUntil(context,route,(_)=>false);
      },child:Scaffold(backgroundColor:AppColors.background,
      body:SafeArea(child:Stack(alignment:Alignment.center,children:[
        Center(child:Image.asset(AppAssets.brandSymbolRaster,width:140.w)),
        Positioned(bottom:20.h,child:Image.asset(AppAssets.splashFooterRaster,width:220.w)),
      ]))),
    ));
}
