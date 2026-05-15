import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const StudentTrackerApp());
}

class StudentTrackerApp extends StatefulWidget {
  const StudentTrackerApp({super.key});

  @override
  State<StudentTrackerApp> createState() => _StudentTrackerAppState();
}

class _StudentTrackerAppState extends State<StudentTrackerApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthCubit — needed by Splash, Login, Register, TaskList (logout)
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        // TaskCubit — promoted to app level so TaskDetailPage can access it
        // across route boundaries without losing state
        BlocProvider<TaskCubit>(create: (_) => getIt<TaskCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Student Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
