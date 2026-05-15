import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../di/injection.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/onboarding_repository.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Splash logo visible for a moment before routing
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final onboardingRepo = getIt<OnboardingRepository>();

    if (!onboardingRepo.hasSeenOnboarding()) {
      // First launch — show onboarding before auth
      context.router.replace(const OnboardingRoute());
      return;
    }

    // Session already seen onboarding — check auth state
    context.read<AuthCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (_) =>
              context.router.replaceAll([const TaskListRoute()]),
          unauthenticated: () => context.router.replaceAll([LoginRoute()]),
          error: (_) => context.router.replaceAll([LoginRoute()]),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 72, color: Colors.white),
              SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
