import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:student_tracker/features/onboarding/presentation/pages/onboarding_page.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/tasks/domain/entities/task_entity.dart';
import '../features/tasks/presentation/pages/task_detail_page.dart';
import '../features/tasks/presentation/pages/task_list_page.dart';
import 'guards/auth_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: TaskListRoute.page, guards: [AuthGuard()]),
    // task param is auto-wired by auto_route from the @RoutePage constructor
    AutoRoute(page: TaskDetailRoute.page, guards: [AuthGuard()]),
  ];
}
