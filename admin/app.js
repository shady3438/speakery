const state = {
  users: [
    ["u_1042", "Aylin Demir", "B2", "12 day streak", "Active"],
    ["u_1088", "Mert Kaya", "A2", "3 day streak", "Trial"],
    ["u_1190", "Selin Aras", "C1", "28 day streak", "Premium"],
    ["u_1211", "Can Yildiz", "B1", "0 day streak", "At risk"],
  ],
  feedback: [
    ["f_9001", "Writing", "B1 essay feedback", "1,240 tokens", "Reviewed"],
    ["f_9002", "Speaking", "Pronunciation score", "820 tokens", "Open"],
    ["f_9003", "Listening", "Dictation hint", "410 tokens", "Open"],
    ["f_9004", "Chat", "Coach reply", "690 tokens", "Flagged"],
  ],
  content: [
    ["grammar_a2_should", "Grammar", "A2", "Published", "0 reports"],
    ["reading_c2_efficiency", "Reading", "C2", "Published", "0 reports"],
    ["listening_b2_workshop", "Listening", "B2", "Published", "1 report"],
    ["writing_b1_email", "Writing", "B1", "Draft", "0 reports"],
  ],
  costs: [
    ["Writing", 42, "$18.20"],
    ["Speaking", 27, "$11.70"],
    ["Chat", 21, "$9.10"],
    ["Listening", 10, "$4.30"],
  ],
  flags: [
    ["AI feedback endpoints", true, "ai_feedback_endpoints"],
    ["Premium listening lab", true, "premium_listening_lab"],
    ["Social feed posting", false, "social_feed_posting"],
    ["C2 reading release", true, "c2_reading_release"],
    ["Admin audit logging", true, "admin_audit_logging"],
  ],
};

const live = {
  app: null,
  auth: null,
  db: null,
  user: null,
  modules: null,
};

const titles = {
  overview: "Overview",
  users: "Users",
  feedback: "AI Feedback",
  content: "Content",
  flags: "Feature Flags",
};

function renderTable(id, headers, rows) {
  const table = document.getElementById(id);
  if (!rows.length) {
    table.innerHTML = `
      <thead><tr>${headers.map((item) => `<th>${item}</th>`).join("")}</tr></thead>
      <tbody><tr><td colspan="${headers.length}">No records found.</td></tr></tbody>`;
    return;
  }

  table.innerHTML = `
    <thead><tr>${headers.map((item) => `<th>${item}</th>`).join("")}</tr></thead>
    <tbody>
      ${rows
        .map(
          (row) => `
            <tr>
              ${row
                .map((cell, index) =>
                  index === row.length - 1 ? `<td><span class="pill">${cell}</span></td>` : `<td>${cell}</td>`,
                )
                .join("")}
            </tr>`,
        )
        .join("")}
    </tbody>`;
}

function renderCosts() {
  const target = document.getElementById("costBars");
  target.innerHTML = state.costs
    .map(
      ([label, value, cost]) => `
        <div class="bar-row">
          <strong>${label}</strong>
          <div class="bar-track"><div class="bar-fill" style="width:${value}%"></div></div>
          <span>${cost}</span>
        </div>`,
    )
    .join("");
}

function renderFlags() {
  const target = document.getElementById("flagsList");
  target.innerHTML = state.flags
    .map(
      ([label, enabled], index) => `
        <div class="flag-row">
          <div>
            <strong>${label}</strong>
            <small>${enabled ? "Enabled" : "Disabled"}</small>
          </div>
          <button class="switch ${enabled ? "is-on" : ""}" data-flag="${index}" aria-label="${label}">
            <span></span>
          </button>
        </div>`,
    )
    .join("");
}

function setView(view) {
  document.querySelectorAll(".view").forEach((item) => item.classList.remove("is-active"));
  document.querySelectorAll(".nav-item").forEach((item) => item.classList.remove("is-active"));
  document.getElementById(view).classList.add("is-active");
  document.querySelector(`[data-view="${view}"]`).classList.add("is-active");
  document.getElementById("viewTitle").textContent = titles[view];
}

