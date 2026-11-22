import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../movies/presentation/widgets/movie_poster.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../user_data/presentation/cubit/profile_cubit.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState()=>_ProfileTabState();
}
class _ProfileTabState extends State<ProfileTab> {
  bool history=false;
  bool _didLeave=false;
  @override
  Widget build(BuildContext context)=>BlocListener<AuthCubit,AuthState>(
    listener:(context,state){
      if(state.status==AuthStatus.signedOut && !_didLeave){
        _didLeave=true;
        Navigator.pushNamedAndRemoveUntil(context,AppRouter.login,(_)=>false);
      } else if(state.status==AuthStatus.failed && state.failure!=null){
        showAppError(context,state.failure!.message);
      }
    },child:SafeArea(bottom:false,child:Column(children:[
      SizedBox(height:8.h),
      BlocBuilder<ProfileCubit,ProfileState>(builder:(context,profile)=>
        BlocBuilder<AuthCubit,AuthState>(builder:(context,auth)=>
          BlocBuilder<LibraryCubit,LibraryState>(builder:(context,library){
            final user=auth.user;
            final name=profile.document?['displayName'] is String
                ?profile.document!['displayName'] as String
                :user?.displayName??user?.email??'';
            return Container(
              color:AppColors.panel,padding:EdgeInsets.fromLTRB(16.w,20.h,16.w,8.h),
              child:Column(children:[
                Row(mainAxisAlignment:MainAxisAlignment.spaceAround,
                  crossAxisAlignment:CrossAxisAlignment.center,children:[
                    Column(children:[
                      AvatarCircle(index:profile.avatar,size:114),
                      SizedBox(height:12.h),Text(name,
                        style:TextStyle(fontSize:19.sp,fontWeight:FontWeight.w700)),
                    ]),
                    _count(library.watchlist.length,'Wish List'),
                    _count(library.history.length,'History'),
                  ]),
                SizedBox(height:22.h),
                Row(children:[
                  Expanded(flex:2,child:PrimaryButton(text:'Edit Profile',
                    onPressed:()=>Navigator.pushNamed(context,AppRouter.editProfile))),
                  SizedBox(width:10.w),
                  Expanded(child:PrimaryButton(text:'Exit',color:AppColors.destructive,
                    foreground:Colors.white,onPressed:()=>context.read<AuthCubit>().logout())),
                ]),
                SizedBox(height:20.h),
                Row(children:[
                  _tab('Watch List','assets/icons/list.svg',false),
                  _tab('History','assets/icons/folder.svg',true),
                ]),
              ]),
            );
          })) ),
      Expanded(child:BlocBuilder<LibraryCubit,LibraryState>(builder:(context,state){
        final items=history?state.history:state.watchlist;
        if(state.failure!=null && items.isEmpty)return ErrorMovies(
          message:state.failure!.message,
          onRetry:()=>context.read<LibraryCubit>().bindUser(state.uid,force:true));
        if(items.isEmpty)return const EmptyMovies();
        return GridView.builder(padding:EdgeInsets.fromLTRB(16.w,18.h,16.w,18.h),
          gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:3,crossAxisSpacing:10.w,mainAxisSpacing:13.h,
            childAspectRatio:120/190),
          itemCount:items.length,itemBuilder:(context,i){
            final movie=items[i];
            return MoviePoster(movie:movie,width:120,height:190,
              onTap:()=>Navigator.pushNamed(context,AppRouter.details,arguments:movie));
          });
      })),
    ])));
  Widget _count(int number,String label)=>Column(children:[
    Text('$number',style:TextStyle(fontSize:31.sp,fontWeight:FontWeight.w700)),
    SizedBox(height:18.h),
    Text(AppStrings.text(context,label),style:TextStyle(fontSize:19.sp,fontWeight:FontWeight.w700)),
  ]);
  Widget _tab(String label,String icon,bool isHistory)=>Expanded(child:GestureDetector(
    onTap:()=>setState(()=>history=isHistory),
    child:Container(height:86.h,decoration:BoxDecoration(border:Border(bottom:BorderSide(
      width:2,color:history==isHistory?AppColors.accent:Colors.transparent))),
      child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        AppIcon(icon,color:AppColors.accent,size:31),SizedBox(height:5.h),
        Text(AppStrings.text(context,label),style:TextStyle(fontSize:18.sp)),
      ]),
    ),
  ));
}
