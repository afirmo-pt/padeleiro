"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.manageUserStatus = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const VALID_ACTIONS = ['approve', 'reject', 'suspend'];
const STATUS_MAP = {
    approve: 'active',
    reject: 'rejected',
    suspend: 'suspended',
};
exports.manageUserStatus = (0, https_1.onCall)(async (request) => {
    var _a;
    // Verify caller has admin role via custom claim
    if (((_a = request.auth) === null || _a === void 0 ? void 0 : _a.token.role) !== 'admin') {
        throw new https_1.HttpsError('permission-denied', 'Requires admin role');
    }
    const data = request.data;
    // Validate uid
    if (!data.uid || typeof data.uid !== 'string' || data.uid.trim() === '') {
        throw new https_1.HttpsError('invalid-argument', 'Field "uid" is required and must be a non-empty string');
    }
    // Validate action presence
    if (!data.action) {
        throw new https_1.HttpsError('invalid-argument', 'Field "action" is required');
    }
    // Validate action value
    if (!VALID_ACTIONS.includes(data.action)) {
        throw new https_1.HttpsError('invalid-argument', `Field "action" must be one of: ${VALID_ACTIONS.join(', ')}`);
    }
    const { uid, action } = data;
    await admin.firestore().doc(`users/${uid}`).update({ status: STATUS_MAP[action] });
});
//# sourceMappingURL=manageUserStatus.js.map