const admin = require("firebase-admin");

admin.initializeApp();

async function main() {
  const email = process.argv[2];
  const value = process.argv[3] !== "false";

  if (!email) {
    console.error("Usage: npm run set-admin -- user@example.com [true|false]");
    process.exitCode = 1;
    return;
  }

  const user = await admin.auth().getUserByEmail(email);
  const claims = {
    ...(user.customClaims || {}),
    admin: value,
  };

  await admin.auth().setCustomUserClaims(user.uid, claims);
  await admin.firestore().collection("admin_audit_logs").add({
    action: value ? "admin.grant" : "admin.revoke",
    targetUid: user.uid,
    targetEmail: email,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`${value ? "Granted" : "Revoked"} admin claim for ${email}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
