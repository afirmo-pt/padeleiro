// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MatchTeam {
  String get player1Id => throw _privateConstructorUsedError;
  String get player1Name => throw _privateConstructorUsedError;
  String get player2Id => throw _privateConstructorUsedError;
  String get player2Name => throw _privateConstructorUsedError;

  /// Create a copy of MatchTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchTeamCopyWith<MatchTeam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchTeamCopyWith<$Res> {
  factory $MatchTeamCopyWith(MatchTeam value, $Res Function(MatchTeam) then) =
      _$MatchTeamCopyWithImpl<$Res, MatchTeam>;
  @useResult
  $Res call({
    String player1Id,
    String player1Name,
    String player2Id,
    String player2Name,
  });
}

/// @nodoc
class _$MatchTeamCopyWithImpl<$Res, $Val extends MatchTeam>
    implements $MatchTeamCopyWith<$Res> {
  _$MatchTeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? player1Id = null,
    Object? player1Name = null,
    Object? player2Id = null,
    Object? player2Name = null,
  }) {
    return _then(
      _value.copyWith(
            player1Id: null == player1Id
                ? _value.player1Id
                : player1Id // ignore: cast_nullable_to_non_nullable
                      as String,
            player1Name: null == player1Name
                ? _value.player1Name
                : player1Name // ignore: cast_nullable_to_non_nullable
                      as String,
            player2Id: null == player2Id
                ? _value.player2Id
                : player2Id // ignore: cast_nullable_to_non_nullable
                      as String,
            player2Name: null == player2Name
                ? _value.player2Name
                : player2Name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchTeamImplCopyWith<$Res>
    implements $MatchTeamCopyWith<$Res> {
  factory _$$MatchTeamImplCopyWith(
    _$MatchTeamImpl value,
    $Res Function(_$MatchTeamImpl) then,
  ) = __$$MatchTeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String player1Id,
    String player1Name,
    String player2Id,
    String player2Name,
  });
}

/// @nodoc
class __$$MatchTeamImplCopyWithImpl<$Res>
    extends _$MatchTeamCopyWithImpl<$Res, _$MatchTeamImpl>
    implements _$$MatchTeamImplCopyWith<$Res> {
  __$$MatchTeamImplCopyWithImpl(
    _$MatchTeamImpl _value,
    $Res Function(_$MatchTeamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? player1Id = null,
    Object? player1Name = null,
    Object? player2Id = null,
    Object? player2Name = null,
  }) {
    return _then(
      _$MatchTeamImpl(
        player1Id: null == player1Id
            ? _value.player1Id
            : player1Id // ignore: cast_nullable_to_non_nullable
                  as String,
        player1Name: null == player1Name
            ? _value.player1Name
            : player1Name // ignore: cast_nullable_to_non_nullable
                  as String,
        player2Id: null == player2Id
            ? _value.player2Id
            : player2Id // ignore: cast_nullable_to_non_nullable
                  as String,
        player2Name: null == player2Name
            ? _value.player2Name
            : player2Name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MatchTeamImpl implements _MatchTeam {
  const _$MatchTeamImpl({
    required this.player1Id,
    required this.player1Name,
    required this.player2Id,
    required this.player2Name,
  });

  @override
  final String player1Id;
  @override
  final String player1Name;
  @override
  final String player2Id;
  @override
  final String player2Name;

  @override
  String toString() {
    return 'MatchTeam(player1Id: $player1Id, player1Name: $player1Name, player2Id: $player2Id, player2Name: $player2Name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchTeamImpl &&
            (identical(other.player1Id, player1Id) ||
                other.player1Id == player1Id) &&
            (identical(other.player1Name, player1Name) ||
                other.player1Name == player1Name) &&
            (identical(other.player2Id, player2Id) ||
                other.player2Id == player2Id) &&
            (identical(other.player2Name, player2Name) ||
                other.player2Name == player2Name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, player1Id, player1Name, player2Id, player2Name);

  /// Create a copy of MatchTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchTeamImplCopyWith<_$MatchTeamImpl> get copyWith =>
      __$$MatchTeamImplCopyWithImpl<_$MatchTeamImpl>(this, _$identity);
}

abstract class _MatchTeam implements MatchTeam {
  const factory _MatchTeam({
    required final String player1Id,
    required final String player1Name,
    required final String player2Id,
    required final String player2Name,
  }) = _$MatchTeamImpl;

  @override
  String get player1Id;
  @override
  String get player1Name;
  @override
  String get player2Id;
  @override
  String get player2Name;

  /// Create a copy of MatchTeam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchTeamImplCopyWith<_$MatchTeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SetScore {
  int get setNumber => throw _privateConstructorUsedError;
  int get teamAScore => throw _privateConstructorUsedError;
  int get teamBScore => throw _privateConstructorUsedError;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetScoreCopyWith<SetScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetScoreCopyWith<$Res> {
  factory $SetScoreCopyWith(SetScore value, $Res Function(SetScore) then) =
      _$SetScoreCopyWithImpl<$Res, SetScore>;
  @useResult
  $Res call({int setNumber, int teamAScore, int teamBScore});
}

/// @nodoc
class _$SetScoreCopyWithImpl<$Res, $Val extends SetScore>
    implements $SetScoreCopyWith<$Res> {
  _$SetScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? teamAScore = null,
    Object? teamBScore = null,
  }) {
    return _then(
      _value.copyWith(
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            teamAScore: null == teamAScore
                ? _value.teamAScore
                : teamAScore // ignore: cast_nullable_to_non_nullable
                      as int,
            teamBScore: null == teamBScore
                ? _value.teamBScore
                : teamBScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetScoreImplCopyWith<$Res>
    implements $SetScoreCopyWith<$Res> {
  factory _$$SetScoreImplCopyWith(
    _$SetScoreImpl value,
    $Res Function(_$SetScoreImpl) then,
  ) = __$$SetScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int setNumber, int teamAScore, int teamBScore});
}

/// @nodoc
class __$$SetScoreImplCopyWithImpl<$Res>
    extends _$SetScoreCopyWithImpl<$Res, _$SetScoreImpl>
    implements _$$SetScoreImplCopyWith<$Res> {
  __$$SetScoreImplCopyWithImpl(
    _$SetScoreImpl _value,
    $Res Function(_$SetScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? teamAScore = null,
    Object? teamBScore = null,
  }) {
    return _then(
      _$SetScoreImpl(
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        teamAScore: null == teamAScore
            ? _value.teamAScore
            : teamAScore // ignore: cast_nullable_to_non_nullable
                  as int,
        teamBScore: null == teamBScore
            ? _value.teamBScore
            : teamBScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SetScoreImpl implements _SetScore {
  const _$SetScoreImpl({
    required this.setNumber,
    required this.teamAScore,
    required this.teamBScore,
  });

  @override
  final int setNumber;
  @override
  final int teamAScore;
  @override
  final int teamBScore;

  @override
  String toString() {
    return 'SetScore(setNumber: $setNumber, teamAScore: $teamAScore, teamBScore: $teamBScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetScoreImpl &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.teamAScore, teamAScore) ||
                other.teamAScore == teamAScore) &&
            (identical(other.teamBScore, teamBScore) ||
                other.teamBScore == teamBScore));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, setNumber, teamAScore, teamBScore);

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetScoreImplCopyWith<_$SetScoreImpl> get copyWith =>
      __$$SetScoreImplCopyWithImpl<_$SetScoreImpl>(this, _$identity);
}

abstract class _SetScore implements SetScore {
  const factory _SetScore({
    required final int setNumber,
    required final int teamAScore,
    required final int teamBScore,
  }) = _$SetScoreImpl;

  @override
  int get setNumber;
  @override
  int get teamAScore;
  @override
  int get teamBScore;

  /// Create a copy of SetScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetScoreImplCopyWith<_$SetScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Match {
  String get matchId => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  String get locationId => throw _privateConstructorUsedError;
  String get locationName => throw _privateConstructorUsedError;
  MatchTeam get teamA => throw _privateConstructorUsedError;
  MatchTeam get teamB => throw _privateConstructorUsedError;
  List<SetScore>? get scores => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call({
    String matchId,
    MatchStatus status,
    String createdBy,
    DateTime scheduledAt,
    String locationId,
    String locationName,
    MatchTeam teamA,
    MatchTeam teamB,
    List<SetScore>? scores,
    String? winnerId,
  });

  $MatchTeamCopyWith<$Res> get teamA;
  $MatchTeamCopyWith<$Res> get teamB;
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? status = null,
    Object? createdBy = null,
    Object? scheduledAt = null,
    Object? locationId = null,
    Object? locationName = null,
    Object? teamA = null,
    Object? teamB = null,
    Object? scores = freezed,
    Object? winnerId = freezed,
  }) {
    return _then(
      _value.copyWith(
            matchId: null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchStatus,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            locationId: null == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String,
            locationName: null == locationName
                ? _value.locationName
                : locationName // ignore: cast_nullable_to_non_nullable
                      as String,
            teamA: null == teamA
                ? _value.teamA
                : teamA // ignore: cast_nullable_to_non_nullable
                      as MatchTeam,
            teamB: null == teamB
                ? _value.teamB
                : teamB // ignore: cast_nullable_to_non_nullable
                      as MatchTeam,
            scores: freezed == scores
                ? _value.scores
                : scores // ignore: cast_nullable_to_non_nullable
                      as List<SetScore>?,
            winnerId: freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchTeamCopyWith<$Res> get teamA {
    return $MatchTeamCopyWith<$Res>(_value.teamA, (value) {
      return _then(_value.copyWith(teamA: value) as $Val);
    });
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchTeamCopyWith<$Res> get teamB {
    return $MatchTeamCopyWith<$Res>(_value.teamB, (value) {
      return _then(_value.copyWith(teamB: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
    _$MatchImpl value,
    $Res Function(_$MatchImpl) then,
  ) = __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String matchId,
    MatchStatus status,
    String createdBy,
    DateTime scheduledAt,
    String locationId,
    String locationName,
    MatchTeam teamA,
    MatchTeam teamB,
    List<SetScore>? scores,
    String? winnerId,
  });

  @override
  $MatchTeamCopyWith<$Res> get teamA;
  @override
  $MatchTeamCopyWith<$Res> get teamB;
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
    _$MatchImpl _value,
    $Res Function(_$MatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? status = null,
    Object? createdBy = null,
    Object? scheduledAt = null,
    Object? locationId = null,
    Object? locationName = null,
    Object? teamA = null,
    Object? teamB = null,
    Object? scores = freezed,
    Object? winnerId = freezed,
  }) {
    return _then(
      _$MatchImpl(
        matchId: null == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchStatus,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        locationId: null == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String,
        locationName: null == locationName
            ? _value.locationName
            : locationName // ignore: cast_nullable_to_non_nullable
                  as String,
        teamA: null == teamA
            ? _value.teamA
            : teamA // ignore: cast_nullable_to_non_nullable
                  as MatchTeam,
        teamB: null == teamB
            ? _value.teamB
            : teamB // ignore: cast_nullable_to_non_nullable
                  as MatchTeam,
        scores: freezed == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as List<SetScore>?,
        winnerId: freezed == winnerId
            ? _value.winnerId
            : winnerId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MatchImpl implements _Match {
  const _$MatchImpl({
    required this.matchId,
    required this.status,
    required this.createdBy,
    required this.scheduledAt,
    required this.locationId,
    required this.locationName,
    required this.teamA,
    required this.teamB,
    final List<SetScore>? scores,
    this.winnerId,
  }) : _scores = scores;

  @override
  final String matchId;
  @override
  final MatchStatus status;
  @override
  final String createdBy;
  @override
  final DateTime scheduledAt;
  @override
  final String locationId;
  @override
  final String locationName;
  @override
  final MatchTeam teamA;
  @override
  final MatchTeam teamB;
  final List<SetScore>? _scores;
  @override
  List<SetScore>? get scores {
    final value = _scores;
    if (value == null) return null;
    if (_scores is EqualUnmodifiableListView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? winnerId;

  @override
  String toString() {
    return 'Match(matchId: $matchId, status: $status, createdBy: $createdBy, scheduledAt: $scheduledAt, locationId: $locationId, locationName: $locationName, teamA: $teamA, teamB: $teamB, scores: $scores, winnerId: $winnerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.teamA, teamA) || other.teamA == teamA) &&
            (identical(other.teamB, teamB) || other.teamB == teamB) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    matchId,
    status,
    createdBy,
    scheduledAt,
    locationId,
    locationName,
    teamA,
    teamB,
    const DeepCollectionEquality().hash(_scores),
    winnerId,
  );

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);
}

abstract class _Match implements Match {
  const factory _Match({
    required final String matchId,
    required final MatchStatus status,
    required final String createdBy,
    required final DateTime scheduledAt,
    required final String locationId,
    required final String locationName,
    required final MatchTeam teamA,
    required final MatchTeam teamB,
    final List<SetScore>? scores,
    final String? winnerId,
  }) = _$MatchImpl;

  @override
  String get matchId;
  @override
  MatchStatus get status;
  @override
  String get createdBy;
  @override
  DateTime get scheduledAt;
  @override
  String get locationId;
  @override
  String get locationName;
  @override
  MatchTeam get teamA;
  @override
  MatchTeam get teamB;
  @override
  List<SetScore>? get scores;
  @override
  String? get winnerId;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
