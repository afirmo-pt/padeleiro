import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../../models/location.dart';
import '../../../models/match.dart';
import '../../auth/data/user_repository.dart';
import 'location_repository.dart';
import 'match_repository.dart';

// ---------------------------------------------------------------------------
// Stream providers
// ---------------------------------------------------------------------------

/// Stream de jogadores activos, excluindo o utilizador autenticado.
/// Alimenta a lista de seleção de jogadores no formulário de criação de partida.
final activePlayersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchActivePlayers();
});

/// Stream de localizações com `isActive: true`.
/// Alimenta o dropdown de localização no formulário de criação de partida.
final activeLocationsProvider = StreamProvider<List<Location>>((ref) {
  return ref.watch(locationRepositoryProvider).watchActiveLocations();
});

// ---------------------------------------------------------------------------
// CreateMatchState
// ---------------------------------------------------------------------------

/// Estado do formulário de criação de partida.
class CreateMatchState {
  const CreateMatchState({
    this.selectedPlayers = const [],
    this.teamAPlayers = const [],
    this.teamBPlayers = const [],
    this.selectedLocation,
    this.scheduledAt,
    this.isSubmitting = false,
    this.error,
  });

  /// Jogadores seleccionados para a partida (máximo 4).
  final List<AppUser> selectedPlayers;

  /// Jogadores atribuídos à Equipa A.
  final List<AppUser> teamAPlayers;

  /// Jogadores atribuídos à Equipa B.
  final List<AppUser> teamBPlayers;

  /// Localização seleccionada para a partida.
  final Location? selectedLocation;

  /// Data e hora agendada para a partida.
  final DateTime? scheduledAt;

  /// Indica se a submissão está em curso.
  final bool isSubmitting;

  /// Mensagem de erro, se existir.
  final String? error;

