import * as admin from 'firebase-admin';
import { onRequest } from 'firebase-functions/v2/https';

/**
 * Temporary function to set admin claim for afirmo@gmail.com.
 * Deploy, call once, then remove.
 * Usage: GET https://<region>-<project>.cloudfunctions.net/setAdminTmp
 */
export const setAdminTmp = onRequest(
  { invoker: 'public' },
  async (_req, res) => {
  try {
    const user = await admin.auth().getUserByEmail('afirmo@gmail.com');
    await admin.auth().setCustomUserClaims(user.uid, { role: 'admin' });
    res.status(200).json({ ok: true, uid: user.uid, email: user.email });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});
