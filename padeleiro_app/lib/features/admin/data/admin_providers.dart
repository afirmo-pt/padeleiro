import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../../models/location.dart';
import '../../auth/data/user_repository.dart';
import '../../match/data/location_repository.dart';
import 'admin_repository.dart';

// ---------------------------------------------------------------------------
// pendingUsersProvider
// ---------------------------------------------------------------------------

/// Stream de utilizadores com `status: pending`, ordenados por `createdAt`
/// crescente.
///
/// Usado no Painel Admin para listar utilizadores a aguardar aprovação.
final pendingUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchPendingUsers();
});

// ---------------------------------------------------------------------------
// activeUsersProvider
// ---------------------------------------------------------------------------

/// Stream de utilizadores com `status: active`, excluindo o utilizador
/// autenticado atual.
///
/// Usado no Painel Admin para mostrar os utilizadores que podem ser suspensos.
final activeUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchActivePlayers();
});

// ---------------------------------------------------------------------------
// allLocationsProvider
// ---------------------------------------------------------------------------

/// Stream de todas as localizações, sem filtro de `isActive`.
///
/// Usado no Painel Admin para listar e gerir todas as localizações.
final allLocationsProvider = StreamProvider<List<Location>>((ref) {
  return ref.watch(locationRepositoryProvider).watchAllLocations();
});

// ---------------------------------------------------------------------------
// AdminActionsState
// ---------------------------------------------------------------------------

/// Estado das acções administrativas (aprovar, rejeitar, suspender).
class AdminActionsState {
  const AdminActionsState({
    this.isLoading = false,
    this.error,
    this.lastAction,
  });

  /// Indica se uma acção está em curso.
  final bool isLoading;

  /// Mensagem de erro da última acção falhada, ou `null` se não houve erro.
  final String? error;

  /// Identificador da última acção executada: `'approve'`, `'reject'` ou
  /// `'suspend'`.
  final String? lastAction;

  AdminActionsState copyWith({
    bool? isLoading,
    String? error,
    String? lastAction,
  }) {
    return AdminActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

// ---------------------------------------------------------------------------
// AdminActionsNotifier
// ---------------------------------------------------------------------------

/// Notifier que gere o estado das acções administrativas sobre utilizadores.
class AdminActionsNotifier extends StateNotifier<AdminActionsState> {
  AdminActionsNotifier(this._adminRepository)
      : super(const AdminActionsState());

  final AdminRepository _adminRepository;

  /// Aprova o utilizador com [uid] (status → active).
  Future<void> approveUser(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      await _adminRepository.approveUser(uid);
      state = state.copyWith(isLoading: false, lastAction: 'approve');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastAction: 'approve',
      );
    }
  }

  /// Rejeita o utilizador com [uid] (status → rejected).
  Future<void> rejectUser(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      await _adminRepository.rejectUser(uid);
      state = state.copyWith(isLoading: false, lastAction: 'reject');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastAction: 'reject',
      );
    }
  }

  /// Suspende o utilizador com [uid] (status → suspended).
  Future<void> suspendUser(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      await _adminRepository.suspendUser(uid);
      state = state.copyWith(isLoading: false, lastAction: 'suspend');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastAction: 'suspend',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// adminActionsProvider
// ---------------------------------------------------------------------------

/// Provider que expõe o [AdminActionsNotifier] e o seu estado.
///
/// Uso:
/// ```dart
/// // Ler estado
/// final state = ref.watch(adminActionsProvider);
///
/// // Executar acção
/// ref.read(adminActionsProvider.notifier).approveUser(uid);
/// ```
final adminActionsProvider =
    StateNotifierProvider<AdminActionsNotifier, AdminActionsState>((ref) {
  return AdminActionsNotifier(ref.watch(adminRepositoryProvider));
});
