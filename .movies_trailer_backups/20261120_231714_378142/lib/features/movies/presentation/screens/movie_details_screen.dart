import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/movie_poster.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../domain/entities/movie.dart';
import '../cubit/movie_details_cubit.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key,required this.movieId,this.initial});
  final int movieId;
  final Movie? initial;
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>getIt<MovieDetailsCubit>()..load(movieId),
    child:_MovieDetailsBody(movieId:movieId,initial:initial));
}
class _MovieDetailsBody extends StatelessWidget {
  const _MovieDetailsBody({required this.movieId,this.initial});
  final int movieId;
  final Movie? initial;
  @override
  Widget build(BuildContext context)=>BlocBuilder<MovieDetailsCubit,MovieDetailsState>(
    builder:(context,state){
      final movie=state.movie??initial;
      if(movie==null && state.status==DetailsStatus.failed){
        return Scaffold(body:ErrorMovies(message:state.failure?.message??'Could not load details',
          onRetry:()=>context.read<MovieDetailsCubit>().load(movieId)));
      }
      if(movie==null)return const Scaffold(body:Center(
        child:CircularProgressIndicator(color:AppColors.accent)));
      return Scaffold(body:CustomScrollView(slivers:[
        SliverToBoxAdapter(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          _hero(context,movie),
          Padding(padding:EdgeInsets.fromLTRB(16.w,10.h,16.w,40.h),child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
            _primaryDetails(context,movie),
            SizedBox(height:15.h),_stats(movie),
            if (movie.screenshots.isNotEmpty)...[
              SizedBox(height:21.h),_heading(context,'Screen Shots'),SizedBox(height:11.h),
              for(final url in movie.screenshots)...[
                ClipRRect(borderRadius:BorderRadius.circular(12.r),
                  child:SizedBox(width:double.infinity,height:167.h,
                    child:PosterImage(url:url))),
                SizedBox(height:10.h),
              ],
            ],
            if(state.suggestions.isNotEmpty)...[
              SizedBox(height:10.h),_heading(context,'Similar'),SizedBox(height:12.h),
              GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
                gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:2,crossAxisSpacing:12.w,mainAxisSpacing:12.h,
                  childAspectRatio:198/270),
                itemCount:state.suggestions.length,itemBuilder:(context,i){
                  final related=state.suggestions[i];
                  return MoviePoster(movie:related,width:198,height:270,
                    onTap:()=>Navigator.pushReplacementNamed(context,AppRouter.details,arguments:related));
                }),
            ],
            if(movie.description.trim().isNotEmpty)...[
              SizedBox(height:25.h),_heading(context,'Summary'),SizedBox(height:14.h),
              Text(movie.description,style:TextStyle(color:Colors.white,
                fontSize:14.sp,height:1.22)),
            ],
            if(movie.cast.isNotEmpty)...[
              SizedBox(height:25.h),_heading(context,'Cast'),SizedBox(height:10.h),
              for(final actor in movie.cast)...[
                _castTile(actor),SizedBox(height:6.h),
              ],
            ],
            if(movie.genres.isNotEmpty)...[
              SizedBox(height:24.h),_heading(context,'Genres'),SizedBox(height:13.h),
              Wrap(spacing:12.w,runSpacing:10.h,children:[
                for(final genre in movie.genres)Container(
                  constraints:BoxConstraints(minWidth:105.w),
                  padding:EdgeInsets.symmetric(horizontal:15.w,vertical:9.h),
                  decoration:BoxDecoration(color:AppColors.surface,
                    borderRadius:BorderRadius.circular(10.r)),
                  child:Text(genre,textAlign:TextAlign.center,
                    style:TextStyle(fontSize:13.sp,color:Colors.white))),
              ]),
            ],
          ])),
        ])),
      ]));
    });

  Widget _heading(BuildContext context,String s)=>Text(AppStrings.text(context,s),style:TextStyle(fontSize:20.sp,
    fontWeight:FontWeight.w700,color:Colors.white));

  Widget _hero(BuildContext context,Movie movie)=>SizedBox(height:424.h,
    child:Stack(fit:StackFit.expand,children:[
      PosterImage(url:movie.largeCover.isNotEmpty?movie.largeCover:movie.backgroundImage),
      const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(
        begin:Alignment.topCenter,end:Alignment.bottomCenter,
        colors:[Color(0x66000000),Colors.transparent,AppColors.background],
        stops:[0,.35,1]))),
      SafeArea(top:true,bottom:false,child:Align(alignment:Alignment.topCenter,
        child:Padding(padding:EdgeInsets.symmetric(horizontal:14.w,vertical:6.h),
          child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            IconButton(tooltip:'Back',onPressed:()=>Navigator.maybePop(context),
              icon:const AppIcon('assets/icons/back.svg',size:27)),
            BlocBuilder<LibraryCubit,LibraryState>(builder:(context,s)=>IconButton(
              onPressed:() async {
                final failure=await context.read<LibraryCubit>().toggleWatchlist(movie);
                if(context.mounted && failure!=null)showAppError(context,failure.message);
              },icon:AppIcon('assets/icons/bookmark.svg',size:29,
                color:s.includes(movie.id)?AppColors.accent:Colors.white))),
          ]))),
      ),
      Center(child:GestureDetector(onTap:()=>_watch(context,movie),
        child:Container(width:96.w,height:96.w,
          decoration:BoxDecoration(shape:BoxShape.circle,color:AppColors.accent,
            border:Border.all(color:Colors.white,width:6.w)),
          child:Center(child:Container(width:65.w,height:65.w,
            decoration:const BoxDecoration(shape:BoxShape.circle,color:Colors.white),
            child:Center(child:AppIcon('assets/icons/play.svg',size:28,
              color:AppColors.accent))))))),
    ]));

  Widget _primaryDetails(BuildContext context,Movie movie)=>Column(children:[
    Text(movie.title,textAlign:TextAlign.center,style:TextStyle(
      fontSize:19.sp,fontWeight:FontWeight.w700,height:1.16)),
    SizedBox(height:12.h),
    Text(movie.year>0?'${movie.year}':'',style:TextStyle(
      fontSize:16.sp,fontWeight:FontWeight.w700,color:Colors.white70)),
    SizedBox(height:12.h),
    /* MOVIES_UI_WATCH_BUTTON_V1 */
    SizedBox(width:double.infinity,height:58.h,
      child:ElevatedButton(
        onPressed:()=>_watch(context,movie),
        style:ElevatedButton.styleFrom(
          backgroundColor:AppColors.destructive,
          foregroundColor:Colors.white,
          padding:EdgeInsets.zero,
          elevation:0,
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15.r))),
        child:Text(AppStrings.text(context,'Watch'),
          style:TextStyle(fontSize:20.sp,fontWeight:FontWeight.w700)),
      )),
  ]);

  Widget _stats(Movie movie)=>Row(children:[
    _stat('assets/icons/heart.svg',movie.likeCount.toString()),
    SizedBox(width:10.w),
    _stat('assets/icons/clock.svg',movie.runtime>0?'${movie.runtime}':'—'),
    SizedBox(width:10.w),
    _stat('assets/icons/star.svg',movie.rating.toStringAsFixed(1)),
  ]);
  Widget _stat(String icon,String value)=>Expanded(child:Container(
    height:38.h,decoration:BoxDecoration(color:AppColors.surface,
      borderRadius:BorderRadius.circular(12.r)),
    child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
      AppIcon(icon,color:AppColors.accent,size:22),SizedBox(width:9.w),
      Text(value,style:TextStyle(fontSize:16.sp,fontWeight:FontWeight.w700)),
    ])));

  Widget _castTile(MovieActor actor)=>Container(
    constraints:BoxConstraints(minHeight:62.h),
    decoration:BoxDecoration(color:AppColors.surface,
      borderRadius:BorderRadius.circular(12.r)),
    padding:EdgeInsets.all(7.w),
    child:Row(children:[
      ClipRRect(borderRadius:BorderRadius.circular(9.r),
        child:SizedBox(width:48.w,height:48.w,child:PosterImage(url:actor.imageUrl))),
      SizedBox(width:9.w),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        children:[Text('Name : ${actor.name}',maxLines:1,overflow:TextOverflow.ellipsis,
            style:TextStyle(fontSize:15.sp)),
          if(actor.characterName.isNotEmpty)Padding(
            padding:EdgeInsets.only(top:6.h),child:Text('Character : ${actor.characterName}',
              style:TextStyle(fontSize:14.sp))),
        ])),
    ]));

  Future<void> _watch(BuildContext context,Movie movie) async {
    final code=movie.trailerCode.trim();
    if(code.isEmpty){showAppError(context,'No official trailer is available for this movie.');return;}
    final url=Uri.https('www.youtube.com','/watch',{'v':code});
    final success=await launchUrl(url,mode:LaunchMode.externalApplication);
    if(context.mounted){
      if(success){
        final failure=await context.read<LibraryCubit>().recordHistory(movie);
        if(context.mounted && failure!=null)showAppError(context,failure.message);
      } else {showAppError(context,'Could not open the trailer.');}
    }
  }
}
