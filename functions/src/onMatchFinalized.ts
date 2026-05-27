import * as admin from 'firebase-admin';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';

interface SetScore {
  setNumber: number;
  teamAScore: number;
  teamBScore: number;
}

/**
 * Counts sets won by each team and returns the winner.
 * In case of a tie (shouldn't happen in valid padel matches), defaults to 'teamA'.
 */
function determineWinner(scores: SetScore[]): 'teamA' | 'teamB' {
  let teamAWins = 0;
  let teamBWins = 0;

  for (const set of scores) {
    if (set.teamAScore > set.teamBScore) {
      teamAWins++;
    } else if (set.teamBScore > set.teamAScore) {
      teamBWins++;
    }
  }

  return teamAWins >= teamBWins ? 'teamA' : 'teamB';
}

export const onMatchFinalized = onDocumentUpdated(
  'matches/{matchId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    // Only process the scheduled → completed transition
    if (before?.status !== 'scheduled' || after?.status !== 'completed') return;

    const playerIds: string[] = [
      after.teamA.player1Id,
      after.teamA.player2Id,
      after.teamB.player1Id,
      after.teamB.player2Id,
    ];

    const scores: SetScore[] = after.scores ?? [];
    const winnerId = determineWinner(scores);
    const winnerTeamIds: string[] =
      winnerId === 'teamA'
        ? [after.teamA.player1Id, after.teamA.player2Id]
        : [after.teamB.player1Id, after.teamB.player2Id];

    const db = admin.firestore();
    const batch = db.batch();

    for (const uid of playerIds) {
      const statsRef = db.doc(`user_stats/${uid}`);
      const isWinner = winnerTeamIds.includes(uid);

      // Use set with merge:true so the document is created if it doesn't exist yet
      batch.set(
        statsRef,
        {
          uid,
          totalMatches: FieldValue.increment(1),
          wins: FieldValue.increment(isWinner ? 1 : 0),
          losses: FieldValue.increment(isWinner ? 0 : 1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    await batch.commit();
  }
);
