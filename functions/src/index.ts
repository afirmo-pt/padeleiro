import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

admin.initializeApp();

export { onMatchFinalized } from './onMatchFinalized';
export { manageUserStatus } from './manageUserStatus';

// ---------------------------------------------------------------------------
// invitePlayer — creates account for an external player and returns temp password
// ---------------------------------------------------------------------------

export const invitePlayer = onCall(async (request) => {
  const { name, email } = request.data as { name: string; email: string };

  if (!name || !email) {
    throw new HttpsError('invalid-argument', 'Nome e email são obrigatórios.');
  }

  const tempPassword = Math.random().toString(36).slice(2, 10) +
    Math.random().toString(36).toUpperCase().slice(2, 6) + '1!';

  try {
    const user = await admin.auth().createUser({
      email,
      password: tempPassword,
      displayName: name,
    });

    await admin.firestore().collection('users').doc(user.uid).set({
      uid: user.uid,
      email,
      fullName: name,
      phone: '',
      community: '',
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { uid: user.uid, email, fullName: name, password: tempPassword };
  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Este email já está registado.');
    }
    console.error('Error inviting player:', error);
    throw new HttpsError('internal', 'Erro ao convidar jogador.');
  }
});
