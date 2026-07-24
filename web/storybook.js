/**
 * Mangasm Storybook — 18+ UNDERPANTS COMIC edition
 * Aesthetic: crude camp / bathroom-stall superhero energy (original IP)
 * GANESH · mangasm.app · ai@mangasm.app
 * Roast landlords, never the community.
 */

const STORAGE_KEY = "mangasm_storybook_v2_comic";

const SFX_WORDS = [
  "POW!",
  "BONK!",
  "THWIP!",
  "YIKES!",
  "SPLAT!",
  "WHOOSH!",
  "EEK!",
  "KA-CHING!",
  "GROSS!",
  "HOT!",
];

const PAGES = [
  {
    id: "cover",
    num: "COVER · 18+",
    title: "Open the body. <em>(Gross. Necessary.)</em>",
    banter:
      "They called it generic. We called it an autopsy. Pull up a toilet seat — this comic’s for grown-ups who still draw on the back of homework.",
    sfx: "POW!",
  },
  {
    id: "opening",
    num: "01 · OPENING",
    title: "They Built It For Us. <em>Then They Forgot Us.</em>",
    banter:
      "Pride float energy. Empty chat energy. If connection was the product, why does the algorithm smell like a casino bathroom? Spoiler: you’re not the user. You’re the crop. And the crop is TIRED.",
    sfx: "YIKES!",
  },
  {
    id: "accused",
    num: "02 · THE ACCUSED",
    title: "Different faces. <em>Same betrayal.</em>",
    banter:
      "I’m not roasting the community. I’m roasting the landlords who rented us a club, charged cover for ads, and called the fire exits ‘premium.’ Four mugshots. One skidmark business model.",
    sfx: "BONK!",
  },
  {
    id: "evidence",
    num: "03 · THE EVIDENCE BOARD",
    title: "The receipts. <em>Don’t lie.</em>",
    banter:
      "Data in the underwear drawer of capitalism. Safety theater. Report abuse → robot shrugs. Red string = receipts. Sticky notes = rage. You’re allowed to be mad AND horny for justice.",
    sfx: "SPLAT!",
  },
  {
    id: "honesty",
    num: "04 · RADICAL HONESTY",
    title: "What they sold you <em>vs</em> what they built.",
    banter:
      "Pretty glass. Ugly guts. Like a cape over skidmarks. Subscriptions = velvet rope. Ads = second rent. Boosts = tax on loneliness. KA-CHING on your heart, baby.",
    sfx: "KA-CHING!",
  },
  {
    id: "manifesto",
    num: "05 · THE MANIFESTO",
    title: "We’re not the product. <em>We are the reason.</em>",
    banter:
      "Campfire, not casino. Pants optional. Consent required. Mangasm is culturally specific, safety-first, anti-extraction — a home, not a petri dish for someone else’s IPO.",
    sfx: "WHOOSH!",
  },
  {
    id: "rebuild",
    num: "06 · THE REBUILD",
    title: "The autopsy is over. <em>The rebuild begins.</em>",
    banter:
      "Not another app. A home. Real people. Real care. No doorstep farms. Keep your underpants. Lose the landlords. Flip the last page like a hero with boundaries.",
    sfx: "HOT!",
  },
];

/** CYOA forks — glamorous binaries, toilet-humor delivery */
const FORKS = {
  after1: {
    id: "entrance",
    label: "FORK · PICK A LANE (BOTH STINK / BOTH FAB)",
    title: "Left or Right, genius?",
    prompt:
      "Corridor splits. You’re not picking good vs evil — you’re picking which landlord smell you want to document first.",
    a: {
      id: "left",
      main: "A · LEFT — HOOKUP KING LANE",
      sub: "Loud thirst. Fast heat. Audit the body marketplace with your eyes open (and your wallet closed).",
      tags: ["left", "hookup-king"],
    },
    b: {
      id: "right",
      main: "B · RIGHT — CORPORATE RAINBOW",
      sub: "Pride mug polish. Sniff the ad stack under the paint. Inclusion as a quarter; extraction as a year.",
      tags: ["right", "corporate-rainbow"],
    },
  },
  after2: {
    id: "wardrobe",
    label: "FORK · LOOKBOOK (KEEP YOUR PANTS)",
    title: "What are we wearing to the end of intimacy?",
    prompt:
      "Catch the draft. Both options fabulous. Neither option is ‘be boring.’ This is a comic, not HR.",
    a: {
      id: "trench",
      main: "A · BURBERRY TRENCH",
      sub: "Structure. Mystery. Subpoena energy. You’re the detective who still looks hot in the rain.",
      tags: ["trench", "wardrobe"],
      wardrobe: "trench",
    },
    b: {
      id: "sequin",
      main: "B · SEQUIN CROP TOP",
      sub: "Main character under the streetlight. Every flash a premiere. Pants optional. Consent mandatory.",
      tags: ["sequin", "wardrobe"],
      wardrobe: "sequin",
    },
  },
};

