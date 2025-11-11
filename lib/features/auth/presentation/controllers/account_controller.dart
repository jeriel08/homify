import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/auth_providers.dart';

// 1. Define the Notifier
class LogoutController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initialization needed, so this is empty.
    return;
  }

  // 2. Define the logout method
  Future<void> logout() async {
    // Set state to loading
    state = const AsyncLoading();

    // Get the use case
    final logoutUser = ref.read(logoutUserUseCaseProvider);

    // Call it, and let AsyncNotifier handle the success (AsyncData)
    // or error (AsyncError) state automatically.
    state = await AsyncValue.guard(() => logoutUser());
  }
}

// 3. Create the Provider
final logoutControllerProvider = AsyncNotifierProvider<LogoutController, void>(
  () {
    return LogoutController();
  },
);
