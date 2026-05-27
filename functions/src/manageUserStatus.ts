import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

type ManageUserStatusAction = 'approve' | 'reject' | 'suspend';

interface ManageUserStatusData {
  uid: string;
  action: ManageUserStatusAction;
}

const VALID_ACTIONS: ManageUserStatusAction[] = ['approve', 'reject', 'suspend'];

const STATUS_MAP: Record<ManageUserStatusAction, string> = {
  approve: 'active',
  reject: 'rejected',
  suspend: 'suspended',
};

export const manageUserStatus = onCall(async (request) => {
  // Verify caller has admin role via custom claim
  if (request.auth?.token.role !== 'admin') {
    throw new HttpsError('permission-denied', 'Requires admin role');
  }

  const data = request.data as Partial<ManageUserStatusData>;

  // Validate uid
  if (!data.uid || typeof data.uid !== 'string' || data.uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'Field "uid" is required and must be a non-empty string');
  }

  // Validate action presence
  if (!data.action) {
    throw new HttpsError('invalid-argument', 'Field "action" is required');
  }

  // Validate action value
  if (!VALID_ACTIONS.includes(data.action as ManageUserStatusAction)) {
    throw new HttpsError(
      'invalid-argument',
      `Field "action" must be one of: ${VALID_ACTIONS.join(', ')}`
    );
  }

  const { uid, action } = data as ManageUserStatusData;

  await admin.firestore().doc(`users/${uid}`).update({ status: STATUS_MAP[action] });
});
