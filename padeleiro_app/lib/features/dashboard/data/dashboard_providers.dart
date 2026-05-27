import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/match.dart';
import '../../../models/user_stats.dart';
import '../../match/data/match_repository.dart';
import 'stats_repository.dart';

// ---------------------------------------------------------------------------
// userStatsProvider
// ---------------------------------------------------------------------------

/// Stream em tempo real das estatísticas do utilizador identificado por [uid].
/// Delega para [StatsRepository.watchUserStats].
final userStatsProvider = StreamProvider.family<UserStats, String>((ref, uid) {
  final repo = ref.watch(statsRepositoryProvider);
  return repo.watchUserStats(uid);
});

// ---------------------------------------------------------------------------
// MatchHistoryState
// ---------------------------------------------------------------------------

/// Estado imutável do histórico de partidas de um jogador.
class MatchHistoryState {
  const MatchHistoryState({
    this.matches = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDocument,
  });

  /// Lista acumulada de partidas carregadas até ao momento.
  final List<Match> matches;

  /// Indica se uma operação de carregamento está em curso.
  final bool isLoading;

  /// Indica se existem mais partidas para carregar.
  /// Torna-se [false] quando uma página retorna menos de 20 resultados.
  final bool hasMore;

  /// Último [DocumentSnapshot] recebido, usado como cursor para a próxima página.
  final DocumentSnapshot? lastDocument;

  MatchHistoryState copyWith({
    List<Match>? matches,
    bool? isLoading,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    bool clearLastDocument = false,
  }) {
    return MatchHistoryState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDocument:
          clearLastDocument ? null : (lastDocument ?? this.lastDocument),
    );
  }
}

// ---------------------------------------------------------------------------
// MatchHistoryNotifier
// ---------------------------------------------------------------------------

/// Notifier que gere o carregamento paginado do histórico de partidas.
///
/// Usa cursores Firestore ([DocumentSnapshot]) para paginação eficiente.
/// Cada página contém no máximo 20 documentos; quando uma página retorna
/// menos de 20 resultados, [MatchHistoryState.hasMore] é definido como
/// [false] e não são feitos mais pedidos.
class MatchHistoryNotifier extends StateNotifier<MatchHistoryState> {
  MatchHistoryNotifier({
    required this.playerId,
    required this.ref,
  }) : super(const MatchHistoryState());

  final String playerId;
  final Ref ref;

  static const int _pageSize = 20;

  /// Carrega a próxima página de partidas.
  ///
  /// Se [MatchHistoryState.isLoading] for [true] ou [MatchHistoryState.hasMore]
  /// for [false], o método retorna imediatamente sem fazer nenhum pedido.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final repo = ref.read(matchRepositoryProvider);

    // Subscrever o stream e aguardar o primeiro evento (snapshot actual).
    final newMatches = await repo
        .watchPlayerMatches(playerId, cursor: state.lastDocument)
        .first;

    // Determinar o novo cursor: o último DocumentSnapshot da página.
    // Como o repositório devolve List<Match> (sem acesso directo aos docs),
    // precisamos de obter o snapshot via Firestore para o cursor.
    // A implementação actual do repositório não expõe os DocumentSnapshots,
    // por isso obtemos o cursor directamente do Firestore.
    DocumentSnapshot? newLastDocument;
    if (newMatches.isNotEmpty) {
      final firestore = FirebaseFirestore.instance;
      final query = firestore
          .collection('matches')
          .where('playerIds', arrayContains: playerId)
          .orderBy('scheduledAt', descending: true)
          .limit(_pageSize);

      final queryToRun = state.lastDocument != null
          ? query.startAfterDocument(state.lastDocument!)
          : query;

      final snapshot = await queryToRun.get();
      if (snapshot.docs.isNotEmpty) {
        newLastDocument = snapshot.docs.last;
      }
    }

    final hasMore = newMatches.length >= _pageSize;

    state = state.copyWith(
      matches: [...state.matches, ...newMatches],
      isLoading: false,
      hasMore: hasMore,
      lastDocument: newLastDocument,
    );
  }
}

// ---------------------------------------------------------------------------
// matchHistoryProvider
// ---------------------------------------------------------------------------

/// Provider que expõe o [MatchHistoryNotifier] para o jogador identificado
/// por [playerId].
///
/// Exemplo de uso:
/// ```dart
/// final notifier = ref.read(matchHistoryProvider(uid).notifier);
/// await notifier.loadMore();
/// ```
final matchHistoryProvider = StateNotifierProvider.family<MatchHistoryNotifier,
    MatchHistoryState, String>(
  (ref, playerId) => MatchHistoryNotifier(playerId: playerId, ref: ref),
);
