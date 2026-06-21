// mangasm-chat.jsx — glassmorphic floating-bubble messaging. Exports to window.MangasmUI.
const { GOLD: cG, GOLD_DEEP: cGD, GOLD_BRIGHT: cGB, SPOTIFY: cSP, INK: cINK, INK_SOFT: cINKS, serif: cSerif, sans: cSans, mono: cMono, glass: cGlass, goldText: cGoldText } = window;
const cIMG = (id, s = 120) => `https://images.unsplash.com/photo-${id}?w=${s}&h=${s}&q=80&auto=format&fit=crop&crop=faces`;
const CHAT_IMG = { m1: '1507003211169-0a1dd7228f2d', m2: '1500648767791-00dcc994a43e', m3: '1519085360753-af0119f7cbe7', m4: '1492562080023-ab3db95bfbce', m5: '1463453091185-61582044d556' };

function ChatScreen({ candidate: c, onBack }) {
  const [msgs, setMsgs] = React.useState([
    { me: false, text: 'Hey — the stars said 94%. Bold of them 😏' },
    { me: true, text: "They don't lie. Dubai this weekend?" },
    { me: false, text: 'That hot-air balloon date looked unreal 🎈' },
  ]);
  const [draft, setDraft] = React.useState('');
  const [typing, setTyping] = React.useState(false);
  const bodyRef = React.useRef(null);
  const REPLIES = ['Okay you have my attention.', 'Pick the time — I’ll bring the wine 🍷', 'RSVP me. I’m serious.', 'You’re trouble. I like it.'];
  const rIdx = React.useRef(0);
  React.useEffect(() => { const el = bodyRef.current; if (el) el.scrollTop = el.scrollHeight; }, [msgs, typing]);
  const send = () => {
    const text = draft.trim(); if (!text) return;
    setMsgs((m) => [...m, { me: true, text }]); setDraft(''); setTyping(true);
    setTimeout(() => { setTyping(false); setMsgs((m) => [...m, { me: false, text: REPLIES[rIdx.current % REPLIES.length] }]); rIdx.current += 1; }, 1100);
  };

  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 60, display: 'flex', flexDirection: 'column' }}>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(248,245,239,0.28)', backdropFilter: 'blur(2px)' }} />

      {/* header */}
      <div style={{ position: 'relative', zIndex: 2, display: 'flex', alignItems: 'center', gap: 11, padding: '50px 14px 12px', ...cGlass(true, 0.62), borderBottom: `1px solid ${cG}44`, boxShadow: '0 10px 28px -12px rgba(40,30,15,0.35)' }}>
        <button onClick={onBack} style={{ width: 32, height: 32, borderRadius: 10, display: 'grid', placeItems: 'center', cursor: 'pointer', ...cGlass(true, 0.5), border: `1px solid ${cG}55` }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={cGD} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 6l-6 6 6 6" /></svg>
        </button>
        <div style={{ width: 38, height: 38, borderRadius: '50%', overflow: 'hidden', flex: '0 0 auto', border: `2px solid ${cG}`, boxShadow: '0 0 10px rgba(201,168,76,0.45)' }}>
          <img src={cIMG(CHAT_IMG[c.id] || '1507003211169-0a1dd7228f2d', 96)} alt="" style={{ width: 38, height: 38, objectFit: 'cover', display: 'block' }} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: cSerif, fontWeight: 700, fontSize: 19, color: cINK, lineHeight: 1 }}>{c.name}</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 2 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: cSP, boxShadow: `0 0 6px ${cSP}` }} />
            <span style={{ fontFamily: cMono, fontSize: 8, letterSpacing: '0.08em', color: cINKS }}>Online · {c.dist} away</span>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '4px 9px', borderRadius: 11, ...cGlass(true, 0.5), border: `1px solid ${cG}55` }}>
          <span style={{ fontFamily: cSerif, fontWeight: 700, fontSize: 13, ...cGoldText }}>{c.m}%</span>
        </div>
      </div>

      {/* messages — floating glass bubbles */}
      <div ref={bodyRef} className="mg-scroll" style={{ position: 'relative', zIndex: 2, flex: 1, overflowY: 'auto', padding: '18px 14px 8px' }}>
        <div style={{ textAlign: 'center', marginBottom: 16 }}>
          <span style={{ fontFamily: cMono, fontSize: 7.5, letterSpacing: '0.14em', color: cINKS, padding: '5px 11px', borderRadius: 20, ...cGlass(true, 0.5) }}>END-TO-END ENCRYPTED · PRIVACY ZONES ON</span>
        </div>
        {msgs.map((m, i) => (
          <div key={i} style={{ display: 'flex', justifyContent: m.me ? 'flex-end' : 'flex-start', marginBottom: 13 }}>
            <div style={{
              position: 'relative', maxWidth: '76%', padding: '10px 13px', borderRadius: 18, color: m.me ? '#3a2c08' : cINK,
              animation: `mgpop .42s ${i * 0.05}s both, mgfloat ${4 + (i % 3)}s ${i * 0.35}s ease-in-out infinite`,
              backdropFilter: 'blur(18px) saturate(150%)', WebkitBackdropFilter: 'blur(18px) saturate(150%)',
              background: m.me ? 'linear-gradient(135deg, rgba(248,236,200,0.85), rgba(228,201,126,0.7))' : 'rgba(255,253,249,0.7)',
              border: m.me ? `1px solid ${cG}` : '0.7px solid rgba(255,255,255,0.8)',
              boxShadow: m.me ? '0 12px 30px -12px rgba(201,168,76,0.5), inset 0 1px 0 rgba(255,255,255,0.5)' : '0 12px 30px -12px rgba(40,30,15,0.3), inset 0 1px 0 rgba(255,255,255,0.7)',
            }}>
              <span style={{ fontFamily: cSans, fontWeight: m.me ? 600 : 500, fontSize: 12.5, lineHeight: 1.4 }}>{m.text}</span>
              <div style={{ position: 'absolute', bottom: -4, [m.me ? 'right' : 'left']: 17, width: 11, height: 11, transform: 'rotate(45deg)', background: m.me ? 'rgba(232,201,126,0.8)' : 'rgba(255,253,249,0.7)', borderRight: m.me ? `1px solid ${cG}` : '0.7px solid rgba(255,255,255,0.8)', borderBottom: m.me ? `1px solid ${cG}` : '0.7px solid rgba(255,255,255,0.8)' }} />
            </div>
          </div>
        ))}
        {typing && (
          <div style={{ display: 'flex', justifyContent: 'flex-start', marginBottom: 13 }}>
            <div style={{ display: 'flex', gap: 4, padding: '12px 14px', borderRadius: 18, ...cGlass(true, 0.6), border: '0.7px solid rgba(255,255,255,0.8)' }}>
              {[0, 1, 2].map((d) => <span key={d} style={{ width: 6, height: 6, borderRadius: '50%', background: 'rgba(42,33,23,0.5)', animation: `mgpulse 1s ${d * 0.18}s infinite` }} />)}
            </div>
          </div>
        )}
      </div>

      {/* composer */}
      <div style={{ position: 'relative', zIndex: 2, display: 'flex', alignItems: 'center', gap: 9, padding: '10px 14px 26px' }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, padding: '4px 6px 4px 14px', borderRadius: 22, ...cGlass(true, 0.62), border: `1px solid ${cG}55`, boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.7)' }}>
          <input value={draft} onChange={(e) => setDraft(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter') send(); }} placeholder="Message…" style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: cINK, fontFamily: cSans, fontWeight: 500, fontSize: 13, padding: '8px 0' }} />
          <button onClick={send} style={{ width: 36, height: 36, borderRadius: '50%', flex: '0 0 auto', border: 'none', cursor: 'pointer', display: 'grid', placeItems: 'center', background: `linear-gradient(135deg, ${cGB}, ${cGD})`, boxShadow: '0 4px 14px -3px rgba(201,168,76,0.7), inset 0 1px 0 rgba(255,255,255,0.5)' }}>
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#3a2c08" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 2 11 13M22 2l-7 20-4-9-9-4 20-7z" /></svg>
          </button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window.MangasmUI, { ChatScreen });
