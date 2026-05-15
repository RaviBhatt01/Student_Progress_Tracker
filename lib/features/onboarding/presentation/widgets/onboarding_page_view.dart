import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Data class describing one onboarding slide
class OnboardingSlide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

/// The three slides shown during onboarding.
/// Change copy or icons here without touching the page itself.
const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    icon: Icons.school_rounded,
    iconColor: AppTheme.primary,
    title: 'Welcome to Student Tracker',
    body:
        'Stay on top of every assignment, project, and deadline - all in one place.',
  ),
  OnboardingSlide(
    icon: Icons.checklist_rounded,
    iconColor: AppTheme.secondary,
    title: 'Organise by Priority',
    body:
        'Tag tasks as High, Medium, or Low priority so you always know what needs attention first.',
  ),
  OnboardingSlide(
    icon: Icons.notifications_active_rounded,
    iconColor: AppTheme.warning,
    title: 'Never Miss a Deadline',
    body:
        'Set due dates on any task and get a clear view of what\'s coming up.',
  ),
];

/// Renders one slide — icon illustration, title, and body copy.
class OnboardingPageView extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingPageView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: slide.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: slide.iconColor),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Body
          Text(
            slide.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
