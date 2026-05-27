import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/match.dart';

// ---------------------------------------------------------------------------
// CreateMatchPayload
// ---------------------------------------------------------------------------

/// Dados necessários para criar uma nova partida.
class CreateMatchPayload {
  const CreateMatchPayload({
    required this.scheduledAt,
    required this.locationId,
    required this.locationName,
    required this.teamA,
    required this.teamB,
    required this.createdBy,
  });

  final DateTime scheduledAt;
  final String locationId;
  final String locationName;
  final MatchTeam teamA;
  final MatchTeam teamB;

  /// UID do utilizador que cria a partida.
  final String createdBy;
}

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class MatchRepository {
  /// Stream paginado de partidas em que [playerId] participa,
  /// ordenado por [scheduledAt] decrescente, limite 20 por página.
  /// Passar [cursor] para obter a página seguinte.
  Stream<List<Match>> watchPlayerMatches(
    String playerId, {
    DocumentSnapshot? cursor,
  });

  /// Cria um novo documento na coleção `matches` com status: scheduled.
  Future<DocumentReference> createMatch(CreateMatchPayload payload);

  /// Actualiza o documento `matches/{matchId}` com os scores e status: completed.
  Future<void> finalizeMatch(String matchId, List<SetScore> scores);

  /// Leitura directa de `matches/{matchId}`.
  Future<Match> getMatch(String matchId);
}

// ---------------------------------------------------------------------------
// Firebase implementation
// ---------------------------------------------------------------------------

class FirebaseMatchRepository implements MatchRepository {
  FirebaseMatchRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  @override
  Stream<List<Match>> watchPlayerMatches(
    String playerId, {
    DocumentSnapshot? cursor,
  }) {
    Query<Map<String, dynamic>> query = _matches
        .where('playerIds', arrayContains: playerId)
        .orderBy('scheduledAt', descending: true)
        .limit(20);

    if (cursor != null) {
      query = query.startAfterDocument(cursor);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Match.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<DocumentReference> createMatch(CreateMatchPayload payload) async {
    // Construir o array playerIds com os 4 IDs dos jogadores
    final playerIds = [
      payload.teamA.player1Id,
      payload.teamA.player2Id,
      payload.teamB.player1Id,
      payload.teamB.player2Id,
    ];

    final docRef = await _matches.add({
      'status': 'scheduled',
      'createdBy': payload.createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledAt': Timestamp.fromDate(payload.scheduledAt),
      'locationId': payload.locationId,
      'locationName': payload.locationName,
      'teamA': payload.teamA.toMap(),
      'teamB': payload.teamB.toMap(),
      'playerIds': playerIds,
    });

    return docRef;
  }

  @override
  Future<void> finalizeMatch(String matchId, List<SetScore> scores) async {
    final winnerId = _determineWinner(scores);

    await _matches.doc(matchId).update({
      'scores': scores.map((s) => s.toMap()).toList(),
      'winnerId': winnerId,
      'status': 'completed',
    });
  }

  @override
  Future<Match> getMatch(String matchId) async {
    final doc = await _matches.doc(matchId).get();

    if (!doc.exists) {
      throw StateError('Documento matches/$matchId não encontrado.');
    }

    return Match.fromMap(doc.id, doc.data()!);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Determina o vencedor contando os sets ganhos por cada equipa.
  /// Devolve 'teamA' ou 'teamB'.
  String _determineWinner(List<SetScore> scores) {
    int teamAWins = 0;
    int teamBWins = 0;

    for (final set in scores) {
      if (set.teamAScore > set.teamBScore) {
        teamAWins++;
      } else if (set.teamBScore > set.teamAScore) {
        teamBWins++;
      }
    }

    return teamAWins >= teamBWins ? 'teamA' : 'teamB';
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider que expõe a implementação Firebase de [MatchRepository].
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return FirebaseMatchRepository();
});
