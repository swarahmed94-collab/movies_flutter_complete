import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../user_data/presentation/cubit/profile_cubit.dart';
import '../../../movies/presentation/screens/browse_tab.dart';
import '../../../movies/presentation/screens/home_tab.dart';
import '../../../movies/presentation/screens/search_tab.dart';
import '../../../profile/presentation/screens/profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState()=>_AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index=0;
  String browseGenre='Action';
  void showBrowse(String genre){setState(() {browseGenre=genre;index=2;});}
  @override
  void initState(){super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!mounted)return;
      final uid=context.read<AuthCubit>().state.user?.uid;
      context.read<LibraryCubit>().bindUser(uid);
      context.read<ProfileCubit>().bindUser(uid);
    });
  }
  @override
  Widget build(BuildContext context)=>BlocListener<AuthCubit,AuthState>(
    listener:(context,state){
      if(state.status==AuthStatus.signedIn || state.status==AuthStatus.signedOut){
        context.read<LibraryCubit>().bindUser(state.user?.uid);
        context.read<ProfileCubit>().bindUser(state.user?.uid);
      }
    },child:Scaffold(
      // MOVIES_UI_FULL_BLEED_V1: the content fills the viewport; navigation floats over it.
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(children: [
        Positioned.fill(child:IndexedStack(index:index,children:[
          HomeTab(onBrowseGenre:showBrowse),
          Padding(padding:EdgeInsets.only(bottom:84.h),child:const SearchTab()),
          Padding(padding:EdgeInsets.only(bottom:84.h),
            child:BrowseTab(key:ValueKey(browseGenre),initialGenre:browseGenre)),
          Padding(padding:EdgeInsets.only(bottom:84.h),child:const ProfileTab()),
        ])),
        Positioned(
          // MOVIES_FIGMA_NAV_PRECISION_V2: float close to the bottom, above the gesture handle.
          left: 9.w,
          right: 9.w,
          bottom: 8.h + MediaQuery.of(context).padding.bottom * 0.15,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15.r),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 58.h,
              child: Row(children: [
                _item(0, AppAssets.homeIcon),
                _item(1, AppAssets.searchIcon),
                _item(2, AppAssets.browseIcon),
                _item(3, AppAssets.profileIcon),
              ]),
            ),
          ),
        ),
      ]),
    ));
    Widget _item(int i,String icon)=>Expanded(child:Semantics(
    label:['Home','Search','Browse','Profile'][i],
    button:true,child:InkWell(onTap:()=>setState(()=>index=i),
      child:Center(child:AppIcon(icon,color:index==i?AppColors.accent:Colors.white,
        size:25))),
  ));
}
