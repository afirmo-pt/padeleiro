"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMatchFinalized = void 0;
const admin = require("firebase-admin");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
/**
 * Counts sets won by each team and returns the winner.
 * In case of a tie (shouldn't happen in valid padel matches), defaults to 'teamA'.
 */
function determineWinner(scores) {
    let teamAWins = 0;
    let teamBWins = 0;
    for (const set of scores) {
        if (set.teamAScore > set.teamBScore) {
            teamAWins++;
        }
        else if (set.teamBScore > set.teamAScore) {
            teamBWins++;
        }
    }
    return teamAWins >= teamBWins ? 'teamA' : 'teamB';
}
exports.onMatchFinalized = (0, firestore_1.onDocumentUpdated)('matches/{matchId}', async (event) => {
    var _a, _b, _c;
    const before = (_a = event.data) === null || _a === void 0 ? void 0 : _a.before.data();
    const after = (_b = event.data) === null || _b === void 0 ? void 0 : _b.after.data();
    // Only process the scheduled → completed transition
    if ((before === null || before === void 0 ? void 0 : before.status) !== 'scheduled' || (after === null || after === void 0 ? void 0 : after.status) !== 'completed')
        return;
    const playerIds = [
        after.teamA.player1Id,
        after.teamA.player2Id,
        after.teamB.player1Id,
        after.teamB.player2Id,
    ];
    const scores = (_c = after.scores) !== null && _c !== void 0 ? _c : [];
    const winnerId = determineWinner(scores);
    const winnerTeamIds = winnerId === 'teamA'
        ? [after.teamA.player1Id, after.teamA.player2Id]
        : [after.teamB.player1Id, after.teamB.player2Id];
    const db = admin.firestore();
    const batch = db.batch();
    for (const uid of playerIds) {
        const statsRef = db.doc(`user_stats/${uid}`);
        const isWinner = winnerTeamIds.includes(uid);
        // Use set with merge:true so the document is created if it doesn't exist yet
        batch.set(statsRef, {
            uid,
            totalMatches: firestore_2.FieldValue.increment(1),
            wins: firestore_2.FieldValue.increment(isWinner ? 1 : 0),
            losses: firestore_2.FieldValue.increment(isWinner ? 0 : 1),
            updatedAt: firestore_2.FieldValue.serverTimestamp(),
        }, { merge: true });
    }
    await batch.commit();
});
//# sourceMappingURL=onMatchFinalized.js.map