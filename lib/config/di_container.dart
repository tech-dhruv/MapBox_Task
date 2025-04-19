import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:mapbox_task/config/api_constants.dart';
import 'package:mapbox_task/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:mapbox_task/providers/connectivity_provider.dart';
import 'package:mapbox_task/providers/map_provider.dart';
import 'package:mapbox_task/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasource/remote/dio/dio_client.dart';
import '../data/repository/auth_repo.dart';
import '../data/repository/user_repo.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // For API AND FIREBASE
  await Firebase.initializeApp();
  //? Core
  sl.registerLazySingleton(() => DioClient(APIConstants.BASE_URL, sl(),
      loggingInterceptor: sl(), sharedPreferences: sl()));

  //? Repository
  sl.registerLazySingleton(
      () => AuthRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(() => UserRepo());

  //? Provider
  sl.registerFactory(() => AuthProvider(authRepo: sl()));
  sl.registerFactory(() => ThemeProvider(sharedPreferences: sl()));
  sl.registerFactory(() => UserProvider(sl()));
  sl.registerFactory(() => ConnectivityProvider());
  sl.registerFactory(() => MapProvider());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => LoggingInterceptor());
  sl.registerLazySingleton(() => Dio());
}
