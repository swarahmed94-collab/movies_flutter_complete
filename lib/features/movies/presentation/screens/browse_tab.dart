import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/movie_poster.dart';
import '../../domain/entities/movie.dart';
import '../cubit/movie_list_cubit.dart';

class BrowseTab extends StatelessWidget {
  const BrowseTab({super.key,this.initialGenre='Action'});
  final String initialGenre;
  static const genres=['Action','Adventure','Animation','Biography','Comedy','Crime',
    'Documentary','Drama','Family','Fantasy','Horror','Music','Mystery',
    'Romance','Sci-Fi','Sport','Thriller','War','Western'];
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>getIt<MovieListCubit>()..load(MovieQuery(genre:initialGenre,
      limit:20,sortBy:'rating')),
    child:_BrowseBody(initialGenre:initialGenre));
}
class _BrowseBody extends StatefulWidget {
  const _BrowseBody({required this.initialGenre});
  final String initialGenre;
  @override
  State<_BrowseBody> createState()=>_BrowseBodyState();
}
class _BrowseBodyState extends State<_BrowseBody> {
  late String _selected;
  final ScrollController _controller=ScrollController();
  @override
  void initState(){super.initState();_selected=widget.initialGenre;
    _controller.addListener((){
      if(_controller.hasClients && _controller.position.extentAfter<400){
        context.read<MovieListCubit>().nextPage();
      }
    });
  }
  @override
  void dispose(){_controller.dispose();super.dispose();}
  void _select(String genre){
    if(_selected==genre)return;
    setState(()=>_selected=genre);
    context.read<MovieListCubit>().load(MovieQuery(genre:genre,limit:20,sortBy:'rating'));
  }
  @override
  Widget build(BuildContext context)=>SafeArea(top:true,bottom:false,child:Column(children:[
    SizedBox(height:10.h),
    SizedBox(height:40.h,child:ListView.separated(
      scrollDirection:Axis.horizontal,
      padding:EdgeInsets.symmetric(horizontal:16.w),
      itemCount:BrowseTab.genres.length,separatorBuilder:(_,__)=>SizedBox(width:7.w),
      itemBuilder:(context,i){
        final genre=BrowseTab.genres[i];final active=genre==_selected;
        return InkWell(onTap:()=>_select(genre),child:Container(
          alignment:Alignment.center,padding:EdgeInsets.symmetric(horizontal:15.w),
          decoration:BoxDecoration(
            color:active?AppColors.accent:Colors.transparent,
            borderRadius:BorderRadius.circular(12.r),
            border:Border.all(color:AppColors.accent,width:1.5)),
          child:Text(AppStrings.text(context,genre),style:TextStyle(fontWeight:FontWeight.w600,
            color:active?AppColors.onAccent:AppColors.accent,fontSize:14.sp)),
        ));
      })),
    SizedBox(height:12.h),
    Expanded(child:BlocBuilder<MovieListCubit,MovieListState>(builder:(context,state){
      if(state.status==MovieListStatus.loading || state.status==MovieListStatus.initial){
        return const Center(child:CircularProgressIndicator(color:AppColors.accent));
      }
      if(state.status==MovieListStatus.failure)return ErrorMovies(
        message:state.failure?.message??'Unable to load movies',
        onRetry:()=>context.read<MovieListCubit>().load(MovieQuery(genre:_selected,
            sortBy:'rating')));
      if(state.items.isEmpty)return const EmptyMovies(message:'No movies in this genre');
      return GridView.builder(controller:_controller,
        padding:EdgeInsets.fromLTRB(16.w,0,16.w,22.h),
        gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:2,crossAxisSpacing:12.w,mainAxisSpacing:13.h,
          childAspectRatio:191/249),
        itemCount:state.items.length+(state.status==MovieListStatus.loadingMore?2:0),
        itemBuilder:(context,i){
          if(i>=state.items.length)return const Center(
            child:CircularProgressIndicator(color:AppColors.accent));
          final movie=state.items[i];
          return MoviePoster(movie:movie,width:191,height:249,
            onTap:()=>Navigator.pushNamed(context,AppRouter.details,arguments:movie));
        });
    })),
  ]));
}
