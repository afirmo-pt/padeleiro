import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';

// Web API key for Firebase Auth REST API (sends password reset email)
const WEB_API_KEY = 'AIzaSyDL9QslCJFsviPXEjA7P21ozHIrMoqDQLE';

/**
 * Invites an external player by creating their account and sending a
 * password reset email so they can set their own password and log in.
 */
export const invitePlayer = onCall(async (request) => {
  const { name, email } = request.data as { name: string; email: string };

  if (!name || !email) {
    throw new HttpsError('invalid-argument', 'Nome e email são obrigatórios.');
  }

  // 1. Generate a random temporary password
  const tempPassword = Math.random().toString(36).slice(2, 10) +
    Math.random().toString(36).toUpperCase().slice(2, 6) + '1!';

  try {
    // 2. Create Firebase Auth user
    const user = await admin.auth().createUser({
      email,
      password: tempPassword,
      displayName: name,
    });

    // 3. Create Firestore user document with status 'pending'
    await admin.firestore().collection('users').doc(user.uid).set({
      uid: user.uid,
      email,
      fullName: name,
      phone: '',
      community: '',
      status: 'pending',
      createdAt: FieldValue.serverTimestamp(),
    });

    // 4. Send password reset email via Firebase Auth REST API
    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${WEB_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          requestType: 'PASSWORD_RESET',
          email,
        }),
      }
    );

    const result = await response.json() as Record<string, unknown>;

    if (!response.ok) {
      console.error('Error sending password reset email:', result);
    }

    return {
      uid: user.uid,
      email,
      fullName: name,
    };
  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Este email já está registado.');
    }
    console.error('Error inviting player:', error);
    throw new HttpsError('internal', 'Erro ao convidar jogador.');
  }
});
