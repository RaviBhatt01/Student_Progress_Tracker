import '../../../core/constants/app_constants.dart';
import '../../../core/storage/storage_service.dart';

abstract class OnboardingRepository {
  /// Returns true if the user has already seen onboarding.
  bool hasSeenOnboarding();

  /// Persists that the user has completed onboarding.
  Future<void> completeOnboarding();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final StorageService _storage;

  OnboardingRepositoryImpl(this._storage);

  @override
  bool hasSeenOnboarding() => _storage.getBool(AppConstants.keyOnboardingSeen);

  @override
  Future<void> completeOnboarding() =>
      _storage.setBool(AppConstants.keyOnboardingSeen, value: true);
}
