const admin = require("firebase-admin");

admin.initializeApp();

const featureFlags = {
  ai_feedback_endpoints: {
    name: "AI feedback endpoints",
    enabled: true,
  },
  premium_listening_lab: {
    name: "Premium listening lab",
    enabled: true,
  },
  social_feed_posting: {
    name: "Social feed posting",
    enabled: false,
  },
  c2_reading_release: {
    name: "C2 reading release",
    enabled: true,
  },
  admin_audit_logging: {
    name: "Admin audit logging",
    enabled: true,
  },
};

const lessons = {
  grammar_a2_should: {
    type: "Grammar",
    level: "A2",
    state: "Published",
    reportCount: 0,
  },
  reading_c2_efficiency: {
    type: "Reading",
    level: "C2",
    state: "Published",
    reportCount: 0,
  },
  listening_b2_workshop: {
    type: "Listening",
    level: "B2",
    state: "Published",
    reportCount: 0,
  },
};

async function main() {
  const db = admin.firestore();
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const [id, data] of Object.entries(featureFlags)) {
    batch.set(
      db.collection("feature_flags").doc(id),
      {
        ...data,
        updatedAt: now,
      },
      { merge: true },
    );
  }

  for (const [id, data] of Object.entries(lessons)) {
    batch.set(
      db.collection("lessons").doc(id),
      {
        ...data,
        updatedAt: now,
      },
      { merge: true },
    );
  }

  batch.set(db.collection("admin_audit_logs").doc(), {
    action: "admin.seed",
    featureFlagCount: Object.keys(featureFlags).length,
    lessonCount: Object.keys(lessons).length,
    createdAt: now,
  });

  await batch.commit();
  console.log("Seeded admin feature flags and lesson records.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
