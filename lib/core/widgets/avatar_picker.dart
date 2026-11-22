import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'app_widgets.dart';

/// The 9 portraits are cropped from the supplied avatar selector PNG.
Future<int?> showAvatarPicker(BuildContext context,int current) => showModalBottomSheet<int>(
  context:context,isScrollControlled:true,backgroundColor:Colors.transparent,
  builder:(context)=>SafeArea(top:false,child:Container(
    margin:EdgeInsets.symmetric(horizontal:16.w,vertical:14.h),
    padding:EdgeInsets.all(18.w),
    decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(23.r)),
    child:GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:3,crossAxisSpacing:16.w,mainAxisSpacing:16.h),
      itemCount:9,itemBuilder:(context,index)=>GestureDetector(
        onTap:()=>Navigator.pop(context,index),
        child:Container(
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(18.r),
            border:Border.all(color:AppColors.accent,width:1.3),
            color:current==index?AppColors.accent.withValues(alpha:.2):AppColors.panel),
          padding:EdgeInsets.all(7.w),child:AvatarCircle(index:index,size:76)),
      )),
  )));
