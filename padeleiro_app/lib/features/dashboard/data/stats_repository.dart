import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_stats.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class StatsRepository {
  /// Stream em tempo real das estatísticas do utilizador com [uid].
  /// Emite um [UserStats] com zeros se o documento ainda não existir.
  Stream<UserStats> watchUserStats(String uid);
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseStatsRepository implements StatsRepository {
  FirebaseStatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<UserStats> watchUserStats(String uid) {
    return _firestore
        .collection('user_stats')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        // Documento ainda não existe — devolver zeros por omissão
        return UserStats(
          uid: uid,
          totalMatches: 0,
          wins: 0,
          losses: 0,
        );
      }
      return UserStats.fromMap(doc.id, doc.data()!);
    });
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider que expõe a implementação Firebase de [StatsRepository].
final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => FirebaseStatsRepository(),
);
