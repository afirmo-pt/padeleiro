import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_stats.dart';
import '../../auth/data/auth_providers.dart';
import '../data/dashboard_providers.dart';
import 'match_history_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro de autenticação: $e')),
      ),
      data: (user) {
        if (user == null) {
          // Guard: não deve acontecer se o router estiver configurado correctamente.
          return const Scaffold(
            body: Center(child: Text('Não autenticado')),
          );
        }
        return _DashboardView(uid: user.uid);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _DashboardView — ecrã principal após autenticação confirmada
// ---------------------------------------------------------------------------

class _DashboardView extends ConsumerWidget {
  const _DashboardView({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Painel Admin',
            onPressed: () => context.go(AppRoutes.admin),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => context.go(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Terminar sessão',
            onPressed: () async {
              final repo = ref.read(authRepositoryProvider);
              await repo.signOut();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/match/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova partida'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar estatísticas: $e',
            style: TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
        data: (stats) => _DashboardBody(stats: stats, uid: uid),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DashboardBody — conteúdo quando os dados estão disponíveis
// ---------------------------------------------------------------------------

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, required this.uid});

  final UserStats stats;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'As minhas estatísticas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Partidas',
                        value: stats.totalMatches,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Vitórias',
                        value: stats.wins,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Derrotas',
                        value: stats.losses,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Histórico de partidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MatchHistoryList(playerId: uid),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _StatCard — card individual de estatística
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
