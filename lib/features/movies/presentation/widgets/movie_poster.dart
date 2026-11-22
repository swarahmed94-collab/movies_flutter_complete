import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/movie.dart';

class MoviePoster extends StatelessWidget {
  const MoviePoster({super.key,required this.movie,required this.onTap,
    this.width=152,this.height=218,this.showRating=true});
  final Movie movie;
  final VoidCallback onTap;
  final double width,height;
  final bool showRating;
  @override
  Widget build(BuildContext context) => GestureDetector(onTap:onTap,
    child:SizedBox(width:width.w,height:height.h,
      child:ClipRRect(borderRadius:BorderRadius.circular(13.r),
        child:Stack(fit:StackFit.expand,children:[
          PosterImage(url:movie.largeCover.isNotEmpty?movie.largeCover:movie.mediumCover),
          if (showRating && movie.rating>0)
            Positioned(left:6.w,top:7.h,child:Container(
              padding:EdgeInsets.symmetric(horizontal:8.w,vertical:5.h),
              decoration:BoxDecoration(color:const Color(0xDD343434),
                borderRadius:BorderRadius.circular(12.r)),
              child:Row(mainAxisSize:MainAxisSize.min,children:[
                Text(movie.rating.toStringAsFixed(1),style:TextStyle(fontSize:12.sp,color:Colors.white)),
                SizedBox(width:4.w),AppIcon('assets/icons/star.svg',size:16,color:AppColors.accent),
              ]))),
        ]))),
    );
}

