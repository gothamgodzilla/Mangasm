export const meta = {
  name: 'mangasm-review-claims-audit',
  description: 'Verify every claim in APP_REVIEW_NOTES.md against the Mangasm codebase, then adversarially verify each gap',
  phases: [
    { title: 'Verify claims', detail: 'one agent per review-note claim' },
    { title: 'Adversarial check', detail: 'refute each reported gap' },
    { title: 'Build & test', detail: 'swift build + test suite' },
  ],
}

// Repo root = cwd when the workflow runs from the Mangasm checkout.
const REPO = process.cwd()
const FINDINGS_SCHEMA = {
  type: 'object',
  required: ['claim', 'status', 'evidence', 'gaps'],
  properties: {
    claim: { type: 'string' },
    status: { type: 'string', enum: ['verified', 'partial', 'broken'] },
    evidence: { type: 'array', items: { type: 'string' }, description: 'file:line references proving the status' },
    gaps: {
      type: 'array',
      items: {
        type: 'object',
        required: ['title', 'detail', 'severity'],
        properties: {
          title: { type: 'string' },
          detail: { type: 'string', description: 'what is missing/wrong, with file:line' },
          severity: { type: 'string', enum: ['blocker', 'major', 'minor'] },
          fix: { type: 'string', description: 'concrete suggested fix' },
        },
      },
    },
  },
}
const VERDICT_SCHEMA = {
  type: 'object',
  required: ['isReal', 'reasoning'],
  properties: {
    isReal: { type: 'boolean' },
    reasoning: { type: 'string' },
    corrected_severity: { type: 'string', enum: ['blocker', 'major', 'minor', 'not-an-issue'] },
  },
}

const COMMON = `You are auditing the iOS app repo at ${REPO} (Swift Package + XcodeGen project.yml; sources under Sources/, app shell under App/, backend under supabase/). This audit backs an App Store submission — Apple's reviewer will test each claim, so be precise and cite file:line for everything. Return ONLY the structured output.`

const CLAIMS = [
  {
    key: 'moderation-filter',
    prompt: `${COMMON}
CLAIM (Guideline 1.2 #1): "Filter objectionable content — content moderation/filtering is applied to profiles and messages."
Verify: is there real filtering/moderation logic applied to user-generated content (profiles, messages)? Find the code path, confirm it is actually invoked in the live message-send and profile-display flows (not dead code). Check both client (Swift) and backend (supabase/).`,
  },
  {
    key: 'report-flow',
    prompt: `${COMMON}
CLAIM (Guideline 1.2 #2): "Report — open any chat thread or a match's detail screen → overflow menu → 'Report.' Reports are sent to the backend file-report function."
Verify: (a) Report action exists in BOTH chat thread overflow menu and match detail screen; (b) it actually sends to a backend function named file-report. NOTE: supabase/functions/ contains only delete-account, validate-referral, verify-purchase — no file-report. Determine where reports actually go (a table insert? a missing function? nowhere?). If the claim text is wrong but a working equivalent exists, say so precisely.`,
  },
  {
    key: 'block-flow',
    prompt: `${COMMON}
CLAIM (Guideline 1.2 #3): "Block — same chat thread / match detail menu → 'Block.' The chat thread plays a short dissolve animation on all bubbles, then is removed from the inbox so the blocked member cannot be messaged in that session. Blocked users are also filtered from discovery and messaging (BlockPolicy) on later sessions."
Verify each part: Block action in chat menu AND match detail menu; dissolve animation; thread removed from inbox; BlockPolicy filters discovery AND messaging across sessions (is the block persisted to the backend, or only local?). Cite file:line.`,
  },
  {
    key: 'delete-account',
    prompt: `${COMMON}
CLAIM (Guideline 1.2 #4 / 5.1.1(v)): "Settings → Delete Account permanently purges the user's record (Supabase delete-account edge function: deletes the auth user; all owned rows cascade via ON DELETE CASCADE), then signs out."
Verify: Settings has Delete Account; it calls the delete-account edge function; read supabase/functions/delete-account and confirm it deletes the auth user; check migrations for ON DELETE CASCADE on user-owned tables (profiles, messages, matches, reports, blocks, etc.) — list any user-owned table that would NOT cascade; confirm client signs out after. Cite file:line.`,
  },
  {
    key: 'location-privacy',
    prompt: `${COMMON}
CLAIM: "The map never shows raw GPS. Coordinates are jittered to a neighborhood-level 'privacy zone.'"
Verify: find the jitter/privacy-zone implementation; confirm every code path that displays or uploads location applies it (map display AND any coordinate sent to the backend). Flag any path where raw coordinates leak. Cite file:line.`,
  },
  {
    key: 'compliance-metadata',
    prompt: `${COMMON}
CLAIMS (binary metadata): (a) ITSAppUsesNonExemptEncryption is NO in the Info.plist / project.yml; (b) Team ID in project.yml is 854XZ2543V; (c) Sign in with Apple entitlement is present; (d) an email/password (Supabase email provider) login path exists in the app UI for the reviewer demo account. Verify each, cite file:line.`,
  },
  {
    key: 'iap-storekit',
    prompt: `${COMMON}
CLAIMS (payments): iOS subscriptions use StoreKit with EXACTLY these product IDs: Mangasm2cute4u001 ($9.99/1mo) and Mangasm0001 ($24.99/3mo); no other product IDs referenced; Stripe code is not reachable from the iOS build (web-only). Verify: search for product ID strings in Sources/ and Mangasm.storekit; confirm they match; search for Stripe usage and confirm none is compiled into / reachable from the iOS target. Also check the verify-purchase supabase function for consistency with these product IDs. Cite file:line.`,
  },
]

