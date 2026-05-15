import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/onboarding_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;
  final int totalPages;

  OnboardingCubit(this._repository, {this.totalPages = 3})
    : super(OnboardingState.active(currentPage: 0, totalPages: totalPages));

  /// Called by the PageView's onPageChanged — keeps state in sync
  /// when the user swipes manually.
  void onPageChanged(int index) {
    emit(OnboardingState.active(currentPage: index, totalPages: totalPages));
  }

  /// Called by the Next button — advances to the next page.
  /// If already on the last page, completes onboarding.
  Future<void> nextPage() async {
    final current = state;
    if (current is! OnboardingActive) return;

    if (current.currentPage < totalPages - 1) {
      emit(
        OnboardingState.active(
          currentPage: current.currentPage + 1,
          totalPages: totalPages,
        ),
      );
    } else {
      await complete();
    }
  }

  /// Persists completion and emits completed state.
  /// Also called by the Skip button.
  Future<void> complete() async {
    await _repository.completeOnboarding();
    emit(const OnboardingState.completed());
  }

  bool get isLastPage {
    final current = state;
    return current is OnboardingActive && current.currentPage == totalPages - 1;
  }
}
