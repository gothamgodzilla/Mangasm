// mangasm-launch.jsx — launch sequence: runway splash → logo → CTA → landmark sign-in.
// Exports window.LaunchFlow. Calls onEnter() to hand off to the full app.
const { useState: useStateL, useEffect: useEffectL, useRef: useRefL } = React;
const { GOLD: LG, GOLD_DEEP: LGD, GOLD_BRIGHT: LGB, INK: LINK, serif: lSerif, sans: lSans, mono: lMono,
  goldText: lGoldText, glass: lGlass } = window;

const ORANGE = '#F08A38';
const ORANGE_DEEP = '#C95E1E';

/* ============ injected keyframes (self-contained) ============ */
function LaunchStyle() {
  return (
    <style dangerouslySetInnerHTML={{ __html: `
      @keyframes mglogoIn { from { opacity:0; transform: translateY(14px) scale(0.92); filter: blur(6px); } to { opacity:1; transform:none; filter:none; } }
      @keyframes mgglow { 0%,100% { text-shadow: 0 0 18px rgba(240,138,56,0.55), 0 0 44px rgba(240,138,56,0.30), 0 2px 3px rgba(0,0,0,0.5); }
        50% { text-shadow: 0 0 30px rgba(240,138,56,0.95), 0 0 80px rgba(240,138,56,0.55), 0 2px 3px rgba(0,0,0,0.5); } }
      @keyframes mgrise { from { opacity:0; transform: translateY(20px); } to { opacity:1; transform:none; } }
      @keyframes mgctaPulse { 0%,100% { box-shadow: 0 10px 30px -8px rgba(240,138,56,0.6), inset 0 1px 0 rgba(255,255,255,0.45); }
        50% { box-shadow: 0 12px 44px -6px rgba(240,138,56,0.95), inset 0 1px 0 rgba(255,255,255,0.45); } }
      @keyframes mgkb { from { transform: scale(1.02) translateX(0); } to { transform: scale(1.16) translateX(-2%); } }
      @keyframes mgfadeIn { from { opacity:0; } to { opacity:1; } }
      @keyframes mgshimmer { from { background-position: -180% 0; } to { background-position: 280% 0; } }
      @keyframes mgcaret { 0%,49% { opacity:1; } 50%,100% { opacity:0; } }
    ` }} />
  );
}

/* ============ skyline silhouettes (gold line-art motif) ============ */
function band(x, w, h, top) { return <rect key={x + '-' + w} x={x} y={top - h} width={w} height={h} rx="1" />; }
const SKY = {
  Dubai: (
    <g>
      {[[6,16,30],[26,12,46],[42,18,62],[64,14,40],[92,20,78],[118,12,52]].map(([x,w,h]) => band(x,w,h,150))}
      <path d="M150 150 L156 150 L153 24 Z" />
      <rect x="150" y="64" width="6" height="86" />
      <path d="M152 24 L153.5 6 L155 24 Z" />
      {[[170,16,58],[192,22,92],[220,14,44],[238,18,70],[262,12,38],[280,22,100],[308,14,54],[326,18,72],[350,16,46],[372,20,84]].map(([x,w,h]) => band(x,w,h,150))}
    </g>
  ),
  London: (
    <g>
      {[[6,20,40],[30,16,30],[50,14,52]].map(([x,w,h]) => band(x,w,h,150))}
      {/* London Eye */}
      <circle cx="96" cy="92" r="34" fill="none" stroke="currentColor" strokeWidth="2.2" />
      <circle cx="96" cy="92" r="3.4" />
      {Array.from({length:12}).map((_,i)=>{const a=i/12*Math.PI*2;return <line key={i} x1="96" y1="92" x2={96+Math.cos(a)*34} y2={92+Math.sin(a)*34} stroke="currentColor" strokeWidth="1.1" />;})}
      <rect x="80" y="124" width="32" height="26" />
      {/* Big Ben */}
      <rect x="150" y="58" width="16" height="92" />
      <rect x="149" y="50" width="18" height="9" />
      <path d="M150 50 L158 30 L166 50 Z" />
      {/* Shard */}
      <path d="M200 150 L214 150 L210 36 Z" />
      {[[230,18,60],[254,14,42],[272,22,84],[300,16,50],[322,20,72],[350,14,38],[368,22,96]].map(([x,w,h]) => band(x,w,h,150))}
    </g>
  ),
  Mykonos: (
    <g>
      {/* cubic white-town houses */}
      {[[6,30,40],[40,26,52],[70,34,44],[108,24,60],[150,30,40],[210,28,50],[244,34,42],[300,26,56],[332,30,46],[368,24,52]].map(([x,w,h]) => band(x,w,h,150))}
      {/* church dome */}
      <path d="M176 150 L176 122 a14 14 0 0 1 28 0 L204 150 Z" />
      <rect x="186" y="104" width="8" height="10" />
      {/* windmill */}
      <rect x="278" y="98" width="18" height="52" />
      <circle cx="287" cy="98" r="5" />
      {Array.from({length:6}).map((_,i)=>{const a=i/6*Math.PI*2;return <rect key={i} x="285.5" y="98" width="3" height="30" transform={`rotate(${i*60} 287 98)`} />;})}
    </g>
  ),
  Tokyo: (
    <g>
      {[[6,18,52],[28,14,34],[46,20,68],[72,16,44]].map(([x,w,h]) => band(x,w,h,150))}
      {/* Tokyo Tower (lattice triangle) */}
      <path d="M104 150 L124 150 L116 38 Z" fill="none" stroke="currentColor" strokeWidth="2" />
      <path d="M116 38 L116 18" stroke="currentColor" strokeWidth="2" />
      <path d="M108 96 L132 96 M111 70 L129 70" stroke="currentColor" strokeWidth="1.4" />
      {[[150,16,46],[172,22,80],[200,14,40],[218,18,60]].map(([x,w,h]) => band(x,w,h,150))}
      {/* Skytree */}
      <rect x="262" y="20" width="6" height="130" />
      <circle cx="265" cy="58" r="9" fill="none" stroke="currentColor" strokeWidth="2.2" />
      <path d="M265 20 L265 6" stroke="currentColor" strokeWidth="1.6" />
      {[[290,20,72],[318,14,40],[336,22,90],[366,16,50]].map(([x,w,h]) => band(x,w,h,150))}
    </g>
  ),
};

