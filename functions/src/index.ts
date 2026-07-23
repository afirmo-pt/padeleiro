import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

admin.initializeApp();

export { onMatchFinalized } from './onMatchFinalized';
export { manageUserStatus } from './manageUserStatus';
export { invitePlayer } from './invitePlayer';
