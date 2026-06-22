# Mangasm — Illustrative Revenue Projection & Business Model

**Last updated:** 2026-06-21
**Status:** Planning document — internal use only

---

## Framing Disclaimer

> **This is an illustrative financial model built on stated planning assumptions. It is NOT a financial forecast, a representation of expected results, or investment advice. All figures are rough order-of-magnitude estimates drawn from comparable app market data and publicly available dating-app benchmarks. Actual results will vary — potentially materially — based on execution, market conditions, App Store policies, and factors outside the founders' control. Do not use this document to make investment or capital-allocation decisions without independent financial and legal review.**

---

## 1. Market Sizing

All figures are rough order-of-magnitude assumptions based on publicly reported dating-app market research and LGBTQ+ demographic studies. They are not independently verified.

| Market Level | Definition | Rough Size | Source basis |
|---|---|---|---|
| **TAM** — Total Addressable Market | Global gay/bisexual men aged 21–55 with smartphone access | ~120–150M people | Kinsey-range estimates × global mobile penetration |
| **SAM** — Serviceable Addressable Market | Gay men in cities where Mangasm targets (Dubai, London, Mykonos, Tokyo + 20 comparable cities globally); English/emoji-capable; aged 25–45 | ~8–12M people | Urbanization × affluence overlap |
| **SOM** — Serviceable Obtainable Market (Yr 1–3) | High-affinity early adopters: "dark luxury" aesthetic buyers, nightlife/jet-set, privacy-sensitive, willing to pay premium | **50K–500K registered users** (Year 1–3 ramp, see scenarios) | Comparable niche dating app launches (Raya, Feeld, The League) |

**Premium/affluent segment note:** Raya (members-only, ~$8/mo) reported ~750K applications and ~100K members globally after several years. The League reached ~1M registered users but modest paid conversion. Mangasm's niche is narrower and higher-intent; the invite-only gate compresses TAM but raises conversion and retention.

---

## 2. Monetization

### 2.1 Primary: M+ Subscription — $9.99/month

| Item | Value |
|---|---|
| List price | $9.99/month |
| Apple IAP cut — Year 1 | 30% → Apple takes $3.00/mo |
| Apple IAP cut — After Year 1 (Small Business Program, if revenue < $1M/yr) | 15% → Apple takes $1.50/mo |
| **Net revenue per sub — Year 1** | **$6.99/mo** |
| **Net revenue per sub — Year 2+ (SBP)** | **$8.49/mo** |

> Apple's Small Business Program reduces the commission to 15% for developers earning under $1M/year through the App Store. Once annual App Store billings exceed $1M, the standard 30% rate applies until the following year. These rates apply to subscriptions in the first year of each subscriber's subscription; renewal commissions are 15% regardless of SBP status.

### 2.2 Hypothetical Future Revenue Lines (not in base model)

The following are speculative and excluded from the primary scenarios below. Include in sensitivity analysis only.

| Line | Mechanism | Rough economics |
|---|---|---|
| Annual plan | $89.99/yr (~25% discount vs. monthly) | Improves cash flow, reduces monthly churn; modeled as 20% of subs opting in at Year 2 |
| Event hosting fee | M+ hosts can charge for events; Mangasm takes 10–15% of ticket revenue | Highly variable; excluded |
| À-la-carte boosts | Profile boost, priority AI match queue — $2.99–$4.99 each | Could add 5–10% to ARPU at scale; excluded |
| Brand partnerships | Private-label events with luxury brands | Non-recurring; excluded |

---

## 3. Funnel & Unit Economics

### 3.1 Conversion Assumptions

Dating apps are notorious for high CAC and churn. Assumptions below are benchmarked against industry data (Bumble, Hinge, Grindr SEC filings; Raya/Feeld press reports).

| Funnel Stage | Conservative | Base | Aggressive |
|---|---|---|---|
| App store impression → install | 3% | 5% | 8% |
| Install → signup (completes onboarding) | 40% | 55% | 70% |
| Signup → activated (sends 1+ message or likes 3+ profiles) | 50% | 60% | 70% |
| Activated → paid (M+) conversion | 2% | 5% | 9% |
| **Blended install → paid** | **~0.4%** | **~1.7%** | **~4.0%** |

