import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/enums.dart';

// ---------------------------------------------------------------------------
// RegisterPayload
// ---------------------------------------------------------------------------

/// Dados necessários para criar uma nova conta de utilizador.
class RegisterPayload {
  const RegisterPayload({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.community,
    required this.password,
  });

  final String fullName;
  final String email;
  final String phone;
  final String community;
  final String password;
}

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class AuthRepository {
  /// Stream que emite o utilizador Firebase autenticado (ou null se não autenticado).
  Stream<User?> get authStateChanges;

  /// Autentica com email e password.
  Future<void> signIn(String email, String password);

  /// Cria conta Firebase Auth e escreve documento `users/{uid}` com status pending.
  Future<void> register(RegisterPayload payload);

  /// Termina a sessão do utilizador autenticado.
  Future<void> signOut();

  /// Lê `users/{uid}` no Firestore e devolve o [UserStatus] correspondente.
  Future<UserStatus> getUserStatus(String uid);
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register(RegisterPayload payload) async {
    // 1. Criar conta Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
    );

    final uid = credential.user!.uid;

    // 2. Escrever documento users/{uid} com status: pending
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': payload.email,
      'fullName': payload.fullName,
      'phone': payload.phone,
      'community': payload.community,
      'status': UserStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserStatus> getUserStatus(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw StateError('Documento users/$uid não encontrado.');
    }

    final statusStr = doc.data()!['status'] as String;
    return UserStatus.values.byName(statusStr);
  }
}
