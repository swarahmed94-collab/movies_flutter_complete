import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(this.asset,{super.key,this.size=24,this.color=Colors.white});
  final String asset;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(asset,width:size.w,height:size.w,
    colorFilter: ColorFilter.mode(color,BlendMode.srcIn));
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key,required this.text,required this.onPressed,
    this.color=AppColors.accent,this.foreground=AppColors.onAccent,
    this.height=54,this.busy=false,this.outlined=false});
  final String text;
  final VoidCallback? onPressed;
  final Color color,foreground;
  final double height;
  final bool busy,outlined;
  @override
  Widget build(BuildContext context) => SizedBox(
    width:double.infinity,height:height.h,
    child:OutlinedButton(onPressed:busy?null:onPressed,
      style:OutlinedButton.styleFrom(
        padding:EdgeInsets.zero,foregroundColor:foreground,
        backgroundColor:outlined?Colors.transparent:color,
        side:BorderSide(color:color,width:outlined?1.5:0),
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15.r))),
      child:busy?SizedBox(height:20.w,width:20.w,child:CircularProgressIndicator(
        strokeWidth:2.5,color:foreground)):
        Text(AppStrings.text(context,text),style:TextStyle(fontSize:16.sp,fontWeight:FontWeight.w500,
          color:foreground))),
  );
}

class AppField extends StatelessWidget {
  const AppField({super.key,required this.controller,required this.hint,
    required this.icon,this.obscure=false,this.onToggleObscure,this.validator,
    this.keyboardType,this.onSubmitted,this.autofillHints});
  final TextEditingController controller;
  final String hint,icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller:controller,obscureText:obscure,validator:validator,
    keyboardType:keyboardType,onFieldSubmitted:onSubmitted,
    autofillHints:autofillHints,
    cursorColor:AppColors.accent,style:TextStyle(fontSize:16.sp,color:Colors.white),
    decoration:InputDecoration(
      hintText:AppStrings.text(context,hint),hintStyle:TextStyle(fontSize:16.sp,color:Colors.white),
      prefixIcon:Padding(padding:EdgeInsets.only(left:10.w,right:8.w),
        child:AppIcon(icon,size:28)),
      prefixIconConstraints:BoxConstraints(minWidth:47.w),
      suffixIcon:onToggleObscure==null?null:IconButton(
        onPressed:onToggleObscure,icon:AppIcon(
          obscure?'assets/icons/eye_off.svg':'assets/icons/eye.svg',size:28)),
      filled:true,fillColor:AppColors.surface,
      contentPadding:EdgeInsets.symmetric(horizontal:12.w,vertical:17.h),
      border:OutlineInputBorder(borderRadius:BorderRadius.circular(15.r),
        borderSide:BorderSide.none),
      enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15.r),
        borderSide:BorderSide.none),
      focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15.r),
        borderSide:const BorderSide(color:AppColors.accent,width:1)),
      errorBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15.r),
        borderSide:const BorderSide(color:AppColors.destructive,width:1)),
    ),
  );
}

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({super.key,required this.index,required this.size,this.onTap});
  final int index;
  final double size;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(onTap:onTap,
    child:ClipOval(child:Image.asset(AppAssets.avatar(index),
      width:size.w,height:size.w,fit:BoxFit.cover)));
}

class PosterImage extends StatelessWidget {
  const PosterImage({super.key,required this.url,this.fit=BoxFit.cover});
  final String url;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return const ColoredBox(color:AppColors.panel,
      child:Center(child:Icon(Icons.movie_outlined,color:Colors.white38)));
    return Image.network(url,fit:fit,width:double.infinity,height:double.infinity,
      errorBuilder:(_,__,___)=>const ColoredBox(color:AppColors.panel,
        child:Center(child:Icon(Icons.broken_image_outlined,color:Colors.white30))));
  }
}

class EmptyMovies extends StatelessWidget {
  const EmptyMovies({super.key,this.message});
  final String? message;
  @override
  Widget build(BuildContext context) => Center(child:Column(
    mainAxisSize:MainAxisSize.min,children:[
      Image.asset(AppAssets.emptyMovies,width:145.w,height:132.w,fit:BoxFit.contain),
      if (message!=null) ...[
        SizedBox(height:18.h),
        Text(AppStrings.text(context,message!),textAlign:TextAlign.center,style:TextStyle(color:Colors.white70,fontSize:14.sp)),
      ],
    ]));
}

class ErrorMovies extends StatelessWidget {
  const ErrorMovies({super.key,required this.message,required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child:Padding(
    padding:EdgeInsets.symmetric(horizontal:28.w),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text(AppStrings.text(context,message),textAlign:TextAlign.center,style:TextStyle(fontSize:14.sp,color:Colors.white70)),
      SizedBox(height:18.h),SizedBox(width:160.w,child:PrimaryButton(text:'Try Again',onPressed:onRetry)),
    ]),
  ));
}

void showAppError(BuildContext context,String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content:Text(message),backgroundColor:AppColors.surface,
    behavior:SnackBarBehavior.floating,
  ));
}
