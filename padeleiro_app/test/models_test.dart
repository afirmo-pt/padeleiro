import 'package:flutter_test/flutter_test.dart';
import 'package:padeleiro_app/models/match.dart' as m;
import 'package:padeleiro_app/models/location.dart' as loc;

void main() {
  test('MatchTeam toMap/fromMap roundtrip', () {
    final team = m.MatchTeam(
      player1Id: 'p1',
      player1Name: 'Alice',
      player2Id: 'p2',
      player2Name: 'Bob',
    );

    final map = team.toMap();
    final restored = m.MatchTeam.fromMap(map);

    expect(restored.player1Id, equals(team.player1Id));
    expect(restored.player1Name, equals(team.player1Name));
    expect(restored.player2Id, equals(team.player2Id));
    expect(restored.player2Name, equals(team.player2Name));
  });

  test('SetScore toMap/fromMap roundtrip', () {
    final score = m.SetScore(setNumber: 1, teamAScore: 6, teamBScore: 3);
    final map = score.toMap();
    final restored = m.SetScore.fromMap(map);

    expect(restored.setNumber, equals(score.setNumber));
    expect(restored.teamAScore, equals(score.teamAScore));
    expect(restored.teamBScore, equals(score.teamBScore));
  });

  test('Location toMap/fromMap roundtrip', () {
    final location = loc.Location(
      locationId: 'loc1',
      name: 'Court A',
      address: 'Street 1',
      isActive: true,
    );

    final map = location.toMap();
    final restored = loc.Location.fromMap('loc1', map);

    expect(restored.locationId, equals(location.locationId));
    expect(restored.name, equals(location.name));
    expect(restored.address, equals(location.address));
    expect(restored.isActive, equals(location.isActive));
  });
}