  CreateMatchState copyWith({
    List<AppUser>? selectedPlayers,
    List<AppUser>? teamAPlayers,
    List<AppUser>? teamBPlayers,
    Location? selectedLocation,
    DateTime? scheduledAt,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearLocation = false,
    bool clearScheduledAt = false,
  }) {
    return CreateMatchState(
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      teamAPlayers: teamAPlayers ?? this.teamAPlayers,
      teamBPlayers: teamBPlayers ?? this.teamBPlayers,
      selectedLocation:
          clearLocation ? null : (selectedLocation ?? this.selectedLocation),
      scheduledAt:
          clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// CreateMatchNotifier
// ---------------------------------------------------------------------------

/// Notifier que gere o estado do formulário de criação de partida.
class CreateMatchNotifier extends StateNotifier<CreateMatchState> {
  CreateMatchNotifier(this._matchRepository) : super(const CreateMatchState());

  final MatchRepository _matchRepository;

  /// Adiciona ou remove [player] da lista de jogadores seleccionados.
  /// Máximo de 3 jogadores seleccionados (o criador é o 4.º implícito).
  void togglePlayer(AppUser player) {
    final current = state.selectedPlayers;
    final isSelected = current.any((p) => p.uid == player.uid);

    if (isSelected) {
      // Remover o jogador e também das equipas
      state = state.copyWith(
        selectedPlayers: current.where((p) => p.uid != player.uid).toList(),
        teamAPlayers:
            state.teamAPlayers.where((p) => p.uid != player.uid).toList(),
        teamBPlayers:
            state.teamBPlayers.where((p) => p.uid != player.uid).toList(),
        clearError: true,
      );
    } else {
      if (current.length >= 4) return; // Limite atingido

      final newTeamA = List<AppUser>.from(state.teamAPlayers);
      final newTeamB = List<AppUser>.from(state.teamBPlayers);
      if (newTeamA.length < 2) {
        newTeamA.add(player);
      } else {
        newTeamB.add(player);
      }

      state = state.copyWith(
        selectedPlayers: [...current, player],
        teamAPlayers: newTeamA,
        teamBPlayers: newTeamB,
        clearError: true,
      );
    }
  }

  /// Atribui [player] à equipa indicada por [team] ('teamA' ou 'teamB').
  /// Remove o jogador da equipa oposta se já lá estiver.
  void assignToTeam(AppUser player, String team) {
    assert(team == 'teamA' || team == 'teamB',
        'team deve ser "teamA" ou "teamB"');

    final newTeamA = List<AppUser>.from(state.teamAPlayers);
    final newTeamB = List<AppUser>.from(state.teamBPlayers);

    // Remover das duas equipas antes de reatribuir
    final alreadyInTeamA = newTeamA.any((p) => p.uid == player.uid);
    final alreadyInTeamB = newTeamB.any((p) => p.uid == player.uid);
    newTeamA.removeWhere((p) => p.uid == player.uid);
    newTeamB.removeWhere((p) => p.uid == player.uid);

    if (team == 'teamA') {
      if (!alreadyInTeamA && newTeamA.length >= 2) return;
      newTeamA.add(player);
    } else {
      if (!alreadyInTeamB && newTeamB.length >= 2) return;
      newTeamB.add(player);
    }

    state = state.copyWith(
      teamAPlayers: newTeamA,
      teamBPlayers: newTeamB,
      clearError: true,
    );
  }

  /// Define a localização seleccionada.
  void setLocation(Location location) {
    state = state.copyWith(selectedLocation: location, clearError: true);
  }

  /// Define a data e hora agendada.
  void setScheduledAt(DateTime dateTime) {
    state = state.copyWith(scheduledAt: dateTime, clearError: true);
  }

  /// Submete o formulário e cria a partida no Firestore.
  ///
  /// [createdByUid] é o UID do utilizador autenticado que cria a partida.
  /// Devolve o ID do documento criado em caso de sucesso.
  /// Em caso de erro, actualiza [state.error] e relança a excepção.
  Future<String> submit(String createdByUid) async {
    // Validação básica
    if (state.selectedPlayers.length != 4) {
      state = state.copyWith(
          error: 'Selecciona exactamente 4 jogadores para a partida.');
      throw StateError(state.error!);
    }
    if (state.selectedLocation == null) {
      state = state.copyWith(error: 'Selecciona uma localização.');
      throw StateError(state.error!);
    }
    if (state.scheduledAt == null) {
      state = state.copyWith(error: 'Define a data e hora da partida.');
      throw StateError(state.error!);
    }
    if (state.teamAPlayers.length != 2 || state.teamBPlayers.length != 2) {
      state = state.copyWith(
          error: 'Atribui exactamente 2 jogadores a cada equipa.');
      throw StateError(state.error!);
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final teamA = MatchTeam(
        player1Id: state.teamAPlayers[0].uid,
        player1Name: state.teamAPlayers[0].fullName,
        player2Id: state.teamAPlayers[1].uid,
        player2Name: state.teamAPlayers[1].fullName,
      );
      final teamB = MatchTeam(
        player1Id: state.teamBPlayers[0].uid,
        player1Name: state.teamBPlayers[0].fullName,
        player2Id: state.teamBPlayers[1].uid,
        player2Name: state.teamBPlayers[1].fullName,
      );

      final docRef = await _matchRepository.createMatch(
        CreateMatchPayload(
          scheduledAt: state.scheduledAt!,
          locationId: state.selectedLocation!.locationId,
          locationName: state.selectedLocation!.name,
          teamA: teamA,
          teamB: teamB,
          createdBy: createdByUid,
        ),
      );

      state = state.copyWith(isSubmitting: false);
      return docRef.id;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// ---------------------------------------------------------------------------
// createMatchProvider
// ---------------------------------------------------------------------------

/// Provider que expõe o [CreateMatchNotifier] e o [CreateMatchState].
final createMatchProvider =
    StateNotifierProvider<CreateMatchNotifier, CreateMatchState>((ref) {
  return CreateMatchNotifier(ref.watch(matchRepositoryProvider));
});

/// Provider that loads a single match by its ID.
final matchDetailProvider = FutureProvider.family<Match, String>((ref, matchId) {
  return ref.watch(matchRepositoryProvider).getMatch(matchId);
});