> Industry benchmark: premium dating apps with a clear value prop see 3–8% paid conversion of activated users. Grindr reported ~7% paying users of MAU (2022). Niche/invite-only apps run higher (8–15%) on a smaller base. We use 5% base as a mid-point, noting the invite gate helps quality but limits volume.

### 3.2 Churn

| Metric | Conservative | Base | Aggressive |
|---|---|---|---|
| Monthly subscriber churn | 10% | 7% | 5% |
| Implied avg. subscription length | ~10 months | ~14 months | ~20 months |

> Dating app median monthly churn runs 8–12%. Users find a partner, lose interest, or switch apps. A tight community with active events and high-quality matches retains better — hence the lower bound at 5%.

### 3.3 Unit Economics

All figures use Year 2+ net revenue per sub ($8.49/mo) for long-term metrics; Year 1 figures use $6.99/mo net.

| Metric | Conservative | Base | Aggressive |
|---|---|---|---|
| ARPU (paid subs, net of Apple) | $6.99/mo | $8.49/mo | $8.49/mo |
| Monthly churn | 10% | 7% | 5% |
| **LTV = ARPU / churn** | **$69.90** | **$121.29** | **$169.80** |
| Blended CAC (paid social + influencer + PR) | $35 | $25 | $15 |
| **LTV : CAC** | **2.0x** | **4.9x** | **11.3x** |
| Payback period | ~5 months | ~3 months | ~1.8 months |

> CAC estimates: Grindr's blended CAC was reported ~$5–$12 (2021, mature network). Newer niche apps spend $20–$60 via paid social. We assume $25 base — achievable with strong organic/influencer channels in the gay nightlife and luxury lifestyle community. Conservative assumes higher spend on paid acquisition.

> LTV:CAC rule of thumb: >3x is generally considered healthy for a subscription business. Base scenario passes this threshold; conservative does not — meaning the conservative scenario requires CAC reduction or churn improvement to be viable long-term.

---

## 4. Three-Scenario Financial Model

### 4.1 Shared Infrastructure Cost Assumptions

| Cost Item | Assumption | Monthly at 10K MAU | Monthly at 50K MAU | Monthly at 150K MAU |
|---|---|---|---|---|
| Supabase (DB, Auth, Storage, Realtime) | Pro plan + scaling | ~$100 | ~$400 | ~$1,200 |
| Push notifications (APNs) | Free via Apple | $0 | $0 | $0 |
| AI matching / moderation API (Claude/GPT) | ~$0.003–$0.01/user/day | ~$900 | ~$4,500 | ~$13,500 |
| Media storage / CDN | S3-compatible, ~$0.02/GB | ~$50 | ~$250 | ~$750 |
| Transactional email (Resend) | ~$0.001/email | ~$20 | ~$100 | ~$300 |
| SMS / verification (Twilio) | ~$0.0075/SMS, 1 per new user | ~$75 (10K new) | ~$375 | ~$1,125 |
| **Total infra/mo** | | **~$1,145** | **~$5,625** | **~$16,875** |
| **Infra per MAU/mo** | | **~$0.11** | **~$0.11** | **~$0.11** |

### 4.2 Headcount / Operating Costs (Months 1–12)

| Role | Conservative | Base | Aggressive |
|---|---|---|---|
| Founders (unpaid or deferred) | 2 FT | 2 FT | 2 FT |
| iOS engineer (contract) | Part-time (~$4K/mo) | 1 FT ($10K/mo) | 2 FT ($20K/mo) |
| Trust & Safety / moderation | 1 part-time ($2K/mo) | 1 FT ($5K/mo) | 2 FT ($10K/mo) |
| Community / growth | 0 | Part-time ($2K/mo) | 1 FT ($8K/mo) |
| **Total people cost/mo** | **~$6K** | **~$17K** | **~$38K** |

> Trust & Safety is non-negotiable for a safety-first gay dating app. Moderation, AI behavior monitoring, and reputation system maintenance require dedicated headcount from launch.

---

### 4.3 Scenario A — Conservative (invite-only, slow organic growth)

**Assumption:** Word-of-mouth only, limited paid acquisition. Invite gate restricts growth. Churn 10%/mo.

