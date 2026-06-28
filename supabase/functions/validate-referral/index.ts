/**
 * validate-referral — record signup with a cartoon referral code.
 *
 * POST { "referrer_code": "TAZ", "referred_user_id": "<uuid>", "ip_hash"?, "device_fp"? }
 *
 * Reward: every 5 completed signups → 1 free month M+ (~$20 value).
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
    return new Response(JSON.stringify({ error: "method_not_allowed" }), {
      status: 405,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  let body: {
    referrer_code?: string;
    referred_user_id?: string;
    ip_hash?: string;
    device_fp?: string;
  };

  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "invalid_json" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const code = body.referrer_code?.trim();
  const referredId = body.referred_user_id?.trim();

  if (!code || !referredId) {
    return new Response(JSON.stringify({ error: "missing_fields" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const { data, error } = await supabase.rpc("record_referral_signup", {
    p_code: code,
    p_referred_id: referredId,
    p_ip_hash: body.ip_hash ?? null,
    p_device_fp: body.device_fp ?? null,
  });

  if (error) {
    const msg = error.message ?? "referral_failed";
    const status =
      msg.includes("invalid_referral_code") ? 404
      : msg.includes("self_referral") || msg.includes("already_referred") ? 409
      : 400;

    return new Response(JSON.stringify({ error: msg }), {
      status,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});