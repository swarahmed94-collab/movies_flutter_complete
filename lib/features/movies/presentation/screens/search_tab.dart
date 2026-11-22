import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/movie_poster.dart';
import '../cubit/search_cubit.dart';
import '../cubit/movie_list_cubit.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>getIt<SearchCubit>(),child:const _SearchBody());
}
class _SearchBody extends StatefulWidget {
  const _SearchBody();
  @override
  State<_SearchBody> createState()=>_SearchBodyState();
}
class _SearchBodyState extends State<_SearchBody> {
  final _search=TextEditingController();
  final _scroll=ScrollController();
  @override
  void initState(){super.initState();_scroll.addListener(_onScroll);}
  void _onScroll(){
    if(_scroll.hasClients && _scroll.position.extentAfter<350){
      context.read<SearchCubit>().nextPage();
    }
  }
  @override
  void dispose(){_search.dispose();_scroll.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>SafeArea(top:true,bottom:false,child:Column(children:[
    Padding(padding:EdgeInsets.fromLTRB(16.w,8.h,16.w,10.h),
      child:TextField(controller:_search,onChanged:(value){context.read<SearchCubit>().changed(value);setState((){});},
        style:TextStyle(color:Colors.white,fontSize:16.sp),cursorColor:AppColors.accent,
        decoration:InputDecoration(hintText:'Search',hintStyle:TextStyle(color:Colors.white,fontSize:16.sp),
          prefixIcon:Padding(padding:EdgeInsets.all(14.w),
            child:const AppIcon('assets/icons/search.svg',size:24)),
          suffixIcon:_search.text.isEmpty?null:IconButton(
            onPressed:(){_search.clear();context.read<SearchCubit>().changed('');setState((){});},
            icon:const Icon(Icons.close,color:Colors.white)),
          filled:true,fillColor:AppColors.surface,
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(14.r),
            borderSide:BorderSide.none),
          contentPadding:EdgeInsets.symmetric(vertical:17.h)),
      )),
    Expanded(child:BlocBuilder<SearchCubit,MovieListState>(builder:(context,state){
      if(state.status==MovieListStatus.initial)return const EmptyMovies();
      if(state.status==MovieListStatus.loading)return const Center(
        child:CircularProgressIndicator(color:AppColors.accent));
      if(state.status==MovieListStatus.failure)return ErrorMovies(
        message:state.failure?.message??'Search failed',
        onRetry:()=>context.read<SearchCubit>().changed(_search.text));
      if(state.items.isEmpty)return const EmptyMovies(message:'No matching movies found');
      return GridView.builder(controller:_scroll,
        padding:EdgeInsets.fromLTRB(16.w,7.h,16.w,22.h),
        gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:2,mainAxisSpacing:13.h,crossAxisSpacing:13.w,
          childAspectRatio:190/250),
        itemCount:state.items.length+(state.status==MovieListStatus.loadingMore?2:0),
        itemBuilder:(context,i){
          if(i>=state.items.length)return const Center(child:CircularProgressIndicator(
            color:AppColors.accent));
          final movie=state.items[i];
          return MoviePoster(movie:movie,width:190,height:250,
            onTap:()=>Navigator.pushNamed(context,AppRouter.details,arguments:movie));
        });
    })),
  ]));
}