| Month | MAU | Paid Subs | MRR (gross) | MRR (net, Y1 @$6.99) | Infra | People | Net Monthly Cash |
|---|---|---|---|---|---|---|---|
| M3 | 500 | 10 | $100 | $70 | $55 | $6,000 | -$5,985 |
| M6 | 2,000 | 40 | $400 | $280 | $220 | $6,000 | -$5,940 |
| M9 | 5,000 | 100 | $1,000 | $700 | $550 | $6,000 | -$5,850 |
| M12 | 8,000 | 160 | $1,598 | $1,119 | $880 | $6,000 | -$5,761 |
| M18 | 12,000 | 240 | $2,398 | $2,036* | $1,320 | $7,000 | -$6,284 |
| M24 | 18,000 | 360 | $3,596 | $3,053* | $1,980 | $8,000 | -$6,927 |
| M36 | 30,000 | 600 | $5,994 | $5,089* | $3,300 | $10,000 | -$8,211 |

*Year 2+ net rate $8.49/mo applied from M13.

**12-month ARR (Conservative): ~$13,400** (annualizing M12 MRR net)
**Break-even MAU estimate:** ~180,000+ paid subs needed at this cost structure — not achievable without investment or major cost reduction.

---

### 4.4 Scenario B — Base (targeted paid + strong community)

**Assumption:** $25K/mo acquisition spend from M3 onward (~1,000 installs/mo from paid + organic). 7% churn. Events and nightlife partnerships drive organic.

| Month | MAU | Paid Subs | MRR (gross) | MRR (net) | Infra | People | CAC Spend | Net Monthly Cash |
|---|---|---|---|---|---|---|---|---|
| M3 | 2,000 | 100 | $999 | $699 | $220 | $17,000 | $10,000 | -$26,521 |
| M6 | 8,000 | 400 | $3,996 | $2,797 | $880 | $17,000 | $15,000 | -$30,083 |
| M9 | 18,000 | 900 | $8,991 | $6,294 | $1,980 | $17,000 | $15,000 | -$27,686 |
| M12 | 30,000 | 1,500 | $14,985 | $10,490 | $3,300 | $17,000 | $15,000 | -$24,810 |
| M18 | 50,000 | 2,500 | $24,975 | $21,225* | $5,500 | $20,000 | $15,000 | -$19,275 |
| M24 | 75,000 | 3,750 | $37,463 | $31,816* | $8,250 | $22,000 | $12,000 | -$10,434 |
| M30 | 100,000 | 5,000 | $49,950 | $42,421* | $11,000 | $25,000 | $10,000 | **+$6,421** |
| M36 | 130,000 | 6,500 | $64,935 | $55,148* | $14,300 | $28,000 | $10,000 | **+$12,848** |

*Year 2+ net rate $8.49/mo.

**12-month ARR (Base): ~$126,000** (annualizing M12 MRR net)
**Break-even point (Base scenario):** approximately Month 28–30 on a cash-flow basis.
**36-month ARR (Base): ~$662,000**

---

### 4.5 Scenario C — Aggressive (viral launch, influencer + PR)

**Assumption:** High-profile gay influencer partnerships, luxury press coverage, major city launch events. 5% churn. $50K/mo acquisition spend months 1–6, tapering to $20K from M7.

| Month | MAU | Paid Subs | MRR (gross) | MRR (net) | Infra | People | CAC Spend | Net Monthly Cash |
|---|---|---|---|---|---|---|---|---|
| M3 | 10,000 | 900 | $8,991 | $6,294 | $1,100 | $38,000 | $50,000 | -$82,806 |
| M6 | 35,000 | 3,150 | $31,469 | $22,028 | $3,850 | $38,000 | $50,000 | -$69,822 |
| M9 | 70,000 | 6,300 | $62,937 | $44,056 | $7,700 | $38,000 | $20,000 | -$21,644 |
| M12 | 110,000 | 9,900 | $98,901 | $69,231 | $12,100 | $38,000 | $20,000 | **-$869** |
| M18 | 180,000 | 16,200 | $161,838 | $137,480* | $19,800 | $45,000 | $15,000 | **+$57,680** |
| M24 | 250,000 | 22,500 | $224,775 | $190,974* | $27,500 | $55,000 | $12,000 | **+$96,474** |
| M36 | 400,000 | 36,000 | $359,640 | $305,454* | $44,000 | $75,000 | $10,000 | **+$176,454** |

