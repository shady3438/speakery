/**
 * Claims a `usernames/{usernameLower}` document for every account that already
 * had a handle before that collection existed.
 *
 * The sign-up form answers "is this username free?" by reading `usernames`.
 * Accounts created before the collection existed never wrote a document there,
 * so their handles currently read as free and a new account could take one.
 *
 * Safe to run more than once: an existing claim by the same account is left
 * alone, and a claim held by a *different* account is reported, never
 * overwritten.
 *
 *   # See what would happen, change nothing:
 *   npm run backfill-usernames
 *
 *   # Actually write:
 *   npm run backfill-usernames -- --apply
 *
 * Needs admin credentials, the same as the other scripts here:
 *   set GOOGLE_APPLICATION_CREDENTIALS to a service account key file path.
 */
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/** Mirrors _normalizeUsername in lib/presentation/login_screen. */
function normalizeUsername(value) {
  const lowered = String(value || "").toLowerCase().trim().replace(/@/g, "");
  let out = "";
  for (const char of lowered) {
    if (/[a-z0-9_.]/.test(char)) out += char;
  }
  return out;
}

async function main() {
  const apply = process.argv.includes("--apply");

  const snapshot = await db.collection("users").get();
  console.log(`Scanned ${snapshot.size} user document(s).\n`);

  const claimed = [];
  const already = [];
  const conflicts = [];
  const skipped = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const uid = doc.id;
    const handle = normalizeUsername(data.usernameLower || data.username);

    if (!handle || handle.length < 3) {
      skipped.push({ uid, reason: "no usable username" });
      continue;
    }

    const ref = db.collection("usernames").doc(handle);
    const existing = await ref.get();

    if (existing.exists) {
      if (existing.data().uid === uid) {
        already.push({ uid, handle });
      } else {
        conflicts.push({ uid, handle, heldBy: existing.data().uid });
      }
      continue;
    }

    if (apply) {
      await ref.set({
        uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    claimed.push({ uid, handle });
  }

  const verb = apply ? "Claimed" : "Would claim";
  console.log(`${verb} ${claimed.length} handle(s):`);
  for (const item of claimed) console.log(`  ${item.handle}  ->  ${item.uid}`);

  if (already.length) {
    console.log(`\nAlready claimed by the same account (${already.length}):`);
    for (const item of already) console.log(`  ${item.handle}`);
  }

  if (skipped.length) {
    console.log(`\nSkipped (${skipped.length}):`);
    for (const item of skipped) console.log(`  ${item.uid} — ${item.reason}`);
  }

  if (conflicts.length) {
    console.log(`\n!! Conflicts (${conflicts.length}) — nothing was written:`);
    for (const item of conflicts) {
      console.log(`  ${item.handle} is held by ${item.heldBy}, `
        + `but ${item.uid} also claims it`);
    }
    console.log("Resolve these by hand: decide which account keeps the "
      + "handle, change the other, then re-run.");
    process.exitCode = 1;
  }

  if (!apply) {
    console.log("\nDry run. Re-run with --apply to write.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
