import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../models/match.dart';
import '../data/dashboard_providers.dart';

/// Lista paginada do histórico de partidas de um jogador.
///
/// Observa [matchHistoryProvider] e apresenta as partidas em [Card]s com
/// Material Design 3. Suporta carregamento incremental via botão
/// "Carregar mais" e indica o fim da lista quando [hasMore] é [false].
class MatchHistoryList extends ConsumerStatefulWidget {
  const MatchHistoryList({super.key, required this.playerId});

  final String playerId;

  @override
  ConsumerState<MatchHistoryList> createState() => _MatchHistoryListState();
}

class _MatchHistoryListState extends ConsumerState<MatchHistoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carrega a primeira página ao inicializar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(matchHistoryProvider(widget.playerId).notifier)
          .loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchHistoryProvider(widget.playerId));
    final matches = state.matches;

    if (matches.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matches.isEmpty && !state.isLoading) {
      return const Center(
        child: Text('Sem partidas registadas.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: matches.length + 1, // +1 para o rodapé
      itemBuilder: (context, index) {
        if (index < matches.length) {
          return _MatchCard(match: matches[index]);
        }
        // Rodapé: indicador de carregamento, botão ou mensagem de fim.
        return _ListFooter(
          playerId: widget.playerId,
          isLoading: state.isLoading,
          hasMore: state.hasMore,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _ListFooter
// ---------------------------------------------------------------------------

class _ListFooter extends ConsumerWidget {
  const _ListFooter({
    required this.playerId,
    required this.isLoading,
    required this.hasMore,
  });

  final String playerId;
  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Não há mais partidas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: FilledButton.tonal(
          onPressed: () {
            ref
                .read(matchHistoryProvider(playerId).notifier)
                .loadMore();
          },
          child: const Text('Carregar mais'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MatchCard
// ---------------------------------------------------------------------------

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatted =
        DateFormat('dd/MM/yyyy HH:mm').format(match.scheduledAt);

    final teamALabel =
        '${match.teamA.player1Name} / ${match.teamA.player2Name}';
    final teamBLabel =
        '${match.teamB.player1Name} / ${match.teamB.player2Name}';

    return InkWell(
      onTap: () => context.go('/match/${match.matchId}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha superior: data e badge de estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormatted,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                _StatusBadge(status: match.status),
              ],
            ),
            const SizedBox(height: 8),
            // Localização
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.locationName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Equipas
            Text(
              'Team A: $teamALabel',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              'Team B: $teamBLabel',
              style: theme.textTheme.bodyMedium,
            ),
            // Resultado (apenas se concluída)
            if (match.status == MatchStatus.completed &&
                match.scores != null &&
                match.scores!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.sports_tennis,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatScores(match.scores!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  /// Formata os scores como "X-X, X-X, X-X".
  String _formatScores(List<SetScore> scores) {
    return scores
        .map((s) => '${s.teamAScore}-${s.teamBScore}')
        .join(', ');
  }
}

// ---------------------------------------------------------------------------
// _StatusBadge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isCompleted = status == MatchStatus.completed;
    final label = isCompleted ? 'Concluída' : 'Agendada';
    final backgroundColor = isCompleted
        ? colorScheme.primaryContainer
        : colorScheme.secondaryContainer;
    final foregroundColor = isCompleted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
