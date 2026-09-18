/**
 * Rewrites `users/{uid}.friends` from usernames to uids.
 *
 * Friendships used to be stored as the friend's username. Usernames are
 * editable, so the moment somebody renamed themselves every friendship
 * pointing at them silently broke — the entry still existed but resolved to
 * nobody. uids never change, so they are the identity now.
 *
 * Entries are matched against `publicProfiles.usernameLower`. An entry that is
 * already a uid is left alone, which makes the script safe to re-run.
 *
 *   # See what would change, write nothing:
 *   npm run migrate-friends
 *
 *   # Actually write:
 *   npm run migrate-friends -- --apply
 *
 * Needs admin credentials, like the other scripts here:
 *   set GOOGLE_APPLICATION_CREDENTIALS to a service account key file path.
 */
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

async function buildUsernameIndex() {
  const byUsername = new Map();
  const uids = new Set();

  const profiles = await db.collection("publicProfiles").get();
  for (const doc of profiles.docs) {
    uids.add(doc.id);
    const data = doc.data();
    for (const key of ["usernameLower", "username"]) {
      const handle = String(data[key] || "").toLowerCase().trim();
      if (handle && !byUsername.has(handle)) byUsername.set(handle, doc.id);
    }
  }

  // Friend requests record the handle each side used at the time, so they are
  // a history of handles that profiles no longer carry. Without this, a friend
  // who renamed themselves cannot be resolved and the entry would be dropped.
  const requests = await db.collection("friendRequests").get();
  for (const doc of requests.docs) {
    const data = doc.data();
    for (const [handleKey, uidKey] of [
      ["fromUsername", "fromUid"],
      ["toUsername", "toUid"],
    ]) {
      const handle = String(data[handleKey] || "").toLowerCase().trim();
      const uid = String(data[uidKey] || "").trim();
      // Current profiles win; this only fills gaps.
      if (handle && uid && !byUsername.has(handle)) byUsername.set(handle, uid);
    }
  }

  return { byUsername, uids };
}

async function main() {
  const apply = process.argv.includes("--apply");
  const { byUsername, uids } = await buildUsernameIndex();
  console.log(`Indexed ${byUsername.size} handle(s) across ${uids.size} `
    + `public profile(s).\n`);

  const snapshot = await db.collection("users").get();
  let changed = 0;
  let untouched = 0;
  const unresolved = [];

  for (const doc of snapshot.docs) {
    const friends = doc.data().friends;
    if (!Array.isArray(friends) || friends.length === 0) continue;

    const next = [];
    const before = [];

    for (const raw of friends) {
      const entry = String(raw || "").trim();
      if (!entry) continue;
      before.push(entry);

      if (uids.has(entry)) {
        // Already a uid.
        if (!next.includes(entry)) next.push(entry);
        continue;
      }

      const mapped = byUsername.get(entry.toLowerCase());
      if (mapped) {
        if (!next.includes(mapped)) next.push(mapped);
      } else {
        // No profile carries this handle any more. Dropping it is the honest
        // outcome: the entry already pointed at nobody.
        unresolved.push({ owner: doc.id, entry });
      }
    }

    const same =
      before.length === next.length && before.every((v, i) => v === next[i]);
    if (same) {
      untouched++;
      continue;
    }

    console.log(`${doc.id}`);
    console.log(`  before: ${JSON.stringify(before)}`);
    console.log(`  after:  ${JSON.stringify(next)}`);
    changed++;

    if (apply) {
      await doc.ref.set({ friends: next }, { merge: true });
    }
  }

  console.log(`\n${apply ? "Rewrote" : "Would rewrite"} ${changed} `
    + `document(s); ${untouched} already correct.`);

  if (unresolved.length) {
    console.log(`\nDropped ${unresolved.length} entry/entries that match no `
      + `profile:`);
    for (const item of unresolved) {
      console.log(`  ${item.owner} -> "${item.entry}"`);
    }
    console.log("These handles belong to nobody; the friendship was already "
      + "dead. Re-add those people from inside the app if needed.");
  }

  if (!apply) console.log("\nDry run. Re-run with --apply to write.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