*Year 2+ net rate $8.49/mo. Note: at >$1M annual App Store billings, Apple's 30% rate re-applies — this would affect M18+ in aggressive scenario and is not modeled above (would reduce net by ~$1.50/sub/mo, impacting MRR by ~$24K/mo at M18 scale).

**12-month ARR (Aggressive): ~$831,000** (annualizing M12 MRR net)
**Break-even point (Aggressive scenario):** approximately Month 12.
**36-month ARR (Aggressive): ~$3.66M**

---

## 5. Summary Table — Scenario Comparison

| Metric | Conservative | Base | Aggressive |
|---|---|---|---|
| MAU at Month 12 | 8,000 | 30,000 | 110,000 |
| Paid subs at Month 12 | 160 | 1,500 | 9,900 |
| MRR (net) at Month 12 | ~$1,119 | ~$10,490 | ~$69,231 |
| **ARR at Month 12** | **~$13,400** | **~$126,000** | **~$831,000** |
| MAU at Month 36 | 30,000 | 130,000 | 400,000 |
| Paid subs at Month 36 | 600 | 6,500 | 36,000 |
| MRR (net) at Month 36 | ~$5,089 | ~$55,148 | ~$305,454 |
| **ARR at Month 36** | **~$61,000** | **~$662,000** | **~$3.66M** |
| Cash flow break-even | Not modeled (requires funding) | ~Month 28–30 | ~Month 12 |
| Estimated runway needed (pre-break-even) | $500K+ (never profitable without restructuring) | $600–800K | $800K–1.2M |
| LTV:CAC | 2.0x (below threshold) | 4.9x | 11.3x |

---

## 6. Cost Model Summary

### Gross Margin (after Apple, before infra and people)

| Scenario | Y1 Gross Margin % | Y2+ Gross Margin % |
|---|---|---|
| Conservative | 70% (Apple 30%) → ~70% | 85% (Apple 15% SBP) |
| Base | 70% Y1 → 85% Y2 | 85% |
| Aggressive | 70% Y1 → ~70%* Y2 | ~70%* (>$1M threshold) |

*Aggressive scenario likely exceeds $1M App Store billings in Year 2, reverting to 30% Apple commission.

### Infrastructure Scaling

| MAU Band | Estimated Monthly Infra | Per-MAU Cost |
|---|---|---|
| 0–10K | $1,000–1,500 | $0.10–0.15 |
| 10K–50K | $1,500–6,000 | $0.10–0.12 |
| 50K–150K | $6,000–18,000 | $0.10–0.12 |
| 150K–500K | $18,000–55,000 | $0.09–0.11 |

Infrastructure scales sub-linearly — a positive characteristic of the Supabase-native architecture.

### Moderation & Trust & Safety

This cost scales with content volume, not linearly with users. Estimate:

| MAU Band | T&S Cost/mo | Basis |
|---|---|---|
| <10K | $2,000 | 1 part-time moderator + AI tools |
| 10K–50K | $5,000–8,000 | 1 FT moderator + AI pipeline |
| 50K–200K | $10,000–20,000 | 2–3 FT + tooling |
| >200K | $25,000+ | Dedicated team; legal/compliance layer |

> Trust & Safety is a cost center that must be funded ahead of scale on a safety-first platform. Under-investment here is a brand and legal risk, not a savings.

---

## 7. Key Sensitivities & Break-Even Analysis

### The Three Levers That Move This Model Most

**1. Monthly churn rate (highest sensitivity)**

Churn is the single most impactful variable. The relationship is non-linear:

| Monthly Churn | Implied LTV (Base ARPU $8.49) | LTV:CAC ($25 CAC) | Break-even subs |
|---|---|---|---|
| 12% | $70.75 | 2.8x (borderline) | ~40,000 |
| 8% | $106.13 | 4.2x | ~27,000 |
| 5% | $169.80 | 6.8x | ~17,000 |
| 3% | $283.00 | 11.3x | ~10,000 |

