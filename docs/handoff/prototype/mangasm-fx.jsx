// mangasm-fx.jsx — shared tokens, glass, weather, background. Exports to window.
const { useState: useStateFX, useEffect: useEffectFX, useRef: useRefFX } = React;

const GOLD = '#C9A84C';
const GOLD_DEEP = '#9A7B2C';
const GOLD_BRIGHT = '#E4C97E';
const SPOTIFY = '#138a3e';
const INK = '#2A2117';
const INK_SOFT = 'rgba(42,33,23,0.7)';
const INK_FAINT = 'rgba(42,33,23,0.5)';
const serif = "'Cormorant Garamond', serif";
const sans = "'Mulish', sans-serif";
const mono = "'Space Mono', monospace";
const goldText = {
  background: `linear-gradient(180deg, ${GOLD_BRIGHT}, ${GOLD} 48%, ${GOLD_DEEP})`,
  WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text',
};
const goldGlow = '0 1px 10px rgba(201,168,76,0.30), 0 1px 1px rgba(255,255,255,0.4)';
// metallic chrome shimmer: gunmetal -> white -> steel-blue -> gold
const holo = 'linear-gradient(120deg, rgba(120,128,140,0.9), rgba(255,255,255,0.98) 34%, rgba(150,178,210,0.85) 60%, rgba(201,168,76,0.85))';
// faint carbon-fibre weave, used as a subtle texture overlay on dark surfaces
const carbon = 'repeating-linear-gradient(45deg, rgba(255,255,255,0.05) 0 2px, rgba(0,0,0,0.05) 2px 4px), repeating-linear-gradient(-45deg, rgba(255,255,255,0.04) 0 2px, rgba(0,0,0,0.06) 2px 4px)';

function glass(night, op) {
  // hyperreal liquid glass — clearer body, deeper refraction, crisp specular rim
  const o = (0.22 + (op != null ? op : 0.46) * 0.30) * 0.12;
  return {
    background: `linear-gradient(150deg, rgba(238,244,252,${o + 0.015}), rgba(200,212,228,${Math.max(o - 0.012, 0.016)}))`,
    backdropFilter: 'blur(22px) saturate(150%) brightness(1.04)', WebkitBackdropFilter: 'blur(22px) saturate(150%) brightness(1.04)',
    border: '0.7px solid rgba(226,236,250,0.55)',
    boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.72), inset 0 0 0.6px rgba(255,255,255,0.5), inset 0 -12px 26px -16px rgba(110,132,164,0.4)',
  };
}

function Refraction({ radius = 24 }) {
  // barely-there iridescent sheen across light glass
  return (
    <div aria-hidden style={{ position: 'absolute', inset: 0, borderRadius: radius, overflow: 'hidden', pointerEvents: 'none' }}>
      <div style={{ position: 'absolute', inset: '-40% -10%', transform: 'rotate(-12deg)', background: 'linear-gradient(108deg, transparent 22%, rgba(201,168,76,0.10) 40%, rgba(255,255,255,0.16) 52%, rgba(176,205,235,0.10) 64%, transparent 80%)', mixBlendMode: 'soft-light', filter: 'blur(4px)' }} />
    </div>
  );
}

function Pill({ children, glow }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '5px 10px', borderRadius: 12, ...glass(true, 0.5), border: glow ? `1px solid ${GOLD}88` : '0.7px solid rgba(255,255,255,0.7)', boxShadow: '0 6px 16px -6px rgba(40,30,15,0.4), inset 0 1px 0 rgba(255,255,255,0.7)' }}>
      {children}
    </div>
  );
}

function Seal({ size = 16 }) {
  return (
    <span style={{ display: 'inline-flex', verticalAlign: 'middle', alignItems: 'center', justifyContent: 'center', width: size, height: size, borderRadius: '50%', background: `linear-gradient(135deg, ${GOLD_BRIGHT}, ${GOLD_DEEP})`, boxShadow: '0 0 8px rgba(232,199,126,0.6)' }}>
      <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none" stroke="#2a1d05" strokeWidth="3.6" strokeLinecap="round" strokeLinejoin="round"><path d="M5 13l4 4L19 6" /></svg>
    </span>
  );
}

function Equalizer({ color, n = 4 }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 2, height: 13 }}>
      {Array.from({ length: n }).map((_, i) => (
        <span key={i} style={{ width: 2.5, height: 5 + (i % 3) * 3, borderRadius: 2, background: color, animation: `mgeq ${0.7 + (i % 3) * 0.2}s ${i * 0.1}s ease-in-out infinite alternate` }} />
      ))}
    </div>
  );
}

