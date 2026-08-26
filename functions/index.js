const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");

admin.initializeApp();

const openAiApiKey = defineSecret("OPENAI_API_KEY");
const openAiModel = defineString("OPENAI_MODEL", { default: "gpt-4.1-mini" });

const taskConfig = {
  general: {
    maxOutputTokens: 110,
    system: "Speakery English coach. Give practical feedback in 2 short sentences.",
  },
  writing: {
    maxOutputTokens: 140,
    system: "Speakery writing coach. Give 2 short sentences and one tiny fix.",
  },
  speaking: {
    maxOutputTokens: 120,
    system:
      "Speakery speaking coach. Give 2 short sentences about fluency, clarity, and one next step.",
  },
  listening: {
    maxOutputTokens: 110,
    system:
      "Speakery listening coach. Give 2 short sentences about what to replay and what to notice.",
  },
  chat: {
    maxOutputTokens: 120,
    system:
      "Speakery chat coach. Reply in English. Keep it under 70 words. Give correction or practice based on mode.",
  },
};

function endpoint(task) {
  return onRequest(
    {
      region: "us-central1",
      timeoutSeconds: 30,
      memory: "256MiB",
      secrets: [openAiApiKey],
    },
    async (req, res) => {
      setCors(res);
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }
      if (req.method !== "POST") {
        res.status(405).json({ error: "method_not_allowed" });
        return;
      }

      try {
        const uid = await verifyUser(req);
        const body = normalizeBody(req.body, task);
        const result = await requestOpenAi(task, body.text, body.context);

        await admin.firestore().collection("ai_feedback_logs").add({
          uid,
          feature: task,
          inputChars: body.text.length,
          contextKeys: Object.keys(body.context),
          outputChars: result.length,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        res.status(200).json({ result });
      } catch (error) {
        const status = error.status || 500;
        const message = status >= 500 ? "ai_feedback_failed" : error.message;
        res.status(status).json({ error: message });
      }
    },
  );
}

async function verifyUser(req) {
  const header = req.get("authorization") || "";
  const match = header.match(/^Bearer (.+)$/);
  if (!match) {
    const error = new Error("auth_required");
    error.status = 401;
    throw error;
  }

  try {
    const decoded = await admin.auth().verifyIdToken(match[1]);
    return decoded.uid;
  } catch (_) {
    const error = new Error("invalid_auth");
    error.status = 401;
    throw error;
  }
}

function normalizeBody(raw, task) {
  const body = typeof raw === "object" && raw !== null ? raw : {};
  const text = trimText(String(body.x || body.text || ""), 1200);
  if (!text) {
    const error = new Error("empty_text");
    error.status = 400;
    throw error;
  }

  const requestedTask = String(body.t || task);
  if (requestedTask !== task && requestedTask !== "general") {
    const error = new Error("task_mismatch");
    error.status = 400;
    throw error;
  }

  return {
    text,
    context: compactContext(body.c || body.ctx || {}),
  };
}

async function requestOpenAi(task, text, context) {
  const config = taskConfig[task] || taskConfig.general;
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${openAiApiKey.value()}`,
    },
    body: JSON.stringify({
      model: openAiModel.value(),
      input: [
        { role: "system", content: config.system },
        {
          role: "user",
          content: JSON.stringify({
            text,
            ...(Object.keys(context).length ? { ctx: context } : {}),
          }),
        },
      ],
      temperature: 0.35,
      max_output_tokens: config.maxOutputTokens,
    }),
  });

  if (!response.ok) {
    const error = new Error("provider_error");
    error.status = 502;
    throw error;
  }

  const data = await response.json();
  return extractText(data);
}

function extractText(data) {
  if (typeof data.output_text === "string" && data.output_text.trim()) {
    return data.output_text.trim();
  }

  const buffer = [];
  for (const item of data.output || []) {
    for (const part of item.content || []) {
      if (typeof part.text === "string" && part.text.trim()) {
        buffer.push(part.text.trim());
      }
    }
  }

  if (buffer.length) return buffer.join("\n");

  const error = new Error("empty_provider_response");
  error.status = 502;
  throw error;
}

function compactContext(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  const out = {};
  for (const [key, raw] of Object.entries(value).slice(0, 8)) {
    const cleanKey = trimText(key, 40);
    if (!cleanKey) continue;
    const cleanValue = compactValue(raw);
    if (cleanValue !== null) out[cleanKey] = cleanValue;
  }
  return out;
}

function compactValue(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === "string") return trimText(value, 220) || null;
  if (typeof value === "number" || typeof value === "boolean") return value;
  if (Array.isArray(value)) {
    const items = value.slice(0, 8).map(compactValue).filter((item) => item !== null);
    return items.length ? items : null;
  }
  if (typeof value === "object") return compactContext(value);
  return trimText(String(value), 220) || null;
}

function trimText(value, maxLength) {
  const clean = value.trim();
  return clean.length > maxLength ? clean.slice(0, maxLength).trimEnd() : clean;
}

function setCors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "authorization,content-type");
  res.set("Access-Control-Allow-Methods", "POST,OPTIONS");
}

exports.aiFeedback = endpoint("general");
exports.aiWriting = endpoint("writing");
exports.aiSpeaking = endpoint("speaking");
exports.aiListening = endpoint("listening");
exports.aiChat = endpoint("chat");