const CITIES = [
  { name: 'Dubai',   coord: '25.20° N · 55.27° E', tag: 'where the signal shouldn’t reach', sky: ['#241a36', '#6e3550', '#e0894a'] },
  { name: 'London',  coord: '51.50° N · 0.12° W',  tag: 'after-hours, members only',        sky: ['#161f3c', '#3c3a64', '#bf6a7e'] },
  { name: 'Mykonos', coord: '37.44° N · 25.32° E', tag: 'white walls, gold nights',         sky: ['#102634', '#2f6f7c', '#e7bd6e'] },
  { name: 'Tokyo',   coord: '35.67° N · 139.65° E',tag: 'neon, velvet & rain',              sky: ['#191334', '#5a2a4c', '#d4585a'] },
];

/* ============ landmark slideshow background ============ */
function LandmarkSlides({ index }) {
  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
      {CITIES.map((c, i) => {
        const on = i === index;
        return (
          <div key={c.name} style={{ position: 'absolute', inset: 0, opacity: on ? 1 : 0, transition: 'opacity 1.4s ease' }}>
            <div style={{ position: 'absolute', inset: 0, transformOrigin: '60% 40%', animation: on ? 'mgkb 9s ease-out forwards' : 'none',
              background: `linear-gradient(180deg, ${c.sky[0]} 0%, ${c.sky[1]} 56%, ${c.sky[2]} 100%)` }}>
              {/* sun haze */}
              <div style={{ position: 'absolute', left: '62%', top: '44%', width: 220, height: 220, borderRadius: '50%', transform: 'translate(-50%,-50%)',
                background: `radial-gradient(circle, ${c.sky[2]}cc, ${c.sky[2]}22 46%, transparent 70%)`, filter: 'blur(6px)', mixBlendMode: 'screen' }} />
              {/* skyline */}
              <svg viewBox="0 0 400 150" preserveAspectRatio="xMidYMax meet" style={{ position: 'absolute', left: 0, right: 0, bottom: '40%', width: '100%', height: 260, color: '#120a14',
                fill: 'rgba(12,7,16,0.9)', filter: 'drop-shadow(0 -2px 14px rgba(12,7,16,0.5))' }}>
                {SKY[c.name]}
              </svg>
              {/* reflection / ground */}
              <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, height: '40%', background: `linear-gradient(180deg, ${c.sky[2]}66, #060308 92%)` }} />
            </div>
          </div>
        );
      })}
      {/* legibility veil */}
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(6,4,9,0.55) 0%, rgba(6,4,9,0.12) 26%, rgba(6,4,9,0.30) 56%, rgba(4,3,7,0.94) 100%)' }} />
      <div style={{ position: 'absolute', inset: 0, boxShadow: 'inset 0 0 140px 34px rgba(0,0,0,0.6)' }} />
    </div>
  );
}