const ENDINGS = {
  default:
    "Not another app. A home we build together — campfire, not casino. (Keep your underpants. Lose the landlords.)",
  trench:
    "TRENCH ENDING: you documented the crime with spine. Report, block, delete, real humans. Cape on. Pants up. Rebuild.",
  sequin:
    "SEQUIN ENDING: you walked in loud. Keep the glamour, dump the extraction. Mangasm = afterparty with doors that lock.",
  left: "HOOKUP KING LANE scouted. You saw the cover charge. Time to build a club that doesn’t sell the guests for parts.",
  right:
    "CORPORATE RAINBOW peeled. Paint off. Inclusion isn’t a quarter — it’s the architecture. Join the rebuild.",
  both: "TRENCH + RECEIPTS. You left no landlord unroasted. The rebuild is yours — mangasm.app. POW.",
};

const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];

const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
const isTouch =
  matchMedia("(pointer: coarse)").matches ||
  "ontouchstart" in window ||
  navigator.maxTouchPoints > 0;

if (isTouch) document.body.classList.add("is-touch");

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { page: 0, tags: [], forksDone: {}, read: [0] };
    return { page: 0, tags: [], forksDone: {}, read: [0], ...JSON.parse(raw) };
  } catch {
    return { page: 0, tags: [], forksDone: {}, read: [0] };
  }
}

function saveState(s) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
}

let state = loadState();
let animating = false;
let pendingAdvance = null;

const book = $("#book");
const spreads = $$(".spread");
const metaNum = $("[data-meta-num]");
const metaTitle = $("[data-meta-title]");
const metaBanter = $("[data-meta-banter]");
const btnPrev = $("#btn-prev");
const btnNext = $("#btn-next");
const btnOpen = $("#btn-open");
const pathChip = $("#path-chip");
const dotsEl = $("#dots");
const forkOverlay = $("#fork-overlay");
const endLine = $("[data-end-line]");

function updatePathChip() {
  const tags = state.tags.length ? state.tags.join(" · ") : "underwear drawer empty";
  const wardrobe = state.tags.includes("trench")
    ? "trench (subpoena chic)"
    : state.tags.includes("sequin")
      ? "sequin (main character)"
      : "pants TBD";
  pathChip.textContent = `Path sticky-note: ${tags} · look: ${wardrobe} · page ${state.page}/${PAGES.length - 1}`;
}

function boomSfx(word) {
  const el = $("#sfx");
  if (!el || reduced) return;
  const w = word || SFX_WORDS[Math.floor(Math.random() * SFX_WORDS.length)];
  el.hidden = false;
  el.textContent = w;
  el.classList.remove("left", "right");
  el.classList.add(Math.random() > 0.5 ? "left" : "right");
  // re-trigger animation
  el.style.animation = "none";
  // eslint-disable-next-line no-unused-expressions
  el.offsetHeight;
  el.style.animation = "";
  clearTimeout(boomSfx._t);
  boomSfx._t = setTimeout(() => {
    el.hidden = true;
  }, 900);
}

function endingCopy() {
  const t = state.tags;
  if (t.includes("trench") && (t.includes("left") || t.includes("right"))) return ENDINGS.both;
  if (t.includes("trench")) return ENDINGS.trench;
  if (t.includes("sequin")) return ENDINGS.sequin;
  if (t.includes("left")) return ENDINGS.left;
  if (t.includes("right")) return ENDINGS.right;
  return ENDINGS.default;
}

