// mangasm-screens.jsx — Profile / Settings / AI Match / Discover + nav. Exports to window.
const { useState, useEffect, useRef, useMemo } = React;
const { GOLD, GOLD_DEEP, GOLD_BRIGHT, SPOTIFY, INK, INK_SOFT, INK_FAINT, serif, sans, mono, goldText, goldGlow, holo,
  glass, Refraction, Pill, Seal, Equalizer, WeatherPill } = window;

/* ============ tiny shared controls ============ */
function Switch({ on, onClick, locked }) {
  return (
    <button onClick={locked ? undefined : onClick} aria-pressed={on} style={{
      width: 42, height: 24, borderRadius: 13, border: 'none', cursor: locked ? 'default' : 'pointer', padding: 2, flex: '0 0 auto',
      background: on ? `linear-gradient(135deg, ${GOLD_BRIGHT}, ${GOLD_DEEP})` : 'rgba(40,33,23,0.18)',
      boxShadow: on ? '0 0 10px -2px rgba(201,168,76,0.7), inset 0 1px 0 rgba(255,255,255,0.4)' : 'inset 0 1px 2px rgba(0,0,0,0.18)',
      opacity: locked ? 0.55 : 1, transition: 'all .2s', position: 'relative',
    }}>
      <span style={{ display: 'block', width: 20, height: 20, borderRadius: '50%', background: '#fff', transform: on ? 'translateX(18px)' : 'translateX(0)', transition: 'transform .2s', boxShadow: '0 1px 3px rgba(0,0,0,0.3)' }} />
    </button>
  );
}
function Field({ label, value, onChange, max, sanitize, hint }) {
  const count = (value || '').length;
  return (
    <div style={{ padding: '11px 13px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
        <span style={{ fontFamily: mono, fontSize: 8.5, letterSpacing: '0.1em', color: INK_FAINT }}>{label}</span>
        {max && <span style={{ fontFamily: mono, fontSize: 8, color: count > max ? '#c0392b' : INK_FAINT }}>{count}/{max}</span>}
      </div>
      <input value={value} maxLength={max} onChange={(e) => onChange(sanitize ? sanitize(e.target.value) : e.target.value)}
        style={{ width: '100%', marginTop: 6, background: 'rgba(255,255,255,0.55)', border: `1px solid ${GOLD}55`, borderRadius: 9, padding: '8px 10px', color: INK, fontFamily: sans, fontWeight: 600, fontSize: 13, outline: 'none' }} />
      {hint && <div style={{ fontFamily: mono, fontSize: 7.5, color: INK_FAINT, marginTop: 4 }}>{hint}</div>}
    </div>
  );
}
function Chip({ children, tone }) {
  const c = tone === 'gold' ? { bg: 'rgba(201,168,76,0.16)', bd: `${GOLD}66`, fg: GOLD_DEEP } : { bg: 'rgba(40,33,23,0.06)', bd: 'rgba(40,33,23,0.14)', fg: INK_SOFT };
  return <span style={{ fontFamily: sans, fontWeight: 700, fontSize: 9.5, padding: '4px 9px', borderRadius: 9, background: c.bg, border: `1px solid ${c.bd}`, color: c.fg, whiteSpace: 'nowrap' }}>{children}</span>;
}
function SectionLabel({ children }) {
  return <div style={{ fontFamily: serif, fontWeight: 700, fontSize: 15, letterSpacing: '0.16em', color: GOLD, margin: '4px 2px 8px', ...goldText, textShadow: goldGlow }}>{children}</div>;
}
function Card({ children, style }) {
  return (
    <div style={{ position: 'relative', borderRadius: 20, padding: 1, background: holo, boxShadow: '0 18px 44px -20px rgba(40,30,15,0.5)', ...style }}>
      <div style={{ position: 'relative', borderRadius: 19, overflow: 'hidden', ...glass(true, 0.5) }}>{children}</div>
    </div>
  );
}

/* ============ reputation ring ============ */
function RepRing({ value = 42, active }) {
  const [filled, setFilled] = useState(false);
  useEffect(() => { if (!active) { setFilled(false); return; } const id = setTimeout(() => setFilled(true), 90); return () => clearTimeout(id); }, [active]);
  const R = 33, C = 2 * Math.PI * R, off = C * (1 - (filled ? value : 0) / 100);
  return (
    <div style={{ position: 'relative', width: 84, height: 84, display: 'grid', placeItems: 'center', flex: '0 0 auto' }}>
      <div style={{ position: 'absolute', inset: 0, borderRadius: '50%', background: 'conic-gradient(from 0deg, #C9A84C, #ffffff, #b0cdeb, #C9A84C, #ffffff, #C9A84C)', WebkitMask: 'radial-gradient(circle, transparent 36px, #000 37px)', mask: 'radial-gradient(circle, transparent 36px, #000 37px)', opacity: 0.9, animation: 'mgspin 16s linear infinite', filter: 'drop-shadow(0 0 5px rgba(201,168,76,0.35))' }} />
      <svg width="84" height="84" viewBox="0 0 84 84" style={{ transform: 'rotate(-90deg)' }}>
        <defs><linearGradient id="goldarc2" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor={GOLD_BRIGHT} /><stop offset="100%" stopColor={GOLD_DEEP} /></linearGradient></defs>
        <circle cx="42" cy="42" r={R} fill="none" stroke="rgba(40,33,23,0.16)" strokeWidth="3" />
        <circle cx="42" cy="42" r={R} fill="none" stroke="url(#goldarc2)" strokeWidth="3.5" strokeLinecap="round" strokeDasharray={C} strokeDashoffset={off} style={{ filter: 'drop-shadow(0 0 4px rgba(201,168,76,0.6))', transition: 'stroke-dashoffset 1.2s cubic-bezier(.2,.8,.2,1)' }} />
      </svg>
      <div style={{ position: 'absolute', display: 'grid', placeItems: 'center', textAlign: 'center' }}>
        <span style={{ fontFamily: serif, fontWeight: 700, fontSize: 34, lineHeight: 0.85, ...goldText, textShadow: goldGlow }}>{value}</span>
        <span style={{ fontFamily: mono, fontSize: 7, letterSpacing: '0.24em', color: INK_FAINT, marginTop: 1, paddingLeft: '0.24em' }}>REP</span>
      </div>
    </div>
  );
}

/* ============ spotify anthem ============ */
function Anthem() {
  const [open, setOpen] = useState(false);
  const recent = [{ t: 'Midnight City', a: 'M83' }, { t: 'Flashing Lights', a: 'Kanye West' }, { t: 'Teenage Dream', a: 'Olly Alexander' }];
  const [pick, setPick] = useState(0);
  return (
    <div style={{ marginTop: 12 }}>
      <button onClick={() => setOpen((o) => !o)} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 11, padding: '9px 11px', borderRadius: 14, cursor: 'pointer', textAlign: 'left', color: '#fff', ...glass(false, 0.34), border: `1px solid ${SPOTIFY}55` }}>
        <div style={{ width: 42, height: 42, flex: '0 0 auto', borderRadius: 9, overflow: 'hidden' }}><image-slot id="mg-anthem" shape="rounded" radius="9" style={{ width: 42, height: 42, display: 'block' }} placeholder="art"></image-slot></div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 13, height: 13, borderRadius: '50%', background: SPOTIFY, display: 'grid', placeItems: 'center', flex: '0 0 auto' }}><Equalizer color="#06140b" n={3} /></span>
            <span style={{ fontFamily: mono, fontSize: 7, letterSpacing: '0.16em', color: SPOTIFY }}>MY ANTHEM</span>
          </div>
          <div style={{ fontFamily: sans, fontWeight: 700, fontSize: 12.5, color: INK, marginTop: 3, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{recent[pick].t}</div>
          <div style={{ fontFamily: sans, fontWeight: 400, fontSize: 10, color: INK_SOFT }}>{recent[pick].a}</div>
        </div>
        <Equalizer color={SPOTIFY} n={4} />
      </button>
      {open && (
        <div style={{ marginTop: 7, borderRadius: 13, overflow: 'hidden', ...glass(false, 0.4) }}>
          <div style={{ fontFamily: mono, fontSize: 7.5, letterSpacing: '0.14em', color: INK_FAINT, padding: '9px 12px 4px' }}>RECENTLY PLAYED · PICK YOUR ANTHEM</div>
          {recent.map((r, i) => (
            <button key={i} onClick={() => { setPick(i); setOpen(false); }} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px', cursor: 'pointer', background: i === pick ? 'rgba(19,138,62,0.12)' : 'transparent', border: 'none', borderTop: '1px solid rgba(40,33,23,0.08)', textAlign: 'left' }}>
              <span style={{ width: 28, height: 28, borderRadius: 6, background: 'rgba(40,33,23,0.08)', flex: '0 0 auto', display: 'grid', placeItems: 'center' }}><svg width="13" height="13" viewBox="0 0 24 24" fill={INK_FAINT}><path d="M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z" /></svg></span>
              <span style={{ flex: 1 }}><span style={{ display: 'block', fontFamily: sans, fontWeight: 700, fontSize: 11.5, color: INK }}>{r.t}</span><span style={{ display: 'block', fontFamily: sans, fontSize: 9.5, color: INK_SOFT }}>{r.a}</span></span>
              {i === pick && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={SPOTIFY} strokeWidth="3" strokeLinecap="round"><path d="M5 13l4 4L19 6" /></svg>}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

/* ============ social button ============ */
function Social({ kind, handle }) {
  const ig = kind === 'ig';
  const href = ig ? `https://instagram.com/${handle}` : `https://x.com/${handle}`;
  return (
    <a href={href} target="_blank" rel="noreferrer" style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '7px 11px', borderRadius: 11, textDecoration: 'none', flex: 1, ...glass(false, 0.3), border: `1px solid ${GOLD}33` }}>
      {ig ? (
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={GOLD} strokeWidth="1.8"><rect x="3" y="3" width="18" height="18" rx="5" /><circle cx="12" cy="12" r="4" /><circle cx="17.5" cy="6.5" r="1" fill={GOLD} stroke="none" /></svg>
      ) : (
        <svg width="13" height="13" viewBox="0 0 24 24" fill={GOLD}><path d="M18.9 2H22l-7.5 8.6L23 22h-6.8l-5-6.6L5.4 22H2.3l8-9.2L1.5 2h6.9l4.5 6 5.2-6zm-2.4 18h1.9L7.6 4H5.6l10.9 16z" /></svg>
      )}
      <span style={{ fontFamily: sans, fontWeight: 700, fontSize: 11, color: INK }}>@{handle}</span>
    </a>
  );
}

/* ============ draggable AIM bubble ============ */
function ChatBubble({ init, tail = 'left', children }) {
  const [pos, setPos] = useState(init);
  const drag = useRef(null);
  const onDown = (e) => {
    const pt = e.touches ? e.touches[0] : e;
    drag.current = { x: pt.clientX - pos.x, y: pt.clientY - pos.y };
    const move = (ev) => { const p = ev.touches ? ev.touches[0] : ev; setPos({ x: p.clientX - drag.current.x, y: p.clientY - drag.current.y }); };
    const up = () => { window.removeEventListener('pointermove', move); window.removeEventListener('pointerup', up); };
    window.addEventListener('pointermove', move); window.addEventListener('pointerup', up);
  };
  return (
    <div onPointerDown={onDown} style={{ position: 'absolute', left: pos.x, top: pos.y, zIndex: 45, cursor: 'grab', touchAction: 'none', maxWidth: 196, padding: '9px 12px 10px', borderRadius: 17, color: INK, ...glass(true, 0.62), boxShadow: '0 12px 30px -8px rgba(40,30,15,0.35), inset 0 1px 0 rgba(255,255,255,0.7), 0 0 22px -10px rgba(201,168,76,0.6)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
        <div style={{ width: 18, height: 18, borderRadius: '50%', flex: '0 0 auto', background: `linear-gradient(135deg, ${GOLD}, ${GOLD_DEEP})`, boxShadow: '0 0 8px rgba(201,168,76,0.55)' }} />
        {children}
      </div>
      <div style={{ position: 'absolute', bottom: -5, [tail]: 20, width: 12, height: 12, transform: 'rotate(45deg)', background: 'rgba(252,248,241,0.62)', borderRight: '0.7px solid rgba(255,255,255,0.7)', borderBottom: '0.7px solid rgba(255,255,255,0.7)', backdropFilter: 'blur(18px)' }} />
    </div>
  );
}

/* ============ top bar (persistent) ============ */
function TopBar({ weather, starlink, onSettings, settingsOpen }) {
  return (
    <div style={{ position: 'absolute', top: 46, left: 14, right: 14, zIndex: 30, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', pointerEvents: 'none' }}>
      {/* reputation — left */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'flex-start', pointerEvents: 'auto' }}>
        <div style={{ lineHeight: 1 }}>
          <div style={{ fontFamily: mono, fontSize: 7.5, letterSpacing: '0.22em', color: INK_SOFT }}>REPUTATION</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginTop: 3 }}>
            <span style={{ fontFamily: serif, fontWeight: 700, fontSize: 38, ...goldText, textShadow: goldGlow, lineHeight: 0.8 }}>42</span>
            <span style={{ fontFamily: serif, fontStyle: 'italic', fontWeight: 600, fontSize: 13, color: GOLD_DEEP, display: 'inline-flex', alignItems: 'center', gap: 4 }}>Veteran<Seal size={12} /></span>
          </div>
        </div>
        <WeatherPill kind={weather} />
        {starlink && <Pill glow><span style={{ width: 5, height: 5, borderRadius: '50%', background: GOLD, boxShadow: `0 0 6px ${GOLD}`, animation: 'mgpulse 1.6s infinite' }} /><span style={{ fontFamily: mono, fontSize: 8, letterSpacing: '0.1em', color: GOLD_DEEP }}>STARLINK</span></Pill>}
      </div>
      {/* logo — center */}
      <div style={{ textAlign: 'center', marginTop: 2, flex: '0 0 auto' }}>
        <div style={{ fontFamily: serif, fontWeight: 700, fontSize: 31, ...goldText, textShadow: '0 1px 12px rgba(201,168,76,0.4), 0 1px 2px rgba(255,255,255,0.5)', lineHeight: 1, letterSpacing: '0.01em' }}>Mangasm</div>
      </div>
      {/* private lock + settings — right */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'flex-end', pointerEvents: 'auto' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, padding: '6px 11px', borderRadius: 13, ...glass(true, 0.5), border: `1px solid ${GOLD}77`, boxShadow: '0 6px 16px -6px rgba(40,30,15,0.4), inset 0 1px 0 rgba(255,255,255,0.7)' }}>
          <span style={{ fontFamily: serif, fontWeight: 700, fontSize: 10.5, letterSpacing: '0.14em', color: GOLD_DEEP }}>PRIVATE</span>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={GOLD_DEEP} strokeWidth="2"><path d="M6 10V8a6 6 0 0 1 12 0v2" /><rect x="4" y="10" width="16" height="11" rx="2.5" /><circle cx="12" cy="15" r="1.4" fill={GOLD_DEEP} stroke="none" /></svg>
        </div>
        <button onClick={onSettings} style={{ width: 30, height: 30, borderRadius: 10, display: 'grid', placeItems: 'center', cursor: 'pointer', ...glass(true, 0.5), border: `1px solid ${GOLD}55` }}>
          {settingsOpen ? (
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={GOLD_DEEP} strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg>
          ) : (
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={GOLD_DEEP} strokeWidth="1.8"><circle cx="12" cy="12" r="3" /><path d="M19.4 13a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-2.7 1.1V21a2 2 0 0 1-4 0v-.2a1.6 1.6 0 0 0-2.7-1.1l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1A1.6 1.6 0 0 0 4.6 13H4.5a2 2 0 0 1 0-4h.1a1.6 1.6 0 0 0 1.1-2.7l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1A1.6 1.6 0 0 0 11 4.6V4.5a2 2 0 0 1 4 0v.1a1.6 1.6 0 0 0 2.7 1.1l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0 1.1 2.7h.1a2 2 0 0 1 0 4h-.2Z" /></svg>
          )}
        </button>
      </div>
    </div>
  );
}

/* ============ scroll wrapper ============ */
function Scroll({ children }) {
  return <div className="mg-scroll" style={{ position: 'absolute', inset: 0, zIndex: 10, overflowY: 'auto', overflowX: 'hidden', padding: '150px 14px 96px' }}>{children}</div>;
}

window.MangasmUI = { Switch, Field, Chip, SectionLabel, Card, RepRing, Anthem, Social, ChatBubble, TopBar, Scroll };
