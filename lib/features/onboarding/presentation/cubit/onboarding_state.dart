import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
sealed class OnboardingState with _$OnboardingState {
  const factory OnboardingState.active({
    /// Index of the currently visible page
    required int currentPage,

    /// Total number of onboarding pages
    required int totalPages,
  }) = OnboardingActive;

  /// User tapped "Get Started" on the last page
  const factory OnboardingState.completed() = OnboardingCompleted;
}