/* ============ provider button ============ */
function ProviderBtn({ kind, label, onClick }) {
  const icons = {
    apple: <svg width="17" height="17" viewBox="0 0 24 24" fill="#fff"><path d="M16.4 12.8c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.1-2.8.9-3.5.9-.7 0-1.8-.8-3-.8-1.5 0-3 .9-3.8 2.3-1.6 2.8-.4 7 1.2 9.3.8 1.1 1.7 2.4 3 2.3 1.2-.1 1.6-.8 3-.8 1.4 0 1.8.8 3 .7 1.3 0 2-1.1 2.8-2.2.9-1.3 1.2-2.5 1.3-2.6-.1 0-2.4-1-2.4-3.7zM14.2 5.9c.6-.8 1.1-1.9 1-3-1 0-2.1.7-2.8 1.5-.6.7-1.1 1.8-1 2.8 1.1.1 2.2-.5 2.8-1.3z" /></svg>,
    google: <svg width="16" height="16" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.5 12.2c0-.7-.1-1.4-.2-2H12v4h5.9a5 5 0 0 1-2.2 3.3v2.7h3.6c2.1-2 3.3-4.9 3.3-8z" /><path fill="#34A853" d="M12 23c3 0 5.5-1 7.3-2.7l-3.6-2.7c-1 .7-2.3 1.1-3.7 1.1-2.8 0-5.2-1.9-6.1-4.5H2.2v2.8A11 11 0 0 0 12 23z" /><path fill="#FBBC05" d="M5.9 14.2a6.6 6.6 0 0 1 0-4.2V7.2H2.2a11 11 0 0 0 0 9.8l3.7-2.8z" /><path fill="#EA4335" d="M12 5.4c1.6 0 3 .5 4.1 1.6l3.1-3.1A11 11 0 0 0 2.2 7.2L5.9 10c.9-2.6 3.3-4.5 6.1-4.5z" /></svg>,
    phone: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={LG} strokeWidth="1.8"><rect x="6" y="2.5" width="12" height="19" rx="3" /><path d="M10.5 18.5h3" strokeLinecap="round" /></svg>,
  };
  const dark = kind === 'apple';
  return (
    <button onClick={onClick} style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, padding: '13px 14px', borderRadius: 14, cursor: 'pointer',
      ...(dark
        ? { background: 'linear-gradient(180deg, #2a2a2e, #0e0e10)', border: '0.7px solid rgba(255,255,255,0.16)', color: '#fff', boxShadow: '0 6px 18px -8px rgba(0,0,0,0.7), inset 0 1px 0 rgba(255,255,255,0.14)' }
        : { ...lGlass(true, 0.5), border: `0.7px solid ${LG}44`, color: '#f4ead2', boxShadow: '0 6px 16px -8px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.5)' }) }}>
      {icons[kind]}
      <span style={{ fontFamily: lSans, fontWeight: 700, fontSize: 13.5, letterSpacing: '0.01em' }}>{label}</span>
    </button>
  );
}

