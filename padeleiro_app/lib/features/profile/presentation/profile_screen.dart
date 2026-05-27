import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/data/auth_providers.dart';
import '../../../features/auth/data/user_repository.dart';
import '../../../models/app_user.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _communityController = TextEditingController();

  bool _isSaving = false;
  String? _loadedUid;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  void _populateFields(AppUser user) {
    if (_loadedUid != user.uid) {
      _loadedUid = user.uid;
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone;
      _communityController.text = user.community;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _saveProfile(AppUser user) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(userRepositoryProvider).updateUserProfile(
            uid: user.uid,
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            community: _communityController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar perfil: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

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
            body: Center(child: Text('Não autenticado.')),
          );
        }

        return _buildProfileScreen(context, user.uid);
      },
    );
  }

  Widget _buildProfileScreen(BuildContext context, String uid) {
    final currentUserAsync = ref.watch(currentUserProvider(uid));
    final authRepo = ref.read(authRepositoryProvider);

    return currentUserAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: Center(child: Text('Erro ao carregar perfil: $error')),
      ),
      data: (profile) {
        _populateFields(profile);

        final createdAt = _formatDate(profile.createdAt);
        final status = profile.status.name.toUpperCase();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Terminar sessão',
                onPressed: () async {
                  await authRepo.signOut();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            profile.fullName.isEmpty
                                ? '?'
                                : profile.fullName
                                    .trim()
                                    .split(' ')
                                    .map((part) => part.isNotEmpty ? part[0] : '')
                                    .take(2)
                                    .join(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(profile.email),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(label: Text('Status: $status')),
                                  Chip(label: Text('Registo: $createdAt')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _communityController,
                  decoration: const InputDecoration(
                    labelText: 'Comunidade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveProfile(profile),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar alterações'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
