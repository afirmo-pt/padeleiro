import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/swipe_action_card.dart';
import '../../../models/app_user.dart';
import '../../../models/location.dart';
import '../../match/data/location_repository.dart';
import '../data/admin_providers.dart';

/// Painel de administração com duas tabs:
///  - "Utilizadores": lista de utilizadores pendentes com swipe para aprovar/rejeitar.
///  - "Localizações": lista de todas as localizações com opção de arquivar.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Error SnackBar listener
  // ---------------------------------------------------------------------------

  /// Mostra um SnackBar de erro quando [adminActionsProvider] reporta um erro.
  void _listenForErrors(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminActionsProvider);
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${state.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _listenForErrors(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Utilizadores'),
            Tab(text: 'Localizações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsersTab(),
          _LocationsTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// Tab 1 — Utilizadores pendentes
// =============================================================================

class _UsersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingUsersProvider);
    final activeAsync = ref.watch(activeUsersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Utilizadores pendentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Erro ao carregar utilizadores pendentes: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Sem utilizadores pendentes.'),
                );
              }
              return Column(
                children: users
                    .map((user) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _PendingUserCard(user: user),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Utilizadores activos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          activeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Erro ao carregar utilizadores activos: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Sem utilizadores activos.'),
                );
              }
              return Column(
                children: users
                    .map((user) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _ActiveUserCard(user: user),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PendingUserCard extends ConsumerWidget {
  const _PendingUserCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatted =
        DateFormat('dd/MM/yyyy').format(user.createdAt);

    return SwipeActionCard(
      cardKey: ValueKey(user.uid),
      onSwipeRight: () =>
          ref.read(adminActionsProvider.notifier).approveUser(user.uid),
      onSwipeLeft: () =>
          ref.read(adminActionsProvider.notifier).rejectUser(user.uid),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                user.community,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registado em $dateFormatted',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.swipe, size: 14,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    'Deslize → aprovar  |  ← rejeitar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveUserCard extends ConsumerWidget {
  const _ActiveUserCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatted =
        DateFormat('dd/MM/yyyy').format(user.createdAt);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(adminActionsProvider.notifier).suspendUser(user.uid),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Suspender'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              user.community,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Registado em $dateFormatted',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tab 2 — Localizações
// =============================================================================

class _LocationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(allLocationsProvider);

    return locationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Erro ao carregar localizações: $e',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (locations) {
        return Stack(
          children: [
            locations.isEmpty
                ? const Center(child: Text('Sem localizações registadas.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                    itemCount: locations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _LocationListItem(location: locations[index]);
                    },
                  ),
            // "Nova Localização" button — placeholder for task 8.4
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: 'nova_localizacao_fab',
                onPressed: () => _showCreateLocationDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Nova Localização'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateLocationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Nova Localização'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Ex: Padel Clube Lisboa',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Morada',
                        hintText: 'Ex: Rua dos Padel, 123',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Morada é obrigatória.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSubmitting = true);
                          try {
                            await ref.read(locationRepositoryProvider).createLocation(
                                  CreateLocationPayload(
                                    name: nameController.text.trim(),
                                    address: addressController.text.trim(),
                                  ),
                                );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Localização criada com sucesso.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar localização: $e'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    addressController.dispose();
  }
}

class _LocationListItem extends ConsumerWidget {
  const _LocationListItem({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        location.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        location.address,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active / Archived badge
          _StatusBadge(isActive: location.isActive),
          const SizedBox(width: 8),
          // Archive button — only for active locations
          if (location.isActive)
            IconButton(
              tooltip: 'Arquivar localização',
              icon: const Icon(Icons.archive_outlined),
              color: colorScheme.error,
              onPressed: () => _confirmArchive(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arquivar localização'),
        content: Text(
          'Tem a certeza que pretende arquivar "${location.name}"? '
          'A localização deixará de estar disponível para novas partidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(locationRepositoryProvider)
            .archiveLocation(location.locationId);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao arquivar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

/// Badge visual que indica se a localização está activa ou arquivada.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00C853).withOpacity(0.15)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF00C853) : colorScheme.outline,
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Activa' : 'Arquivada',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? const Color(0xFF00C853) : colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
