import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_tracker/features/auth/domain/repositories/auth_repository_impl.dart';

import '../core/network/dio_client.dart';
import '../core/storage/storage_service.dart';
import '../features/auth/data/datasources/auth_mock_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../features/tasks/data/datasources/task_mock_datasource.dart';
import '../features/tasks/data/datasources/task_remote_datasource.dart';
import '../features/tasks/data/repositories/task_repository_impl.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import '../features/tasks/presentation/cubit/task_cubit.dart';
import '../router/app_router.dart';

final getIt = GetIt.instance;

/// Flip to false and set baseUrl in AppConstants when your real API is ready.
const bool useMocks = true;

Future<void> setupDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<StorageService>(StorageService(prefs));

  // --- Network (only needed for real API) ---
  getIt.registerSingleton<DioClient>(DioClient(getIt<StorageService>()));

  // --- Router ---
  getIt.registerSingleton<AppRouter>(AppRouter());

  // --- Onboarding ---
  getIt.registerSingleton<OnboardingRepository>(
    OnboardingRepositoryImpl(getIt<StorageService>()),
  );
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(getIt<OnboardingRepository>()),
  );

  // --- Auth ---
  getIt.registerSingleton<AuthRemoteDataSource>(
    useMocks
        ? AuthMockDataSource()
        : AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      storage: getIt<StorageService>(),
    ),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));

  // --- Tasks ---
  getIt.registerSingleton<TaskRemoteDataSource>(
    useMocks
        ? TaskMockDataSource()
        : TaskRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(remote: getIt<TaskRemoteDataSource>()),
  );
  getIt.registerFactory<TaskCubit>(() => TaskCubit(getIt<TaskRepository>()));
}