/* ============ weather ============ */
const WEATHER = {
  clear: { label: 'Clear', temp: '28°' }, cloudy: { label: 'Cloudy', temp: '24°' },
  rain: { label: 'Light Rain', temp: '19°' }, heavyRain: { label: 'Heavy Rain', temp: '17°' },
  snow: { label: 'Snow', temp: '−2°' }, sleet: { label: 'Sleet', temp: '1°' },
};
function Rain({ heavy }) {
  const make = (n, o) => Array.from({ length: n }).map(() => ({
    left: Math.random() * 106 - 3, delay: -Math.random() * 1.6, dur: o.dur + Math.random() * o.durJ,
    len: o.len + Math.random() * o.lenJ, op: o.op + Math.random() * o.opJ, w: o.w,
  }));
  const far = React.useMemo(() => make(heavy ? 64 : 40, { dur: 0.72, durJ: 0.4, len: 8, lenJ: 7, op: 0.10, opJ: 0.16, w: 0.8 }), [heavy]);
  const near = React.useMemo(() => make(heavy ? 30 : 18, { dur: 0.34, durJ: 0.16, len: 22, lenJ: 16, op: 0.22, opJ: 0.34, w: 1.7 }), [heavy]);
  const rot = heavy ? 14 : 8;
  const streak = (d, i) => (
    <span key={i} style={{ position: 'absolute', top: -40, left: `${d.left}%`, width: d.w, height: d.len, borderRadius: d.w, background: `linear-gradient(to bottom, transparent, rgba(208,224,250,${d.op}))`, transform: `rotate(${rot}deg)`, animation: `mgrain ${d.dur}s linear ${d.delay}s infinite` }} />
  );
  return (
    <div style={{ position: 'absolute', inset: 0 }}>
      <div style={{ position: 'absolute', inset: 0, filter: 'blur(1.4px)', opacity: 0.85 }}>{far.map(streak)}</div>
      {near.map(streak)}
    </div>
  );
}
function Snow() {
  const flakes = React.useMemo(() => Array.from({ length: 52 }).map(() => ({
    left: Math.random() * 100, delay: -Math.random() * 7, dur: 5 + Math.random() * 5, size: 2 + Math.random() * 3.6, op: 0.45 + Math.random() * 0.5, sway: 1.6 + Math.random() * 2.2,
  })), []);
  return <div style={{ position: 'absolute', inset: 0 }}>{flakes.map((f, i) => (
    <span key={i} style={{ position: 'absolute', top: -12, left: `${f.left}%`, animation: `mgfall ${f.dur}s linear ${f.delay}s infinite` }}>
      <span style={{ display: 'block', width: f.size, height: f.size, borderRadius: '50%', background: `rgba(255,255,255,${f.op})`, boxShadow: '0 0 4px rgba(255,255,255,0.6)', animation: `mgsway ${f.sway}s ease-in-out infinite alternate` }} />
    </span>
  ))}</div>;
}
function GodRays({ night }) {
  const beams = [-22, -12, -3, 7, 17, 28];
  const x = night ? '50%' : '72%';
  const tint = night ? 'rgba(232,199,126,0.12)' : 'rgba(255,244,214,0.15)';
  return <div style={{ position: 'absolute', inset: 0, mixBlendMode: 'screen', animation: 'mgray 7s ease-in-out infinite alternate' }}>{beams.map((b, i) => (
    <div key={i} style={{ position: 'absolute', top: '-14%', left: x, width: 58, height: '155%', transformOrigin: 'top center', transform: `translateX(-50%) rotate(${b}deg)`, background: `linear-gradient(180deg, ${tint}, transparent 72%)`, filter: 'blur(7px)' }} />
  ))}</div>;
}
function SunFlare() { return <div style={{ position: 'absolute', top: '5%', right: '13%', width: 150, height: 150, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,247,224,0.92), rgba(255,212,142,0.34) 40%, transparent 70%)', mixBlendMode: 'screen', filter: 'blur(3px)' }} />; }
function Clouds() {
  const cs = [{ t: '7%', d: 0, dur: 46, o: 0.5 }, { t: '20%', d: -16, dur: 60, o: 0.34 }, { t: '13%', d: -34, dur: 74, o: 0.28 }];
  return <div style={{ position: 'absolute', inset: 0, opacity: 0.6 }}>{cs.map((c, i) => (
    <div key={i} style={{ position: 'absolute', top: c.t, left: '-20%', width: '62%', height: 100, borderRadius: '50%', background: `radial-gradient(ellipse, rgba(196,201,212,${c.o}), transparent 70%)`, filter: 'blur(11px)', animation: `mgdrift ${c.dur}s linear ${c.d}s infinite` }} />
  ))}</div>;
}
function RainGlass({ heavy }) {
  const beads = React.useMemo(() => Array.from({ length: heavy ? 44 : 30 }).map(() => {
    const s = 2.4 + Math.random() * (heavy ? 9 : 7);
    return { x: Math.random() * 100, y: Math.random() * 100, s, bob: 2.4 + Math.random() * 3, delay: -Math.random() * 5 };
  }), [heavy]);
  const rivs = React.useMemo(() => Array.from({ length: heavy ? 8 : 5 }).map(() => ({
    x: Math.random() * 100, w: 1.4 + Math.random() * 2.2, len: 24 + Math.random() * 40,
    dur: 1.8 + Math.random() * 2.6, delay: -Math.random() * 5, head: 4 + Math.random() * 4,
  })), [heavy]);
  const dropBG = 'radial-gradient(40% 34% at 38% 30%, rgba(255,255,255,0.92), rgba(220,232,248,0.28) 46%, rgba(150,172,200,0.10) 70%, transparent 80%)';
  const dropSH = 'inset -0.5px -1px 1.5px rgba(255,255,255,0.55), inset 0.5px 1px 2px rgba(38,54,80,0.5), 0 1px 2px rgba(0,0,0,0.25)';
  return (
    <div aria-hidden style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
      <div style={{ position: 'absolute', inset: 0, backdropFilter: 'blur(1.4px) saturate(106%)', WebkitBackdropFilter: 'blur(1.4px) saturate(106%)', background: 'radial-gradient(140% 100% at 50% 0%, rgba(180,200,225,0.04), rgba(110,132,164,0.10))' }} />
      {beads.map((b, i) => (
        <span key={'b' + i} style={{ position: 'absolute', left: `${b.x}%`, top: `${b.y}%`, width: b.s, height: b.s * 1.12, borderRadius: '50%', background: dropBG, boxShadow: dropSH, animation: `mgbeadbob ${b.bob}s ease-in-out ${b.delay}s infinite` }} />
      ))}
      {rivs.map((r, i) => (
        <span key={'r' + i} style={{ position: 'absolute', left: `${r.x}%`, top: 0, width: r.w, height: r.len, borderRadius: r.w, filter: 'blur(0.4px)', background: 'linear-gradient(to bottom, transparent, rgba(210,226,250,0.28) 58%, rgba(255,255,255,0.5))', animation: `mgriv ${r.dur}s cubic-bezier(.45,.05,.6,1) ${r.delay}s infinite` }}>
          <span style={{ position: 'absolute', bottom: -r.head / 2, left: '50%', transform: 'translateX(-50%)', width: r.head, height: r.head * 1.15, borderRadius: '50%', background: dropBG, boxShadow: dropSH }} />
        </span>
      ))}
    </div>
  );
}
function Frost() {
  return <div aria-hidden style={{ position: 'absolute', inset: 0, pointerEvents: 'none', background: 'radial-gradient(120% 92% at 50% 50%, transparent 56%, rgba(214,230,248,0.14) 82%, rgba(232,244,255,0.32))', mixBlendMode: 'screen' }} />;
}
function WeatherStyle() {
  return <style dangerouslySetInnerHTML={{ __html: `
    @keyframes mgriv { 0% { transform: translateY(-60px); opacity: 0; } 8% { opacity: 1; } 90% { opacity: 1; } 100% { transform: translateY(940px); opacity: 0; } }
    @keyframes mgbeadbob { 0%,100% { transform: translateY(0); } 50% { transform: translateY(1.2px); } }
  ` }} />;
}
function WeatherFX({ kind, night }) {
  const k = kind || 'clear';
  const tint = { rain: 'rgba(50,78,120,0.20)', heavyRain: 'rgba(34,52,92,0.30)', sleet: 'rgba(96,116,150,0.22)', snow: 'rgba(200,216,240,0.14)', cloudy: 'rgba(110,120,140,0.16)' }[k];
  const wet = k === 'rain' || k === 'heavyRain' || k === 'sleet';
  return (
    <div aria-hidden style={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden', zIndex: 5 }}>
      <WeatherStyle />
      {tint && <div style={{ position: 'absolute', inset: 0, background: tint, mixBlendMode: k === 'snow' ? 'screen' : 'multiply' }} />}
      {(k === 'clear' || night) && <GodRays night={night} />}
      {k === 'clear' && !night && <SunFlare />}
      {(k === 'cloudy' || wet) && <Clouds />}
      {wet && <Rain heavy={k !== 'rain'} />}
      {wet && <RainGlass heavy={k !== 'rain'} />}
      {(k === 'snow' || k === 'sleet') && <Snow />}
      {(k === 'snow' || k === 'sleet') && <Frost />}
    </div>
  );
}
function WeatherGlyph({ kind, color }) {
  const s = { width: 13, height: 13 };
  if (kind === 'clear') return <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8"><circle cx="12" cy="12" r="4.3" /><path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2M5.2 5.2l1.5 1.5M17.3 17.3l1.5 1.5M18.8 5.2l-1.5 1.5M6.7 17.3l-1.5 1.5" strokeLinecap="round" /></svg>;
  if (kind === 'cloudy') return <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8"><path d="M7 18h10a4 4 0 0 0 0-8 5 5 0 0 0-9.6-1.3A3.5 3.5 0 0 0 7 18z" /></svg>;
  if (kind === 'snow') return <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round"><path d="M12 3v18M3.5 7.5l17 9M20.5 7.5l-17 9" /></svg>;
  return <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round"><path d="M7 14h9a4 4 0 0 0 0-8 5 5 0 0 0-9.6-1.3A3.5 3.5 0 0 0 6 14" /><path d="M8 17l-1 2.5M12.5 17l-1 2.5M17 17l-1 2.5" /></svg>;
}
function WeatherPill({ kind }) {
  const w = WEATHER[kind] || WEATHER.clear;
  return (
    <Pill>
      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke={GOLD_DEEP} strokeWidth="2"><path d="M12 21s-7-5.5-7-11a7 7 0 0 1 14 0c0 5.5-7 11-7 11z" /><circle cx="12" cy="10" r="2.4" /></svg>
      <span style={{ fontFamily: mono, fontSize: 8, letterSpacing: '0.05em', color: INK_SOFT }}>Dubai</span>
      <span style={{ fontFamily: serif, fontWeight: 700, fontSize: 12, color: GOLD_DEEP, lineHeight: 1 }}>{w.temp}</span>
      <WeatherGlyph kind={kind} color={GOLD_DEEP} />
    </Pill>
  );
}

/* ============ persistent cinematic background ============ */
function Background({ night, weather, starlink }) {
  return (
    <React.Fragment>
      <div aria-hidden style={{ position: 'absolute', inset: 0, backgroundImage: 'url(assets/lambo_hero.jpg)', backgroundSize: 'cover', backgroundPosition: '50% 100%', backgroundRepeat: 'no-repeat', filter: night ? 'brightness(0.58) saturate(1.18) contrast(1.08)' : 'brightness(0.98) saturate(1.16) contrast(1.04)' }} />
      {/* carbon-fibre weave texture */}
      <div aria-hidden style={{ position: 'absolute', inset: 0, backgroundImage: carbon, backgroundSize: '6px 6px', opacity: 0.5, mixBlendMode: 'overlay' }} />
      <div style={{ position: 'absolute', inset: 0, background: night
        ? 'linear-gradient(180deg, rgba(8,10,14,0.62) 0%, rgba(10,12,16,0.28) 34%, rgba(6,8,12,0.5) 70%, rgba(3,4,7,0.8) 100%)'
        : 'linear-gradient(180deg, rgba(8,10,14,0.46) 0%, rgba(14,18,24,0.04) 40%, rgba(8,11,16,0.12) 76%, rgba(4,6,10,0.4) 100%)' }} />
      {night && <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(120% 80% at 70% 18%, rgba(232,140,90,0.2), transparent 60%)', mixBlendMode: 'screen' }} />}
      <div style={{ position: 'absolute', inset: 0, boxShadow: night ? 'inset 0 0 150px 34px rgba(0,0,0,0.62)' : 'inset 0 0 140px 30px rgba(0,0,0,0.5)' }} />
      {starlink && [0, 1, 2, 3, 4].map((i) => (
        <span key={i} style={{ position: 'absolute', top: `${12 + i * 7}%`, left: `${10 + i * 17}%`, width: 3, height: 3, borderRadius: '50%', background: '#fff', boxShadow: `0 0 7px 1.5px ${GOLD}`, animation: `mgorbit ${5 + i}s ${i * 0.6}s linear infinite` }} />
      ))}
      <WeatherFX kind={weather} night={night} />
    </React.Fragment>
  );
}

Object.assign(window, {
  GOLD, GOLD_DEEP, GOLD_BRIGHT, SPOTIFY, INK, INK_SOFT, INK_FAINT, serif, sans, mono, goldText, goldGlow, holo,
  glass, Refraction, Pill, Seal, Equalizer, WEATHER, WeatherFX, WeatherGlyph, WeatherPill, Background,
});
