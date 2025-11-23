import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

// 1. Define the state for the login page
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool loginSuccess;

  LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.loginSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? loginSuccess,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      loginSuccess: loginSuccess ?? this.loginSuccess,
    );
  }
}

// 2. Create the StateNotifier (the Controller)
class LoginController extends StateNotifier<LoginState> {
  final Ref _ref;

  LoginController(this._ref) : super(LoginState());

  Future<void> login(String email, String password) async {
    // 1. Set loading state and clear any old errors
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 2. Get the use case from our providers
      final loginUser = _ref.read(loginUserUseCaseProvider);

      // 3. Call the use case
      await loginUser(email: email, password: password);

      // 4. If it succeeds, update the state
      state = state.copyWith(isLoading: false, loginSuccess: true);
    } catch (e) {
      // 5. If it fails, save the error message
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapErrorMessage(e.toString()),
      );
    }
  }

  String _mapErrorMessage(String error) {
    // 1. Clean up the error string
    String message = error
        .replaceAll('Exception: ', '')
        .replaceAll('Auth Error: ', '');

    // 2. Map specific Firebase/Auth errors to user-friendly messages
    if (message.contains('user-not-found') ||
        message.contains('no user record')) {
      return 'No account found with this email.';
    } else if (message.contains('wrong-password') ||
        message.contains('incorrect, malformed or has expired')) {
      return 'Invalid email or password.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    } else if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }

    // 3. Return the cleaned message if no specific match
    return message;
  }

  // Helper to clear the error after it's been shown
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// 3. Create the provider for our new controller
final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      return LoginController(ref);
    });
