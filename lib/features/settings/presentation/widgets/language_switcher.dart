import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/language_cubit.dart';
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});
  @override
  Widget build(BuildContext context)=>BlocBuilder<LanguageCubit,String>(
    builder:(context,lang)=>Center(child:Container(
      height:39.h,padding:EdgeInsets.symmetric(horizontal:5.w,vertical:3.h),
      decoration:BoxDecoration(border:Border.all(color:AppColors.accent,width:2),
        borderRadius:BorderRadius.circular(40.r)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        _flag(context,'🇺🇸','en',lang=='en'),
        Container(height:25.h,width:1,color:AppColors.accent),
        _flag(context,'🇪🇬','ar',lang=='ar'),
      ]),
    )));
  Widget _flag(BuildContext context,String emoji,String lang,bool selected)=>
      GestureDetector(onTap:()=>context.read<LanguageCubit>().select(lang),
        child:Container(width:36.w,height:32.h,alignment:Alignment.center,
          decoration:BoxDecoration(color:selected?Colors.white10:Colors.transparent,
            borderRadius:BorderRadius.circular(30.r)),
          child:Text(emoji,style:TextStyle(fontSize:24.sp))));
}
