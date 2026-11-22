import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/library/data/datasources/firestore_library_data_source.dart';
import '../../features/library/data/repositories/firestore_library_repository.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/presentation/cubit/library_cubit.dart';
import '../../features/movies/data/datasources/yts_movies_remote_data_source.dart';
import '../../features/movies/data/repositories/yts_movies_repository.dart';
import '../../features/movies/domain/repositories/movies_repository.dart';
import '../../features/movies/presentation/cubit/home_cubit.dart';
import '../../features/movies/presentation/cubit/movie_details_cubit.dart';
import '../../features/movies/presentation/cubit/movie_list_cubit.dart';
import '../../features/movies/presentation/cubit/search_cubit.dart';
import '../../features/settings/presentation/cubit/language_cubit.dart';
import '../../features/user_data/data/datasources/firestore_user_document_data_source.dart';
import '../../features/user_data/data/repositories/firestore_user_document_repository.dart';
import '../../features/user_data/domain/repositories/user_document_repository.dart';
import '../../features/user_data/presentation/cubit/profile_cubit.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/cached_json_request.dart';
import '../storage/cache_helper.dart';
import '../storage/hive_service.dart';

final getIt=GetIt.instance;
Future<void> configureDependencies(HiveService hive) async {
  getIt.registerSingleton<HiveService>(hive);
  getIt.registerLazySingleton<CacheHelper>(()=>CacheHelper(SharedPreferencesAsync()));
  getIt.registerLazySingleton<FirebaseAuth>(()=>FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(()=>FirebaseFirestore.instance);
  getIt.registerLazySingleton<DioClient>(()=>DioClient(
    // Never attach Firebase tokens to the public YTS movie API.
    attachToken:(_)=>false));
  getIt.registerLazySingleton<CachedJsonRequest>(()=>CachedJsonRequest(
    getIt<DioClient>(),getIt<HiveService>()));
  getIt.registerLazySingleton<YtsMoviesRemoteDataSource>(()=>YtsMoviesRemoteDataSource(
    getIt<CachedJsonRequest>()));
  getIt.registerLazySingleton<MoviesRepository>(()=>YtsMoviesRepository(
    getIt<YtsMoviesRemoteDataSource>()));
  getIt.registerFactory<HomeCubit>(()=>HomeCubit(getIt<MoviesRepository>()));
  getIt.registerFactory<MovieListCubit>(()=>MovieListCubit(getIt<MoviesRepository>()));
  getIt.registerFactory<SearchCubit>(()=>SearchCubit(getIt<MoviesRepository>()));
  getIt.registerFactory<MovieDetailsCubit>(()=>MovieDetailsCubit(getIt<MoviesRepository>()));

  getIt.registerLazySingleton<FirebaseAuthRemoteDataSource>(()=>
    FirebaseAuthRemoteDataSource(getIt<FirebaseAuth>()));
  getIt.registerLazySingleton<AuthRepository>(()=>FirebaseAuthRepository(
    getIt<FirebaseAuthRemoteDataSource>()));

  getIt.registerLazySingleton<FirestoreUserDocumentDataSource>(()=>
    FirestoreUserDocumentDataSource(getIt<FirebaseFirestore>(),AppConfig.userCollection));
  getIt.registerLazySingleton<UserDocumentRepository>(()=>
    FirestoreUserDocumentRepository(getIt<FirestoreUserDocumentDataSource>()));
  getIt.registerLazySingleton<FirestoreLibraryDataSource>(()=>
    FirestoreLibraryDataSource(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton<LibraryRepository>(()=>
    FirestoreLibraryRepository(getIt<FirestoreLibraryDataSource>()));

  getIt.registerFactory<AuthCubit>(()=>AuthCubit(getIt<AuthRepository>(),
    getIt<UserDocumentRepository>(),getIt<LibraryRepository>()));
  getIt.registerFactory<LibraryCubit>(()=>LibraryCubit(getIt<LibraryRepository>()));
  getIt.registerFactory<ProfileCubit>(()=>ProfileCubit(getIt<UserDocumentRepository>(),
    getIt<AuthRepository>()));
  getIt.registerFactory<LanguageCubit>(()=>LanguageCubit(getIt<CacheHelper>()));
}
