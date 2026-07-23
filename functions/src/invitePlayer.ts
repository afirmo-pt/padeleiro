import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';

/**
 * Invites an external player by creating their account with a temporary
 * password. Returns the temporary password so the match creator can share it.
 */
export const invitePlayer = onCall(async (request) => {
  const { name, email } = request.data as { name: string; email: string };

  if (!name || !email) {
    throw new HttpsError('invalid-argument', 'Nome e email são obrigatórios.');
  }

  const tempPassword = Math.random().toString(36).slice(2, 10) +
    Math.random().toString(36).toUpperCase().slice(2, 6) + '1!';

  try {
    // Create Firebase Auth user
    const user = await admin.auth().createUser({
      email,
      password: tempPassword,
      displayName: name,
    });

    // Create Firestore user document
    await admin.firestore().collection('users').doc(user.uid).set({
      uid: user.uid,
      email,
      fullName: name,
      phone: '',
      community: '',
      status: 'pending',
      createdAt: FieldValue.serverTimestamp(),
    });

    // Return info so the inviter can share the password
    return {
      uid: user.uid,
      email,
      fullName: name,
      password: tempPassword,
    };
  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Este email já está registado.');
    }
    console.error('Error inviting player:', error);
    throw new HttpsError('internal', 'Erro ao convidar jogador.');
  }
});
