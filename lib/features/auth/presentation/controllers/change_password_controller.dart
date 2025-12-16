import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/domain/usecases/change_password_use_case.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

/// State for the change password flow
class ChangePasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  ChangePasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller for managing the change password flow
class ChangePasswordController extends StateNotifier<ChangePasswordState> {
  final Ref _ref;

  ChangePasswordController(this._ref) : super(ChangePasswordState());

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    try {
      final useCase = _ref.read(changePasswordUseCaseProvider);
      await useCase(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
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

    // Map Firebase Auth errors to user-friendly messages
    if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Current password is incorrect.';
    } else if (message.contains('weak-password')) {
      return 'New password is too weak. Use at least 6 characters.';
    } else if (message.contains('requires-recent-login')) {
      return 'Please log out and log in again before changing your password.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    return message;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = ChangePasswordState();
  }
}

/// Provider for the ChangePasswordUseCase
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

/// Provider for the ChangePasswordController
final changePasswordControllerProvider =
    StateNotifierProvider.autoDispose<
      ChangePasswordController,
      ChangePasswordState
    >((ref) => ChangePasswordController(ref));
