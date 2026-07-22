import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import '../data/match_providers.dart';
import '../data/match_repository.dart';
import '../../../models/match.dart';
import '../../../models/enums.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamASet1 = TextEditingController();
  final _teamBSet1 = TextEditingController();
  final _teamASet2 = TextEditingController();
  final _teamBSet2 = TextEditingController();
  final _teamASet3 = TextEditingController();
  final _teamBSet3 = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _teamASet1.dispose();
    _teamBSet1.dispose();
    _teamASet2.dispose();
    _teamBSet2.dispose();
    _teamASet3.dispose();
    _teamBSet3.dispose();
    super.dispose();
  }

  List<SetScore> _buildSetScores() {
    return [
      SetScore(
        setNumber: 1,
        teamAScore: int.parse(_teamASet1.text),
        teamBScore: int.parse(_teamBSet1.text),
      ),
      SetScore(
        setNumber: 2,
        teamAScore: int.parse(_teamASet2.text),
        teamBScore: int.parse(_teamBSet2.text),
      ),
      SetScore(
        setNumber: 3,
        teamAScore: int.parse(_teamASet3.text),
        teamBScore: int.parse(_teamBSet3.text),
      ),
    ];
  }

  Future<void> _finalizeMatch(Match match) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final scores = _buildSetScores();
      await ref.read(matchRepositoryProvider).finalizeMatch(match.matchId, scores);
      if (!mounted) return;
      ref.invalidate(matchDetailProvider(widget.matchId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partida concluída com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao concluir partida: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateScore(String? value) {
    if (value == null || value.isEmpty) {
      return 'Obrigatório';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) {
      return 'Número inválido';
    }
    return null;
  }

  String _playerLabel(MatchTeam team) {
    return '${team.player1Name} / ${team.player2Name}';
  }

  /// Devolve o nome da equipa vencedora, compatível tanto com o formato
  /// antigo ('teamA'/'teamB') como com o novo (playerId do vencedor).
  String _winningTeamLabel(Match match) {
    final winnerId = match.winnerId!;
    // Formato antigo: 'teamA' ou 'teamB'
    if (winnerId == 'teamA') return _playerLabel(match.teamA);
    if (winnerId == 'teamB') return _playerLabel(match.teamB);
    // Formato novo: playerId do vencedor
    if (winnerId == match.teamA.player1Id || winnerId == match.teamA.player2Id) {
      return _playerLabel(match.teamA);
    }
    return _playerLabel(match.teamB);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Erro de autenticação: $error'))),
      data: (user) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhe da Partida'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Voltar',
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ),
          body: matchAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erro ao carregar partida: $error')),
            data: (match) {
              final canFinalize = user != null && match.status == MatchStatus.scheduled && match.createdBy == user.uid;
              final winnerName = match.winnerId != null
                  ? _winningTeamLabel(match)
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações da partida',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(label: 'Localização', value: match.locationName),
                            const SizedBox(height: 8),
                            _DetailRow(label: 'Data', value: match.scheduledAt.toLocal().toString()),
                            const SizedBox(height: 8),
                            _DetailRow(label: 'Estado', value: match.status == MatchStatus.scheduled ? 'Agendada' : 'Concluída'),
                            const SizedBox(height: 8),
                            _DetailRow(label: 'Criada por', value: match.createdBy),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipa A',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(_playerLabel(match.teamA)),
                            const SizedBox(height: 16),
                            Text(
                              'Equipa B',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(_playerLabel(match.teamB)),
                          ],
                        ),
                      ),
                    ),
                    if (match.status == MatchStatus.completed) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: AppColors.success.withOpacity(0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resultado',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              if (winnerName != null) ...[
                                Text('Vencedor: $winnerName'),
                                const SizedBox(height: 8),
                              ],
                              Text(_formatScores(match.scores ?? [])),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (match.status == MatchStatus.scheduled) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Registar score',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _ScoreRow(
                                      label: 'Set 1',
                                      teamAScoreController: _teamASet1,
                                      teamBScoreController: _teamBSet1,
                                      validate: _validateScore,
                                    ),
                                    _ScoreRow(
                                      label: 'Set 2',
                                      teamAScoreController: _teamASet2,
                                      teamBScoreController: _teamBSet2,
                                      validate: _validateScore,
                                    ),
                                    _ScoreRow(
                                      label: 'Set 3',
                                      teamAScoreController: _teamASet3,
                                      teamBScoreController: _teamBSet3,
                                      validate: _validateScore,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: canFinalize && !_isSubmitting ? () => _finalizeMatch(match) : null,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : const Text('Concluir partida'),
                              ),
                              if (!canFinalize) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Apenas o criador da partida pode finalizar a partida.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatScores(List<SetScore> scores) {
    if (scores.isEmpty) {
      return 'Nenhum score registado.';
    }
    return scores.map((s) => 'Set ${s.setNumber}: ${s.teamAScore}-${s.teamBScore}').join('\n');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.teamAScoreController,
    required this.teamBScoreController,
    required this.validate,
  });

  final String label;
  final TextEditingController teamAScoreController;
  final TextEditingController teamBScoreController;
  final String? Function(String?) validate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: teamAScoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '$label Equipa A',
                border: const OutlineInputBorder(),
              ),
              validator: validate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: teamBScoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '$label Equipa B',
                border: const OutlineInputBorder(),
              ),
              validator: validate,
            ),
          ),
        ],
      ),
    );
  }
}