/* ============ sign-in stage ============ */
function SignIn({ onEnter }) {
  const [index, setIndex] = useStateL(0);
  useEffectL(() => {
    const id = setInterval(() => setIndex((i) => (i + 1) % CITIES.length), 4200);
    return () => clearInterval(id);
  }, []);
  const city = CITIES[index];
  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', animation: 'mgfadeIn 0.6s ease both' }}>
      <LandmarkSlides index={index} />

      {/* city tag — upper */}
      <div style={{ position: 'absolute', top: 92, left: 0, right: 0, textAlign: 'center', zIndex: 4 }}>
        <div key={city.name} style={{ animation: 'mgrise 0.9s ease both' }}>
          <div style={{ fontFamily: lMono, fontSize: 9, letterSpacing: '0.34em', color: 'rgba(255,255,255,0.6)', paddingLeft: '0.34em' }}>{city.coord}</div>
          <div style={{ fontFamily: lSerif, fontWeight: 600, fontSize: 40, color: '#fff', lineHeight: 1.05, marginTop: 4, textShadow: '0 2px 24px rgba(0,0,0,0.6)' }}>{city.name}</div>
          <div style={{ fontFamily: lSerif, fontStyle: 'italic', fontWeight: 500, fontSize: 15, color: 'rgba(245,235,214,0.82)', marginTop: 2 }}>{city.tag}</div>
        </div>
        {/* dots */}
        <div style={{ display: 'flex', gap: 6, justifyContent: 'center', marginTop: 16 }}>
          {CITIES.map((_, i) => (
            <span key={i} style={{ width: i === index ? 18 : 6, height: 6, borderRadius: 3, background: i === index ? LG : 'rgba(255,255,255,0.34)', transition: 'all .4s', boxShadow: i === index ? `0 0 8px ${LG}` : 'none' }} />
          ))}
        </div>
      </div>

      {/* sign-in sheet */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 6, padding: '26px 22px 30px', borderTopLeftRadius: 30, borderTopRightRadius: 30,
        ...lGlass(true, 0.6), borderBottom: 'none', boxShadow: '0 -20px 60px -20px rgba(0,0,0,0.75), inset 0 1px 0 rgba(255,255,255,0.4)' }}>
        <div style={{ width: 38, height: 4, borderRadius: 3, background: 'rgba(255,255,255,0.4)', margin: '-8px auto 18px' }} />

        <div style={{ textAlign: 'center', marginBottom: 18 }}>
          <div style={{ fontFamily: lSerif, fontWeight: 700, fontSize: 38, ...lGoldText, lineHeight: 1, letterSpacing: '0.01em', textShadow: '0 1px 14px rgba(201,168,76,0.4)' }}>Mangasm</div>
          <div style={{ fontFamily: lMono, fontSize: 8.5, letterSpacing: '0.28em', color: 'rgba(245,235,214,0.66)', marginTop: 7, paddingLeft: '0.28em' }}>BY INVITATION · MEMBERS ONLY</div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
          <ProviderBtn kind="apple" label="Continue with Apple" onClick={onEnter} />
          <ProviderBtn kind="google" label="Continue with Google" onClick={onEnter} />
          <ProviderBtn kind="phone" label="Continue with phone" onClick={onEnter} />
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '15px 4px 13px' }}>
          <div style={{ flex: 1, height: 1, background: 'linear-gradient(90deg, transparent, rgba(201,168,76,0.4))' }} />
          <span style={{ fontFamily: lMono, fontSize: 8, letterSpacing: '0.2em', color: 'rgba(245,235,214,0.5)' }}>OR</span>
          <div style={{ flex: 1, height: 1, background: 'linear-gradient(90deg, rgba(201,168,76,0.4), transparent)' }} />
        </div>

        <button onClick={onEnter} style={{ width: '100%', padding: '15px', borderRadius: 15, cursor: 'pointer', border: 'none',
          background: `linear-gradient(135deg, ${LGB}, ${LG} 48%, ${LGD})`, color: '#2a1d05', fontFamily: lSerif, fontWeight: 700, fontSize: 16, letterSpacing: '0.04em',
          boxShadow: '0 12px 32px -8px rgba(201,168,76,0.7), inset 0 1px 0 rgba(255,255,255,0.5)' }}>
          Enter the community →
        </button>

        <div style={{ fontFamily: lMono, fontSize: 7.5, lineHeight: 1.7, letterSpacing: '0.04em', color: 'rgba(245,235,214,0.5)', textAlign: 'center', marginTop: 14 }}>
          18+ ONLY · VERIFIED PROFILES · BY CONTINUING YOU ACCEPT THE<br />
          <span style={{ color: 'rgba(245,235,214,0.72)', textDecoration: 'underline', textUnderlineOffset: 2 }}>COMMUNITY GUIDELINES</span> &nbsp;·&nbsp; <span style={{ color: 'rgba(245,235,214,0.72)', textDecoration: 'underline', textUnderlineOffset: 2 }}>PRIVACY</span>
        </div>
      </div>
    </div>
  );
}

