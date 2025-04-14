import { onCall } from "firebase-functions/v2/https";
import { google } from "@genkit-ai/ai/google";
import { configureGenkit, generate } from "@genkit-ai/core";

configureGenkit({
  plugins: [google()],
  enableTracingAndMetrics: true,
});

export const supportChatbot = onCall(async (req) => {
  const input = req.data.input;

  const result = await generate({
    model: google.chat("models/gemini-1.5-pro"),
    prompt: `
      You are a hospital customer support bot. Help users with appointments, billing, and doctor info.
      User: ${input}
    `,
  });

  return result.text();
});
