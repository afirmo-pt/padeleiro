import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class AdminRepository {
  /// Aprova o utilizador com [uid] (status → active).
  Future<void> approveUser(String uid);

  /// Rejeita o utilizador com [uid] (status → rejected).
  Future<void> rejectUser(String uid);

  /// Suspende o utilizador com [uid] (status → suspended).
  Future<void> suspendUser(String uid);
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  /// Invoca a CloudFunction `manageUserStatus` com o [uid] e [action] indicados.
  Future<void> _callManageUserStatus(String uid, String action) async {
    final callable = _functions.httpsCallable('manageUserStatus');
    await callable.call<void>({'uid': uid, 'action': action});
  }

  @override
  Future<void> approveUser(String uid) => _callManageUserStatus(uid, 'approve');

  @override
  Future<void> rejectUser(String uid) => _callManageUserStatus(uid, 'reject');

  @override
  Future<void> suspendUser(String uid) => _callManageUserStatus(uid, 'suspend');
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider que expõe a implementação Firebase de [AdminRepository].
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirebaseAdminRepository(),
);
