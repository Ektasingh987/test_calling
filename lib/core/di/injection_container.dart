import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../features/calling/data/datasources/call_local_datasource.dart';
import '../../features/calling/data/models/call_log_model.dart';
import '../../features/calling/data/repositories/call_repository_impl.dart';
import '../../features/calling/domain/repositories/call_repository.dart';
import '../../features/calling/domain/usecases/call_usecases.dart';
import '../../features/calling/presentation/cubit/call_cubit.dart';
import '../../features/feed/data/datasources/feed_local_datasource.dart';
import '../../features/feed/data/datasources/feed_remote_datasource.dart';
import '../../features/feed/data/models/post_model.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';
import '../../features/feed/domain/usecases/get_feed_usecase.dart';
import '../../features/feed/presentation/cubit/feed_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Hive ──────────────────────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(AppConstants.postModelTypeId)) {
    Hive.registerAdapter(PostModelAdapter());
  }
  if (!Hive.isAdapterRegistered(AppConstants.postUserModelTypeId)) {
    Hive.registerAdapter(PostUserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(AppConstants.callLogModelTypeId)) {
    Hive.registerAdapter(CallLogModelAdapter());
  }

  // Open boxes
  await Hive.openBox<PostModel>(AppConstants.postsBox);
  await Hive.openBox<CallLogModel>(AppConstants.callLogsBox);

  // ─── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => ApiClient.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ─── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ─── Feed ──────────────────────────────────────────────────────────────────
  // DataSources
  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<FeedLocalDataSource>(
    () => FeedLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: sl<FeedRemoteDataSource>(),
      localDataSource: sl<FeedLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // UseCases
  sl.registerLazySingleton<GetFeedUseCase>(
    () => GetFeedUseCase(sl<FeedRepository>()),
  );
  sl.registerLazySingleton<RefreshFeedUseCase>(
    () => RefreshFeedUseCase(sl<FeedRepository>()),
  );

  // Cubit (factory — new instance per screen)
  sl.registerFactory<FeedCubit>(
    () => FeedCubit(
      getFeedUseCase: sl<GetFeedUseCase>(),
      refreshFeedUseCase: sl<RefreshFeedUseCase>(),
    ),
  );

  // ─── Calling ───────────────────────────────────────────────────────────────
  // DataSources
  sl.registerLazySingleton<CallLocalDataSource>(
    () => CallLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(localDataSource: sl<CallLocalDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton<GetCallHistoryUseCase>(
    () => GetCallHistoryUseCase(sl<CallRepository>()),
  );
  sl.registerLazySingleton<SaveCallLogUseCase>(
    () => SaveCallLogUseCase(sl<CallRepository>()),
  );
  sl.registerLazySingleton<DeleteCallLogUseCase>(
    () => DeleteCallLogUseCase(sl<CallRepository>()),
  );
  sl.registerLazySingleton<ClearCallHistoryUseCase>(
    () => ClearCallHistoryUseCase(sl<CallRepository>()),
  );

  // Cubits
  sl.registerLazySingleton<CallHistoryCubit>(
    () => CallHistoryCubit(getHistoryUseCase: sl<GetCallHistoryUseCase>()),
  );
  sl.registerFactory<ActiveCallCubit>(
    () => ActiveCallCubit(saveCallLogUseCase: sl<SaveCallLogUseCase>()),
  );
}

