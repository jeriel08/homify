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
      if (errorMessage.contains('account-exists-with-different-credential')) {
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