/* ============ splash stage (runway video) ============ */
function Splash({ onContinue }) {
  const [show, setShow] = useStateL(true);
  useEffectL(() => {
    const id = setTimeout(() => go(), 8600);
    return () => clearTimeout(id);
  }, []);
  const go = () => { setShow(false); setTimeout(onContinue, 480); };
  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', background: '#000', opacity: show ? 1 : 0, transition: 'opacity 0.48s ease' }}>
      <video src="assets/runway.mp4" autoPlay muted loop playsInline
        style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover', transform: 'scale(1.04)' }} />
      {/* cinematic grade + vignette */}
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(6,4,9,0.5) 0%, rgba(6,4,9,0.05) 30%, rgba(6,4,9,0.35) 62%, rgba(4,2,7,0.92) 100%)' }} />
      <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(120% 80% at 50% 30%, rgba(240,138,56,0.10), transparent 55%)', mixBlendMode: 'screen' }} />
      <div style={{ position: 'absolute', inset: 0, boxShadow: 'inset 0 0 150px 40px rgba(0,0,0,0.7)' }} />

      {/* skip */}
      <button onClick={go} style={{ position: 'absolute', top: 60, right: 18, zIndex: 10, padding: '6px 12px', borderRadius: 20, cursor: 'pointer',
        ...lGlass(true, 0.4), color: 'rgba(255,255,255,0.78)', fontFamily: lMono, fontSize: 9, letterSpacing: '0.18em' }}>SKIP</button>

      {/* lockup */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 132, textAlign: 'center', zIndex: 8 }}>
        <div style={{ fontFamily: lMono, fontSize: 9, letterSpacing: '0.5em', color: ORANGE, opacity: 0, animation: 'mgrise 1s ease 0.4s both', paddingLeft: '0.5em' }}>EST. MMXXVI</div>
        <div style={{ fontFamily: lSerif, fontWeight: 700, fontSize: 60, color: '#fff', lineHeight: 1, marginTop: 6, letterSpacing: '0.01em',
          opacity: 0, animation: 'mglogoIn 1.1s cubic-bezier(.2,.8,.2,1) 0.7s both, mgglow 3.4s ease-in-out 1.8s infinite' }}>Mangasm</div>
        <div style={{ fontFamily: lMono, fontSize: 9.5, letterSpacing: '0.42em', color: 'rgba(245,235,214,0.78)', marginTop: 12, opacity: 0, animation: 'mgrise 1s ease 1.5s both', paddingLeft: '0.42em' }}>
          DARK LUXURY · BROTHERHOOD · NIGHTLIFE
        </div>
      </div>

      {/* CTA */}
      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 46, zIndex: 9, opacity: 0, animation: 'mgrise 0.9s ease 3.1s both' }}>
        <button onClick={go} style={{ width: '100%', padding: '16px', borderRadius: 16, cursor: 'pointer', border: `1px solid ${ORANGE}88`,
          background: `linear-gradient(135deg, ${ORANGE}, ${ORANGE_DEEP})`, color: '#fff', fontFamily: lSerif, fontWeight: 700, fontSize: 16, letterSpacing: '0.08em',
          animation: 'mgctaPulse 2.4s ease-in-out infinite', position: 'relative', overflow: 'hidden' }}>
          <span style={{ position: 'relative', zIndex: 2 }}>ENTER THE COMMUNITY</span>
          <span style={{ position: 'absolute', inset: 0, background: 'linear-gradient(110deg, transparent 30%, rgba(255,255,255,0.4) 50%, transparent 70%)', backgroundSize: '220% 100%', animation: 'mgshimmer 3.2s ease-in-out 3.6s infinite' }} />
        </button>
        <div style={{ textAlign: 'center', fontFamily: lMono, fontSize: 8, letterSpacing: '0.2em', color: 'rgba(255,255,255,0.5)', marginTop: 11 }}>TAP ANYWHERE TO CONTINUE</div>
      </div>

      {/* tap-anywhere catcher (below CTA/skip z-index so buttons still work) */}
      <button onClick={go} aria-label="continue" style={{ position: 'absolute', inset: 0, zIndex: 1, background: 'transparent', border: 'none', cursor: 'pointer' }} />
    </div>
  );
}

/* ============ orchestrator ============ */
function LaunchFlow({ onEnter }) {
  const [stage, setStage] = useStateL('splash');
  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', background: '#000' }}>
      <LaunchStyle />
      {stage === 'splash' ? <Splash onContinue={() => setStage('signin')} /> : <SignIn onEnter={onEnter} />}
    </div>
  );
}

window.LaunchFlow = LaunchFlow;
