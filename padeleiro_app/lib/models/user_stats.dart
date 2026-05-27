import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required String uid,
    required int totalMatches,
    required int wins,
    required int losses,
  }) = _UserStats;

  factory UserStats.fromMap(String id, Map<String, dynamic> data) {
    return UserStats(
      uid: id,
      totalMatches: data['totalMatches'] as int? ?? 0,
      wins: data['wins'] as int? ?? 0,
      losses: data['losses'] as int? ?? 0,
    );
  }
}

extension UserStatsMap on UserStats {
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
    };
  }
}
