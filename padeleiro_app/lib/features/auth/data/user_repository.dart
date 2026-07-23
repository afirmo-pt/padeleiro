import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class UserRepository {
  /// Stream de utilizadores com status 'active', excluindo o utilizador
  /// autenticado actualmente.
  Stream<List<AppUser>> watchActivePlayers();

  /// Stream de utilizadores com status 'pending', ordenados por createdAt
  /// crescente.
  Stream<List<AppUser>> watchPendingUsers();

  /// Leitura directa do documento users/{uid}.
  Future<AppUser> getUser(String uid);

  /// Observa as alterações do documento users/{uid}.
  Stream<AppUser> watchUser(String uid);

  /// Actualiza os campos do perfil editáveis do utilizador.
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String phone,
    required String community,
  });
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<List<AppUser>> watchActivePlayers() {
    return _users
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<AppUser>> watchPendingUsers() {
    return _users
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  @override
  Future<AppUser> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      throw Exception('Utilizador $uid não encontrado.');
    }
    return AppUser.fromFirestore(doc);
  }

  @override
  Stream<AppUser> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Utilizador $uid não encontrado.');
      }
      return AppUser.fromFirestore(doc);
    });
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String phone,
    required String community,
  }) async {
    await _users.doc(uid).update({
      'fullName': fullName,
      'phone': phone,
      'community': community,
    });
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider que expõe a implementação Firebase de [UserRepository].
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

/// Provider que observa o perfil do utilizador autenticado.
final currentUserProvider = StreamProvider.family<AppUser, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
