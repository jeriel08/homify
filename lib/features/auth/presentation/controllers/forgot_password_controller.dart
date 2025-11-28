import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  final Ref _ref;

  ForgotPasswordController(this._ref) : super(ForgotPasswordState());

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final sendEmail = _ref.read(sendPasswordResetEmailUseCaseProvider);
      await sendEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapErrorMessage(e.toString()),
      );
    }
  }

  String _mapErrorMessage(String error) {
    String message = error
        .replaceAll('Exception: ', '')
        .replaceAll('Auth Error: ', '');

    if (message.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }

    return message;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final forgotPasswordControllerProvider =
    StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>((ref) {
      return ForgotPasswordController(ref);
    });