function renderMeta(page) {
  const p = PAGES[page];
  if (!p) return;
  metaNum.textContent = p.num;
  metaTitle.innerHTML = p.title;
  metaBanter.innerHTML = `<strong>GANESH:</strong> ${p.banter}`;
  if (page === 6 && endLine) endLine.textContent = endingCopy();
  if (p.sfx) boomSfx(p.sfx);
}

function buildDots() {
  dotsEl.innerHTML = "";
  PAGES.forEach((_, i) => {
    const b = document.createElement("button");
    b.type = "button";
    b.className = "dot";
    b.setAttribute("role", "tab");
    b.setAttribute("aria-label", `Page ${i}`);
    b.dataset.page = String(i);
    if (i === state.page) b.classList.add("is-active");
    if (state.read.includes(i)) b.classList.add("is-read");
    b.addEventListener("click", () => goTo(i));
    dotsEl.appendChild(b);
  });
}

function updateChrome() {
  book.classList.toggle("is-cover", state.page === 0);
  btnPrev.disabled = state.page <= 0 || animating;
  btnNext.disabled = state.page >= PAGES.length - 1 || animating;
  btnNext.textContent =
    state.page >= PAGES.length - 1 ? "End" : state.page === 0 ? "Open →" : "Next →";
  $$(".dot", dotsEl).forEach((d, i) => {
    d.classList.toggle("is-active", i === state.page);
    d.classList.toggle("is-read", state.read.includes(i));
  });
  updatePathChip();
  saveState(state);
}

function showSpread(page, dir = 0) {
  spreads.forEach((sp) => {
    const n = Number(sp.dataset.page);
    const active = n === page;
    sp.hidden = !active && reduced;
    sp.classList.remove("is-active", "is-exit-left", "is-exit-right");
    if (active) {
      sp.hidden = false;
      sp.classList.add("is-active");
    } else if (!reduced && dir !== 0 && n === state.page) {
      sp.classList.add(dir > 0 ? "is-exit-left" : "is-exit-right");
    }
  });
}

function goTo(page, { skipFork = false } = {}) {
  if (animating) return;
  page = Math.max(0, Math.min(PAGES.length - 1, page));
  if (page === state.page) return;

  const dir = page > state.page ? 1 : -1;

  // Forks when advancing past gates
  if (!skipFork && dir > 0) {
    if (state.page === 1 && page > 1 && !state.forksDone.entrance) {
      pendingAdvance = page;
      openFork(FORKS.after1);
      return;
    }
    if (state.page === 2 && page > 2 && !state.forksDone.wardrobe) {
      pendingAdvance = page;
      openFork(FORKS.after2);
      return;
    }
  }

  animating = true;
  const prev = state.page;
  showSpread(page, dir);
  // briefly show exit class on previous
  const prevEl = spreads.find((s) => Number(s.dataset.page) === prev);
  if (prevEl && !reduced) {
    prevEl.classList.add(dir > 0 ? "is-exit-left" : "is-exit-right");
  }
  state.page = page;
  if (!state.read.includes(page)) state.read.push(page);
  renderMeta(page);
  updateChrome();

  setTimeout(
    () => {
      spreads.forEach((sp) => {
        if (Number(sp.dataset.page) !== state.page) {
          sp.hidden = true;
          sp.classList.remove("is-active", "is-exit-left", "is-exit-right");
        }
      });
      animating = false;
      updateChrome();
    },
    reduced ? 0 : 420
  );
}

function next() {
  if (state.page < PAGES.length - 1) goTo(state.page + 1);
}
function prev() {
  if (state.page > 0) goTo(state.page - 1, { skipFork: true });
}

/* Forks */
function openFork(fork) {
  forkOverlay.classList.add("is-open");
  forkOverlay.setAttribute("aria-hidden", "false");
  $("[data-fork-label]").textContent = fork.label;
  $("[data-fork-title]").textContent = fork.title;
  $("[data-fork-prompt]").textContent = fork.prompt;
  $("[data-fork-a-main]").textContent = fork.a.main;
  $("[data-fork-a-sub]").textContent = fork.a.sub;
  $("[data-fork-b-main]").textContent = fork.b.main;
  $("[data-fork-b-sub]").textContent = fork.b.sub;
  forkOverlay.dataset.forkId = fork.id;

  const onA = () => pickFork(fork, "a");
  const onB = () => pickFork(fork, "b");
  const btnA = $("[data-fork-a]");
  const btnB = $("[data-fork-b]");
  btnA.onclick = onA;
  btnB.onclick = onB;
}

