import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection.dart';
import '../../../../router/app_router.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_page_view.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // PageController lives here — it's a Flutter controller tied to the widget
  // lifecycle, so it belongs in State, not the Cubit.
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => getIt<OnboardingCubit>(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          state.whenOrNull(
            // Navigate to login when onboarding completes
            completed: () => context.router.replaceAll([LoginRoute()]),
          );

          // When cubit page changes (e.g. Next button), drive the PageController
          state.whenOrNull(
            active: (currentPage, _) => _animateToPage(currentPage),
          );
        },
        builder: (context, state) {
          final currentPage = state.maybeWhen(
            active: (page, _) => page,
            orElse: () => 0,
          );
          final isLastPage = state.maybeWhen(
            active: (page, total) => page == total - 1,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            body: SafeArea(
              child: Column(
                children: [
                  // Skip button — top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: () =>
                            context.read<OnboardingCubit>().complete(),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),

                  // Slides
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: kOnboardingSlides.length,
                      // Keep cubit in sync when user swipes manually
                      onPageChanged: (i) =>
                          context.read<OnboardingCubit>().onPageChanged(i),
                      itemBuilder: (_, i) =>
                          OnboardingPageView(slide: kOnboardingSlides[i]),
                    ),
                  ),

                  // Dots + Next/Get Started button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: Column(
                      children: [
                        // Page indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            kOnboardingSlides.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == currentPage ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i == currentPage
                                    ? AppTheme.primary
                                    : AppTheme.divider,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Next / Get Started
                        ElevatedButton(
                          onPressed: () =>
                              context.read<OnboardingCubit>().nextPage(),
                          child: Text(isLastPage ? 'Get Started' : 'Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