phase('Verify claims')
const results = await pipeline(
  CLAIMS,
  c => agent(c.prompt, { label: `verify:${c.key}`, phase: 'Verify claims', schema: FINDINGS_SCHEMA }),
  (res, c) => {
    if (!res) return null
    if (!res.gaps || res.gaps.length === 0) return { key: c.key, ...res, confirmedGaps: [] }
    return parallel(res.gaps.map(g => () =>
      agent(`${COMMON}
A first-pass auditor reported this gap about the claim "${res.claim}":
TITLE: ${g.title}
DETAIL: ${g.detail}
SEVERITY: ${g.severity}
Adversarially try to REFUTE it: re-read the cited files and hunt for code the auditor may have missed (different naming, extensions, backend-side enforcement, App/ shell code). If the gap is real, confirm and give the corrected severity from an App Review perspective (blocker = Apple would reject or the claim in review notes is false).`,
        { label: `refute:${c.key}:${g.title.slice(0, 30)}`, phase: 'Adversarial check', schema: VERDICT_SCHEMA })
        .then(v => ({ ...g, verdict: v }))
    )).then(checked => ({
      key: c.key, ...res,
      confirmedGaps: checked.filter(Boolean).filter(x => x.verdict && x.verdict.isReal),
    }))
  }
)

phase('Build & test')
const buildTest = await agent(`In ${REPO}, run the Swift test suite: \`cd ${REPO} && swift test 2>&1 | tail -40\`. Report: did it build, how many tests ran, how many passed/failed, names of any failing tests. If swift test fails to even build, capture the first compile errors. Return structured output only.`, {
  label: 'swift-test',
  phase: 'Build & test',
  schema: {
    type: 'object',
    required: ['built', 'summary'],
    properties: {
      built: { type: 'boolean' },
      testsPassed: { type: 'number' },
      testsFailed: { type: 'number' },
      failingTests: { type: 'array', items: { type: 'string' } },
      summary: { type: 'string' },
    },
  },
})

return { claims: results.filter(Boolean), buildTest }