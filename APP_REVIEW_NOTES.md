# App Store Review Notes — Mangasm (com.mangasm.app)

> Paste the **Demo Account** + **Notes** sections below into App Store Connect →
> your version → **App Review Information**. Fill in the password before submitting.

---

## Demo Account (App Review Information → Sign-In required: YES)

> ⚠️ The app is login-gated. Reviewers **cannot** use "Sign in with Apple," so you
> MUST supply a working **email/password** demo login. The Email provider is enabled
> in Supabase, so create one real account and put its credentials here.

```
Username:  review-demo@mangasm.app      (or any mailbox you control)
Password:  __________________________   ← create this; do NOT leave blank
```

The app is sign-in-only (no in-app sign-up): create the account in the Supabase
dashboard (Auth → Users → Add user, with email confirmed), then verify you can
log in with it in the app on a clean install before submitting.

---

## Notes for Reviewer (paste into the Notes field)

Mangasm is a safety-first social app for adult gay men. Sign in with the demo
email/password above (Apple Sign-In also works but requires a personal Apple ID).

This build satisfies Guideline 1.2 (user-generated content) — all four required
controls are present and reachable:

1. **Filter objectionable content** — content moderation/filtering is applied to
   profiles and messages.
2. **Report** — open any chat thread or a match's detail screen → overflow menu →
   "Report." Reports are sent to the backend `file-report` function.
3. **Block** — same chat thread / match detail menu → "Block." The chat thread
   plays a short dissolve animation on all bubbles, then is **removed from the
   inbox** so the blocked member cannot be messaged in that session. Blocked
   users are also filtered from discovery and messaging (BlockPolicy) on later
   sessions. (TestFlight video can show: open chat → ⋯ → Block → dissolve → thread gone.)
4. **Contact / account deletion** — Settings → **Delete Account** permanently
   purges the user's record from the backend (Supabase `delete-account` edge
   function: deletes the auth user; all owned rows cascade via ON DELETE CASCADE),
   then signs out. This satisfies the account-deletion requirement.

**Location privacy:** the app collects **no location data at all** — there is no
CoreLocation usage anywhere in the binary and the privacy manifest declares none.
The "map" on Discover is a stylized illustration, and any location shown on a
member card is self-reported profile text, never GPS.

**Encryption:** transport is standard HTTPS. Direct messages are additionally
end-to-end encrypted on device using Apple CryptoKit's standard algorithms
(Curve25519 sealed boxes) — the server stores ciphertext only. No proprietary
cryptography is used; ITSAppUsesNonExemptEncryption is set to NO because the app
uses only Apple-provided, standard/exempt algorithms.

**Payments:** in-app subscriptions use Apple StoreKit / In-App Purchase. (Any
Stripe code in the project is for the separate web surface only and is not reachable
from this iOS build.)

---

## Pre-submit checklist (the gates that actually block this binary)

- [x] **Team ID — CONFIRMED `854XZ2543V`** (dicklicious@icloud.com, Account Holder).
      project.yml already matches. No change needed. (The `9SCVWDNBJ8` from
      MANGASM_MAP.md was stale — ignore it.)
- [ ] **Provisioning profile** — regenerate the distribution profile for
      `com.mangasm.app` so it includes the **Sign in with Apple** capability
      (entitlement was just added). Fresh Archive under Automatic signing usually
      handles this if the App ID has "Sign in with Apple" enabled.
- [ ] **Deploy** the `delete-account` edge function to the live Supabase project:
      `supabase functions deploy delete-account`
- [x] **In-App Purchases** — code now matches the EXISTING ASC product IDs
      (one M+ tier, two billing lengths): - `Mangasm2cute4u001` → $9.99 / 1 month
        - `Mangasm0001`        → $24.99 / 3 months
      Just confirm both are **"Ready to Submit"** and attached to this version.
      (iOS uses StoreKit, NOT Stripe — confirmed in code.)
- [x] **Age rating** — questionnaire completed in App Store Connect.
- [ ] Privacy nutrition label, screenshots, 1024 icon, privacy policy URL (ASC
      clicks).
- [ ] Demo email/password account created and login-tested on a clean install.
