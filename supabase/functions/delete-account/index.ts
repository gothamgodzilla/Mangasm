/**
 * delete-account — App Store Guideline 5.1.1(v) / GDPR.
 * Bearer user JWT required. Purges DMs, then auth.users (profiles cascade).
 *
 * Env: SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY|SUPABASE_ANON_KEY,
 *      SUPABASE_SECRET_KEY|SUPABASE_SERVICE_ROLE_KEY
 */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "Unauthorized" }, 401);
  }

  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const publishable =
    Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
    Deno.env.get("SUPABASE_ANON_KEY") ??
    "";
  const secret =
    Deno.env.get("SUPABASE_SECRET_KEY") ??
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    "";

  if (!url || !publishable || !secret) {
    return json({ error: "Server misconfigured" }, 500);
  }

  const userClient = createClient(url, publishable, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) {
    return json({ error: "Invalid session" }, 401);
  }

  const userId = userData.user.id;
  const admin = createClient(url, secret);

  // Explicit purge before auth delete (block/report/DM leftovers).
  await admin
    .from("messages")
    .delete()
    .or(`sender_id.eq.${userId},recipient_id.eq.${userId}`);
  await admin.from("blocks").delete().eq("blocker_id", userId);
  await admin.from("reports").delete().eq("reporter_id", userId);

  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    return json({ error: deleteError.message }, 500);
  }

  return json({ deleted: true, userId }, 200);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