Reducing churn from 8% to 5% effectively doubles LTV. The invite-only gate, events, and community features are churn-reduction investments, not just marketing.

**2. Paid conversion rate (second-highest sensitivity)**

The invite gate increases conversion by filtering for intent, but also limits install volume. The tension:

| Paid Conversion | Paid subs per 10K installs | MRR per 10K installs (net) |
|---|---|---|
| 2% (conservative) | 200 | $1,698 |
| 5% (base) | 500 | $4,245 |
| 9% (aggressive) | 900 | $7,641 |

A 1-percentage-point improvement in conversion rate is worth ~$849/mo per 10,000 installs at base ARPU. Paywall placement, M+ value demonstration, and free-tier limitations are the design levers.

**3. Customer acquisition cost (CAC) — third lever**

CAC is highly variable for dating apps and tends to rise with scale as cheap channels saturate. The risk:

| CAC | Break-even LTV needed | Churn required at $8.49 ARPU | Viability |
|---|---|---|---|
| $10 | $30+ | Any | Excellent |
| $25 | $75+ | <9% | Viable |
| $50 | $150+ | <6% | Tight |
| $75 | $225+ | <4% | Requires very low churn |
| $100+ | $300+ | <3% | Not viable at launch |

**The model is most sensitive to the combination of churn and CAC.** High churn + high CAC is the failure mode for most dating apps. Mangasm's invite-only model is a structural hedge against both — it filters high-intent users (lower churn) and benefits from referral-driven acquisition (lower CAC) — but only if community quality is maintained.

### Break-Even Summary

| Scenario | Monthly fixed costs (Y1) | Required MRR (net) to break even | Required paid subs | Approx. timeframe |
|---|---|---|---|---|
| Conservative | ~$7K (infra+people, minimal) | $7,000 | ~1,001 subs | Not achievable Y1–3 at projected growth |
| Base | ~$20K (infra+people+CAC) | $20,000 | ~2,356 subs | Month 28–30 |
| Aggressive | ~$70K (infra+people+CAC) | $70,000 | ~8,245 subs | Month 11–12 |

---

## 8. Risk Factors

> These are qualitative risks that could move actual results materially away from any scenario above.

| Risk | Impact | Mitigation |
|---|---|---|
| App Store policy changes (Apple raising rates, removing dating apps) | High | Diversify to web/PWA payment; maintain direct billing capability |
| Copycat competitors with larger budgets (Grindr, Scruff, Hinge) | Medium-High | Double down on community, events, and brand that larger apps cannot replicate |
| Dating-app market saturation in target cities | Medium | Expand city list; deepen community features that competitors lack |
| Trust & Safety failure (harassment, outing, abuse) | Critical | Non-negotiable investment; reputation system is a moat, not a feature |
| Regulatory risk (GDPR, DPDPA, Dubai/UAE local laws) | Medium | Privacy-first architecture is already a strategic asset; legal review per market |
| Churn exceeds modeled rate | High | Extend free tier to onboard; expand events to create sticky community |
| CAC exceeds modeled rate | High | Lean into referral mechanics; partner with luxury/nightlife venues for organic reach |

---

## 9. Planning Assumptions Index

For auditability, every number in this model traces to one of these sources:

| Assumption | Value | Source basis |
|---|---|---|
| Apple IAP cut Y1 | 30% | Apple App Store Review Guidelines |
| Apple Small Business Program | 15% | Apple developer documentation |
| Gay male population estimate | ~4–6% of adult male pop | Kinsey-range studies; varies by country |
| Dating app paid conversion range | 3–8% | Grindr SEC filings, Bumble investor day, Hinge press |
| Monthly churn range | 5–12% | Dating app industry benchmarks (various) |
| Niche app CAC range | $15–$50 | Paid social benchmarks; Raya/Feeld press estimates |
| Infra cost per MAU | ~$0.10–0.15 | Supabase pricing + AI API cost modeling |
| T&S cost estimate | $2K–$20K/mo | Industry staffing benchmarks; Grindr trust & safety disclosures |

---

*This document is a planning tool only. All scenarios are illustrative. Consult a qualified financial advisor before making business or investment decisions based on projections of this type.*
