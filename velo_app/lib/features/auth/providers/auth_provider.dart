import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/secure_storage.dart';
import '../service/auth_service.dart';

part 'auth_provider.g.dart';

enum AuthState { initial, authenticated, unauthenticated }

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _init();
    return AuthState.initial;
  }

  Future<void> _init() async {
    final storage = const SecureStorageService();
    final token = await storage.getToken();
    
    if (token != null) {
      try {
        await ref.read(authServiceProvider).verify();
        state = AuthState.authenticated;
      } catch (_) {
        await storage.deleteToken();
        state = AuthState.unauthenticated;
      }
    } else {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> signIn(String email, String password) async {
    await ref.read(authServiceProvider).signIn(email, password);
    state = AuthState.authenticated;
  }

  Future<void> signUp(String email, String password) async {
    await ref.read(authServiceProvider).signUp(email, password);
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = AuthState.unauthenticated;
  }
}
