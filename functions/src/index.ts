import * as admin from 'firebase-admin';

admin.initializeApp();

export { onMatchFinalized } from './onMatchFinalized';
export { manageUserStatus } from './manageUserStatus';
export { invitePlayer } from './invitePlayer';
