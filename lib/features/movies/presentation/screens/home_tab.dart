import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/movie_poster.dart';
import '../../domain/entities/movie.dart';
import '../cubit/home_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key,required this.onBrowseGenre});
  final ValueChanged<String> onBrowseGenre;
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>getIt<HomeCubit>()..load(),
    child:_HomeBody(onBrowseGenre:onBrowseGenre));
}
class _HomeBody extends StatefulWidget {
  const _HomeBody({required this.onBrowseGenre});
  final ValueChanged<String> onBrowseGenre;
  @override
  State<_HomeBody> createState()=>_HomeBodyState();
}
class _HomeBodyState extends State<_HomeBody> {
  final PageController _page=PageController(viewportFraction:.59);
  int focused=0;
  @override
  void dispose(){_page.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>BlocBuilder<HomeCubit,HomeState>(
    builder:(context,state){
      if(state.status==HomeStatus.initial || state.status==HomeStatus.loading){
        return const Center(child:CircularProgressIndicator(color:AppColors.accent));
      }
      if(state.status==HomeStatus.failed)return ErrorMovies(
        message:state.failure?.message??'Cannot load movies',
        onRetry:()=>context.read<HomeCubit>().load());
      return Stack(fit:StackFit.expand,children:[
        // MOVIES_UI_FULL_BLEED_HERO_V1
        Positioned.fill(child:state.featured.isEmpty
          ? const ColoredBox(color:AppColors.background)
          : Opacity(opacity:.12,child:PosterImage(
              url:state.featured[focused.clamp(0,state.featured.length-1).toInt()].backgroundImage))),
        const Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
          gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,
            colors:[Color(0x99121312),AppColors.background])))),
        SafeArea(top:true,bottom:false,child:RefreshIndicator(color:AppColors.accent,
        onRefresh:()=>context.read<HomeCubit>().load(),
        child:CustomScrollView(physics:const AlwaysScrollableScrollPhysics(),slivers:[
          SliverToBoxAdapter(child:Stack(children:[
            Container(decoration:const BoxDecoration(gradient:LinearGradient(
              colors:[Colors.transparent,AppColors.background],
              begin:Alignment.topCenter,end:Alignment.bottomCenter)),
              child:Column(children:[
                Padding(
                  padding:EdgeInsets.fromLTRB(52.w,13.h,52.w,10.h),
                  child:Image.asset(AppAssets.availableNow,width:326.w,height:89.h,
                    fit:BoxFit.contain)),
                if(state.featured.isNotEmpty)SizedBox(height:357.h,
                  child:PageView.builder(controller:_page,
                    itemCount:state.featured.length,
                    onPageChanged:(v)=>setState(()=>focused=v),
                    itemBuilder:(context,i){
                      final movie=state.featured[i];
                      return AnimatedPadding(duration:const Duration(milliseconds:170),
                        padding:EdgeInsets.symmetric(horizontal:9.w,
                          vertical:i==focused?0:34.h),
                        child:MoviePoster(movie:movie,width:242,height:340,
                          onTap:()=>Navigator.pushNamed(context,AppRouter.details,arguments:movie)));
                    })),
                SizedBox(height:18.h),
                Image.asset(AppAssets.watchNow,width:365.w,height:130.h,fit:BoxFit.contain),
              ]),
            ),
          ])),
          _section('Action',state.action),
          _section('Adventure',state.adventure),
          _section('Animation',state.animation),
          SliverToBoxAdapter(child:SizedBox(height:108.h)),
        ]),
      ))]);
    });
  Widget _section(String genre,List<Movie> movies)=>SliverToBoxAdapter(
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:EdgeInsets.fromLTRB(16.w,14.h,16.w,9.h),
        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text(AppStrings.text(context,genre),style:TextStyle(color:Colors.white,fontSize:20.sp)),
          TextButton(onPressed:()=>widget.onBrowseGenre(genre),
            child:Text(AppStrings.text(context,'See More →'),style:TextStyle(color:AppColors.accent,fontSize:13.sp))),
        ])),
      SizedBox(height:218.h,child:movies.isEmpty
        ?Padding(padding:EdgeInsets.only(left:16.w),child:Text(AppStrings.text(context,'No movies available'),
            style:TextStyle(color:Colors.white60,fontSize:14.sp)))
        :ListView.separated(scrollDirection:Axis.horizontal,
          padding:EdgeInsets.symmetric(horizontal:16.w),
          itemCount:movies.length,separatorBuilder:(_,__)=>SizedBox(width:11.w),
          itemBuilder:(context,i)=>MoviePoster(movie:movies[i],width:148,height:218,
            onTap:()=>Navigator.pushNamed(context,AppRouter.details,arguments:movies[i])))),
      SizedBox(height:8.h),
    ]));
}
