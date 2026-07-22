import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import '../data/match_providers.dart';
import '../../../models/app_user.dart';
import '../../../models/location.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  Future<void> _showInviteDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Convidar jogador'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        hintText: 'Ex: João Silva',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Ex: joao@email.com',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Obrigatório';
                        if (!v.contains('@')) return 'Email inválido';
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
                          setDialogState(() => isSubmitting = true);
                          try {
                            final fn = FirebaseFunctions.instanceFor(
                              region: 'us-central1',
                            ).httpsCallable('invitePlayer');
                            final result = await fn({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                            });
                            final data = result.data as Map<String, dynamic>;
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              ref.invalidate(activePlayersProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Jogador ${data['fullName']} convidado com sucesso!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              final msg = e is FirebaseFunctionsException
                                  ? e.message ?? 'Erro ao convidar jogador.'
                                  : 'Erro ao convidar jogador.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
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
                      : const Text('Convidar'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    ref.read(createMatchProvider.notifier).setScheduledAt(selected);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _teamLabel(AppUser player, CreateMatchState state) {
    if (state.teamAPlayers.any((p) => p.uid == player.uid)) {
      return 'teamA';
    }
    return 'teamB';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final playersAsync = ref.watch(activePlayersProvider);
    final locationsAsync = ref.watch(activeLocationsProvider);
    final createState = ref.watch(createMatchProvider);
    final createNotifier = ref.read(createMatchProvider.notifier);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Erro de autenticação: $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Utilizador não autenticado.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nova Partida'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Cancelar',
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (createState.error != null) ...[
                  Card(
                    color: AppColors.error.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        createState.error!,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Localização',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                locationsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Erro ao carregar localizações: $error'),
                  data: (locations) {
                    if (locations.isEmpty) {
                      return const Text('Não há localizações ativas disponíveis.');
                    }
                    return DropdownButtonFormField<Location>(
                      value: createState.selectedLocation,
                      items: locations
                          .map(
                            (location) => DropdownMenuItem<Location>(
                              value: location,
                              child: Text(location.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          createNotifier.setLocation(value);
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: 'Selecione uma localização',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Data e hora',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _selectDateTime,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Selecionar data e hora'),
                ),
                if (createState.scheduledAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Agendada para: ${_formatDateTime(createState.scheduledAt!)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Jogadores ativos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('Selecione 4 jogadores para formar duas equipas.'),
                const SizedBox(height: 12),
                playersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Erro ao carregar jogadores: $error'),
                  data: (players) {
                    if (players.isEmpty) {
                      return const Text('Não há jogadores activos disponíveis.');
                    }
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: players.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isSelected = createState.selectedPlayers
                              .any((p) => p.uid == player.uid);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) {
                              createNotifier.togglePlayer(player);
                            },
                            title: Text(player.fullName),
                            subtitle: Text(player.community),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showInviteDialog(context),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Convidar jogador'),
                ),
                if (createState.selectedPlayers.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Atribuir equipas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Equipa A (${createState.teamAPlayers.length}/2)'),
                          const SizedBox(height: 8),
                          for (final player in createState.selectedPlayers)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Text(player.fullName)),
                                  DropdownButton<String>(
                                    value: _teamLabel(player, createState),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'teamA',
                                        child: Text('Equipa A'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'teamB',
                                        child: Text('Equipa B'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        createNotifier.assignToTeam(player, value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Text('Equipa B (${createState.teamBPlayers.length}/2)'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: createState.isSubmitting
                        ? null
                        : () async {
                            try {
                              final matchId = await createNotifier.submit(user.uid);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Partida criada com sucesso.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.go(AppRoutes.dashboard);
                            } catch (_) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(createState.error ?? 'Erro ao criar partida.'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    child: createState.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Criar partida'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
