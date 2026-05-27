import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enums.dart';
import 'auth_repository.dart';

// ---------------------------------------------------------------------------
// authRepositoryProvider
// ---------------------------------------------------------------------------

/// Fornece a implementação concreta de [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// ---------------------------------------------------------------------------
// authStateProvider
// ---------------------------------------------------------------------------

/// Stream do utilizador Firebase autenticado (null se não autenticado).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ---------------------------------------------------------------------------
// userStatusProvider
// ---------------------------------------------------------------------------

/// Lê o [UserStatus] de um utilizador pelo seu uid.
///
/// Uso: `ref.watch(userStatusProvider(uid))`
final userStatusProvider =
    FutureProvider.family<UserStatus, String>((ref, uid) async {
  return ref.watch(authRepositoryProvider).getUserStatus(uid);
});
