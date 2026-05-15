import 'package:auto_route/auto_route.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/storage_service.dart';
import '../../di/injection.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final storage = getIt<StorageService>();
    final token = storage.getString(AppConstants.keyAuthToken);

    if (token != null && token.isNotEmpty) {
      // Token exists — allow navigation to proceed
      resolver.next(true);
    } else {
      // No token — redirect to login, replacing the stack so
      // the back button doesn't bring them back to a protected screen
      // router.replaceAll([const LoginRoute()]);
    }
  }
}
