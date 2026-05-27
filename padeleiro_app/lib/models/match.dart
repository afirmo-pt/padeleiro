import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'match.freezed.dart';

@freezed
class MatchTeam with _$MatchTeam {
  const factory MatchTeam({
    required String player1Id,
    required String player1Name,
    required String player2Id,
    required String player2Name,
  }) = _MatchTeam;

  factory MatchTeam.fromMap(Map<String, dynamic> map) {
    return MatchTeam(
      player1Id: map['player1Id'] as String,
      player1Name: map['player1Name'] as String,
      player2Id: map['player2Id'] as String,
      player2Name: map['player2Name'] as String,
    );
  }
}

extension MatchTeamMap on MatchTeam {
  Map<String, dynamic> toMap() {
    return {
      'player1Id': player1Id,
      'player1Name': player1Name,
      'player2Id': player2Id,
      'player2Name': player2Name,
    };
  }
}

@freezed
class SetScore with _$SetScore {
  const factory SetScore({
    required int setNumber,
    required int teamAScore,
    required int teamBScore,
  }) = _SetScore;

  factory SetScore.fromMap(Map<String, dynamic> map) {
    return SetScore(
      setNumber: map['setNumber'] as int,
      teamAScore: map['teamAScore'] as int,
      teamBScore: map['teamBScore'] as int,
    );
  }
}

extension SetScoreMap on SetScore {
  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
    };
  }
}

@freezed
class Match with _$Match {
  const factory Match({
    required String matchId,
    required MatchStatus status,
    required String createdBy,
    required DateTime scheduledAt,
    required String locationId,
    required String locationName,
    required MatchTeam teamA,
    required MatchTeam teamB,
    List<SetScore>? scores,
    String? winnerId,
  }) = _Match;

  factory Match.fromMap(String id, Map<String, dynamic> data) {
    return Match(
      matchId: id,
      status: MatchStatus.values.byName(data['status'] as String),
      createdBy: data['createdBy'] as String,
      scheduledAt: (data['scheduledAt'] as dynamic).toDate() as DateTime,
      locationId: data['locationId'] as String,
      locationName: data['locationName'] as String,
      teamA: MatchTeam.fromMap(data['teamA'] as Map<String, dynamic>),
      teamB: MatchTeam.fromMap(data['teamB'] as Map<String, dynamic>),
      scores: (data['scores'] as List<dynamic>?)
          ?.map((s) => SetScore.fromMap(s as Map<String, dynamic>))
          .toList(),
      winnerId: data['winnerId'] as String?,
    );
  }
}

extension MatchMap on Match {
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'status': status.name,
      'createdBy': createdBy,
      'scheduledAt': scheduledAt,
      'locationId': locationId,
      'locationName': locationName,
      'teamA': teamA.toMap(),
      'teamB': teamB.toMap(),
      if (scores != null) 'scores': scores!.map((s) => s.toMap()).toList(),
      if (winnerId != null) 'winnerId': winnerId,
    };
  }
}
