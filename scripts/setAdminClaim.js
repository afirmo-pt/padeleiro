const admin = require('firebase-admin');
const fs = require('fs');

if (process.argv.length < 3) {
  console.error('Usage: node scripts/setAdminClaim.js <USER_UID> [serviceAccountPath]');
  process.exit(1);
}

const uid = process.argv[2];
const saPath = process.argv[3] || process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!saPath || !fs.existsSync(saPath)) {
  console.error('Service account JSON path is required (env GOOGLE_APPLICATION_CREDENTIALS or argument).');
  process.exit(1);
}

const serviceAccount = require(saPath);

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

async function setAdmin(u) {
  try {
    await admin.auth().setCustomUserClaims(u, { role: 'admin' });
    console.log('Set admin claim for', u);
    process.exit(0);
  } catch (err) {
    console.error('Error setting admin claim:', err);
    process.exit(2);
  }
}

setAdmin(uid);
