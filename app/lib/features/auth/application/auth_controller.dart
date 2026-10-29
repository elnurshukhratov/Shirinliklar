import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/providers.dart';
import '../../notifications/application/push_service.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

enum AuthStatus { loading, signedOut, signedIn, failed }

@immutable
class AuthState {
  const AuthState._(this.status, {this.user, this.error});

  const AuthState.loading() : this._(AuthStatus.loading);
  const AuthState.signedOut() : this._(AuthStatus.signedOut);
  const AuthState.signedIn(AppUser user) : this._(AuthStatus.signedIn, user: user);
  const AuthState.failed(Object error) : this._(AuthStatus.failed, error: error);

  final AuthStatus status;
  final AppUser? user;
  final Object? error;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

/// Chiqishdan oldin (token hali amal qilayotganda) bu qurilmaning push tokeni serverdan o'chiriladi.
typedef BeforeSignOut = Future<void> Function();

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo, {BeforeSignOut? beforeSignOut})
      : _beforeSignOut = beforeSignOut,
        super(const AuthState.loading()) {
    restore();
  }

  final AuthRepository _repo;
  final BeforeSignOut? _beforeSignOut;

  /// Ilova ochilganda saqlangan sessiyani tiklaydi.
  Future<void> restore() async {
    state = const AuthState.loading();
    if (!_repo.hasSession) {
      state = const AuthState.signedOut();
      return;
    }
    try {
      state = AuthState.signedIn(await _repo.fetchMe());
    } on ApiException catch (e) {
      if (e.status == 401 || e.code == 'UNAUTHORIZED') {
        await _repo.signOut();
        state = const AuthState.signedOut();
      } else {
        state = AuthState.failed(e);
      }
    } catch (e) {
      state = AuthState.failed(e);
    }
  }

  /// Xatoda exception tashlaydi, UI uni ko'rsatadi.
  Future<void> signIn() async {
    final user = await _repo.signInWithGoogle();
    if (user != null) state = AuthState.signedIn(user);
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    String? landmark,
  }) async {
    final user = await _repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      landmark: landmark,
    );
    state = AuthState.signedIn(user);
  }

  Future<void> signOut() async {
    await _beforeSignOut?.call();
    await _repo.signOut();
    state = const AuthState.signedOut();
  }

  Future<void> deleteAccount() async {
    await _beforeSignOut?.call();
    await _repo.deleteAccount();
    state = const AuthState.signedOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.watch(authRepositoryProvider),
    beforeSignOut: () => ref.read(pushServiceProvider).unregister(),
  ),
);