function pickFork(fork, side) {
  const choice = fork[side];
  state.tags = [...new Set([...state.tags, ...choice.tags])];
  state.forksDone[fork.id] = choice.id;
  if (choice.wardrobe) state.wardrobe = choice.wardrobe;
  closeFork();
  const target = pendingAdvance ?? state.page + 1;
  pendingAdvance = null;
  goTo(target, { skipFork: true });
}

function closeFork() {
  forkOverlay.classList.remove("is-open");
  forkOverlay.setAttribute("aria-hidden", "true");
}

/* Board drawer */
const drawer = $("#board-drawer");
function setBoard(open) {
  if (open) {
    drawer.hidden = false;
    requestAnimationFrame(() => drawer.classList.add("is-open"));
    $("#btn-board").setAttribute("aria-expanded", "true");
  } else {
    drawer.classList.remove("is-open");
    $("#btn-board").setAttribute("aria-expanded", "false");
    setTimeout(
      () => {
        drawer.hidden = true;
      },
      reduced ? 0 : 320
    );
  }
}

/* Wire */
btnPrev.addEventListener("click", prev);
btnNext.addEventListener("click", next);
btnOpen?.addEventListener("click", () => goTo(1));
$("#btn-restart")?.addEventListener("click", () => {
  state.page = 0;
  goTo(0, { skipFork: true });
  showSpread(0, 0);
  renderMeta(0);
  updateChrome();
});
$("#btn-reset-path")?.addEventListener("click", () => {
  localStorage.removeItem(STORAGE_KEY);
  state = { page: 0, tags: [], forksDone: {}, read: [0] };
  closeFork();
  showSpread(0, 0);
  renderMeta(0);
  buildDots();
  updateChrome();
});
$("#btn-board")?.addEventListener("click", () =>
  setBoard(drawer.hidden || !drawer.classList.contains("is-open"))
);
$("#btn-board-close")?.addEventListener("click", () => setBoard(false));

addEventListener("keydown", (e) => {
  if (forkOverlay.classList.contains("is-open")) {
    if (e.key === "a" || e.key === "A" || e.key === "1") $("[data-fork-a]")?.click();
    if (e.key === "b" || e.key === "B" || e.key === "2") $("[data-fork-b]")?.click();
    if (e.key === "Escape") closeFork();
    return;
  }
  if (e.key === "ArrowRight" || e.key === " ") {
    e.preventDefault();
    next();
  }
  if (e.key === "ArrowLeft") {
    e.preventDefault();
    prev();
  }
  if (e.key === "Escape") setBoard(false);
});

// Swipe
let touchX = null;
book.addEventListener(
  "touchstart",
  (e) => {
    touchX = e.changedTouches[0].clientX;
  },
  { passive: true }
);
book.addEventListener(
  "touchend",
  (e) => {
    if (touchX == null) return;
    const dx = e.changedTouches[0].clientX - touchX;
    touchX = null;
    if (Math.abs(dx) < 48) return;
    if (dx < 0) next();
    else prev();
  },
  { passive: true }
);

// Init
spreads.forEach((sp) => {
  const n = Number(sp.dataset.page);
  sp.hidden = n !== state.page;
  sp.classList.toggle("is-active", n === state.page);
});
// Always start on cover for fresh read feel, but keep path tags
state.page = 0;
if (!state.read.includes(0)) state.read.push(0);
buildDots();
renderMeta(0);
showSpread(0, 0);
updateChrome();

console.log(
  "%cMANGASM · 18+ UNDERPANTS COMIC\n%cAPP AUTOPSY · POW · BONK · landlords only · GANESH",
  "color:#ff2d6a;font-size:15px;font-weight:bold;",
  "color:#2b6cff;font-size:11px;"
);
