import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

// 1. Define the state for the Google sign-in process
class GoogleSignInState {
  final bool isLoading;
  final String? errorMessage;
  final bool signInSuccess;

  GoogleSignInState({
    this.isLoading = false,
    this.errorMessage,
    this.signInSuccess = false,
  });

  GoogleSignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? signInSuccess,
    bool clearError = false,
  }) {
    return GoogleSignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      signInSuccess: signInSuccess ?? this.signInSuccess,
    );
  }
}

// 2. Create the StateNotifier (the Controller)
class GoogleSignInController extends StateNotifier<GoogleSignInState> {
  final Ref _ref;

  GoogleSignInController(this._ref) : super(GoogleSignInState());

  Future<void> signInWithGoogle() async {
    // 1. Set loading state and clear any old errors
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 2. Get the use case from our providers
      final signInWithGoogleUseCase = _ref.read(
        signInWithGoogleUseCaseProvider,
      );

      // 3. Call the use case
      await signInWithGoogleUseCase();

      // 4. If it succeeds, update the state
      state = state.copyWith(isLoading: false, signInSuccess: true);
    } catch (e) {
      // 5. If it fails, save the error message
      // We'll specifically check for the error we discussed
      String errorMessage = e.toString();

      // Clean up the error string first
      errorMessage = _mapErrorMessage(errorMessage);

      if (errorMessage.contains('account-exists-with-different-credential') ||
          errorMessage.contains('account already exists')) {
        errorMessage =
            'An account already exists with this email. Please sign in with your password to link your Google account.';
      } else if (errorMessage.contains('Google sign-in was cancelled')) {
        // Don't show an error, just stop loading
        state = state.copyWith(isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
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
final googleSignInControllerProvider =
    StateNotifierProvider<GoogleSignInController, GoogleSignInState>((ref) {
      return GoogleSignInController(ref);
    });