function exportCsv() {
  const active = document.querySelector(".view.is-active").id;
  const rowsByView = {
    users: state.users,
    feedback: state.feedback,
    content: state.content,
    flags: state.flags.map(([name, enabled, id]) => [id || name, name, enabled ? "enabled" : "disabled"]),
    overview: state.costs,
  };
  const rows = rowsByView[active] || [];
  const csv = rows.map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(",")).join("\n");
  const blob = new Blob([csv], { type: "text/csv" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `speakery-${active}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

document.querySelectorAll(".nav-item").forEach((button) => {
  button.addEventListener("click", () => setView(button.dataset.view));
});

document.getElementById("flagsList").addEventListener("click", (event) => {
  const button = event.target.closest("[data-flag]");
  if (!button) return;
  const index = Number(button.dataset.flag);
  state.flags[index][1] = !state.flags[index][1];
  renderFlags();
});

document.getElementById("searchInput").addEventListener("input", (event) => {
  const query = event.target.value.trim().toLowerCase();
  const filterRows = (rows) => rows.filter((row) => row.join(" ").toLowerCase().includes(query));
  renderTable("usersTable", ["ID", "Name", "Level", "Progress", "Status"], filterRows(state.users));
  renderTable("feedbackTable", ["ID", "Feature", "Item", "Usage", "Status"], filterRows(state.feedback));
  renderTable("contentTable", ["ID", "Type", "Level", "State", "Reports"], filterRows(state.content));
});

document.getElementById("exportButton").addEventListener("click", exportCsv);
document.getElementById("saveFlags").addEventListener("click", saveFlags);

renderTable("usersTable", ["ID", "Name", "Level", "Progress", "Status"], state.users);
renderTable("feedbackTable", ["ID", "Feature", "Item", "Usage", "Status"], state.feedback);
renderTable("contentTable", ["ID", "Type", "Level", "State", "Reports"], state.content);
renderCosts();
renderFlags();
initFirebase();

async function initFirebase() {
  const config = window.SPEAKERY_FIREBASE_CONFIG;
  const status = document.getElementById("authStatus");
  const loginButton = document.getElementById("loginButton");

  if (!config || !config.apiKey || config.apiKey === "replace-me") {
    status.textContent = "Mock mode";
    loginButton.disabled = true;
    return;
  }

  try {
    const [appModule, authModule, firestoreModule] = await Promise.all([
      import("https://www.gstatic.com/firebasejs/10.13.2/firebase-app.js"),
      import("https://www.gstatic.com/firebasejs/10.13.2/firebase-auth.js"),
      import("https://www.gstatic.com/firebasejs/10.13.2/firebase-firestore.js"),
    ]);

    live.modules = { appModule, authModule, firestoreModule };
    live.app = appModule.initializeApp(config);
    live.auth = authModule.getAuth(live.app);
    live.db = firestoreModule.getFirestore(live.app);

    loginButton.addEventListener("click", toggleLogin);
    authModule.onAuthStateChanged(live.auth, async (user) => {
      live.user = user;
      if (!user) {
        status.textContent = "Signed out";
        loginButton.textContent = "Sign in";
        return;
      }

      loginButton.textContent = "Sign out";
      const token = await user.getIdTokenResult();
      const isAdmin = token.claims.admin === true;
      status.textContent = isAdmin ? `Admin: ${user.email}` : `No admin claim: ${user.email}`;
      if (isAdmin) await loadLiveData();
    });
  } catch (error) {
    status.textContent = "Mock mode";
    console.warn("Firebase admin mode unavailable", error);
  }
}

async function toggleLogin() {
  const { authModule } = live.modules;
  if (live.user) {
    await authModule.signOut(live.auth);
    return;
  }

  const provider = new authModule.GoogleAuthProvider();
  await authModule.signInWithPopup(live.auth, provider);
}

async function loadLiveData() {
  const { firestoreModule } = live.modules;
  const { collection, getDocs, limit, orderBy, query } = firestoreModule;

  const [users, feedback, content, flags] = await Promise.allSettled([
    getDocs(query(collection(live.db, "users"), limit(50))),
    getDocs(query(collection(live.db, "ai_feedback_logs"), orderBy("createdAt", "desc"), limit(50))),
    getDocs(query(collection(live.db, "lessons"), limit(50))),
    getDocs(query(collection(live.db, "feature_flags"), limit(50))),
  ]);

  if (users.status === "fulfilled") {
    state.users = users.value.docs.map((doc) => {
      const data = doc.data();
      return [
        doc.id,
        data.name || data.email || "Unnamed",
        data.level || "-",
        `${data.streak || 0} day streak`,
        data.isPremium ? "Premium" : "Active",
      ];
    });
  }

  if (feedback.status === "fulfilled") {
    state.feedback = feedback.value.docs.map((doc) => {
      const data = doc.data();
      return [
        doc.id,
        data.feature || "-",
        data.uid || "-",
        `${data.inputChars || 0}/${data.outputChars || 0} chars`,
        data.status || "Logged",
      ];
    });
  }

  if (content.status === "fulfilled") {
    state.content = content.value.docs.map((doc) => {
      const data = doc.data();
      return [
        doc.id,
        data.type || "Lesson",
        data.level || "-",
        data.state || "Published",
        `${data.reportCount || 0} reports`,
      ];
    });
  }

  if (flags.status === "fulfilled") {
    state.flags = flags.value.docs.map((doc) => {
      const data = doc.data();
      return [data.name || doc.id, data.enabled === true, doc.id];
    });
  }

  renderTable("usersTable", ["ID", "Name", "Level", "Progress", "Status"], state.users);
  renderTable("feedbackTable", ["ID", "Feature", "Item", "Usage", "Status"], state.feedback);
  renderTable("contentTable", ["ID", "Type", "Level", "State", "Reports"], state.content);
  renderFlags();
}

async function saveFlags() {
  const status = document.getElementById("authStatus");
  if (!live.user || !live.modules?.firestoreModule) {
    status.textContent = "Mock flags updated locally";
    return;
  }

  const token = await live.user.getIdTokenResult();
  if (token.claims.admin !== true) {
    status.textContent = "Admin claim required";
    return;
  }

  const { doc, serverTimestamp, setDoc, writeBatch, collection } = live.modules.firestoreModule;
  const batch = writeBatch(live.db);
  for (const [name, enabled, id] of state.flags) {
    const flagId = id || slug(name);
    batch.set(
      doc(live.db, "feature_flags", flagId),
      {
        name,
        enabled,
        updatedAt: serverTimestamp(),
        updatedBy: live.user.uid,
      },
      { merge: true },
    );
  }

  batch.set(doc(collection(live.db, "admin_audit_logs")), {
    action: "feature_flags.update",
    uid: live.user.uid,
    email: live.user.email,
    count: state.flags.length,
    createdAt: serverTimestamp(),
  });

  await batch.commit();
  status.textContent = `Flags saved: ${live.user.email}`;
}

function slug(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}
