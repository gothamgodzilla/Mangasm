// mangasm-events.jsx — Discover sub-tabs: Communities + Events (host flow, M+ gated). Exports to window.MangasmUI.
const { GOLD: eG, GOLD_DEEP: eGD, GOLD_BRIGHT: eGB, SPOTIFY: eSP, INK: eINK, INK_SOFT: eINKS, INK_FAINT: eINKF,
  serif: eSerif, sans: eSans, mono: eMono, goldText: eGoldText, goldGlow: eGoldGlow, holo: eHolo, glass: eGlass } = window;
const eUI = window.MangasmUI;
const eIMG = (id, s = 120) => `https://images.unsplash.com/photo-${id}?w=${s}&h=${s}&q=80&auto=format&fit=crop&crop=faces`;
const PRIDE = 'linear-gradient(90deg, #e40303, #ff8c00 22%, #ffed00 42%, #008026 62%, #004dff 80%, #750787)';

/* ============ event-type glyphs ============ */
const ETYPES = [
  { id: 'glory', label: 'Glory Hole', d: 'M3 6h18v12H3z', extra: 'circle:12,12,3' },
  { id: 'cumgo', label: 'Cum & Go', d: 'M12 3s6 7 6 11a6 6 0 0 1-12 0c0-4 6-11 6-11z', extra: '' },
  { id: 'circle', label: 'Circle Jerk', d: '', extra: 'ring' },
  { id: 'cosplay', label: 'Cosplay / Roleplay', d: 'M4 8c5-2.4 11-2.4 16 0 0 7-4 10-8 10S4 15 4 8z', extra: 'eyes' },
];
function TypeGlyph({ type, size = 18, color = eG, sw = 1.7 }) {
  const t = ETYPES.find((x) => x.id === type) || ETYPES[0];
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      {t.d && <path d={t.d} />}
      {t.extra === 'circle:12,12,3' && <circle cx="12" cy="12" r="3" />}
      {t.extra === 'ring' && <React.Fragment><circle cx="12" cy="12" r="8.5" /><circle cx="12" cy="12" r="2.4" /></React.Fragment>}
      {t.extra === 'eyes' && <React.Fragment><circle cx="9" cy="10.5" r="0.9" fill={color} /><circle cx="15" cy="10.5" r="0.9" fill={color} /></React.Fragment>}
    </svg>
  );
}
const typeLabel = (id) => (ETYPES.find((x) => x.id === id) || {}).label || id;

/* ============ segmented control ============ */
function DiscoverTabs({ tab, setTab }) {
  const TABS = [{ id: 'nearby', l: 'Nearby' }, { id: 'communities', l: 'Communities' }, { id: 'events', l: 'Events' }];
  return (
    <div style={{ display: 'flex', gap: 4, padding: 4, borderRadius: 15, marginBottom: 14, ...eGlass(true, 0.55) }}>
      {TABS.map((t) => {
        const on = tab === t.id;
        return (
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            flex: 1, padding: '8px 4px', borderRadius: 11, cursor: 'pointer', border: 'none',
            fontFamily: eSerif, fontWeight: 700, fontSize: 12, letterSpacing: '0.05em',
            color: on ? '#2a1d05' : eINKS,
            background: on ? `linear-gradient(135deg, ${eGB}, ${eGD})` : 'transparent',
            boxShadow: on ? '0 4px 12px -4px rgba(201,168,76,0.7), inset 0 1px 0 rgba(255,255,255,0.5)' : 'none',
            transition: 'all .2s',
          }}>{t.l}</button>
        );
      })}
    </div>
  );
}

/* ============ Communities ============ */
const COMMS = [
  { id: 'c1', name: 'Pride Marina', tag: 'Social · Allies welcome', members: '4.2k', mono: 'PM' },
  { id: 'c2', name: 'Bears & Cubs UAE', tag: 'Body positive', members: '2.8k', mono: 'BC' },
  { id: 'c3', name: 'Leather & Fetish', tag: 'Kink · Gear', members: '1.9k', mono: 'LF' },
  { id: 'c4', name: 'Trans+ & Allies', tag: 'Support · Safe space', members: '1.1k', mono: 'TA' },
  { id: 'c5', name: 'PrEP & Poz Friendly', tag: 'Health · Stigma-free', members: '3.5k', mono: 'PP' },
  { id: 'c6', name: 'House & After-Hours', tag: 'Music · Nightlife', members: '5.6k', mono: 'HA' },
];
function CommunityCard({ c }) {
  const [joined, setJoined] = React.useState(false);
  return (
    <div style={{ position: 'relative', borderRadius: 16, padding: 1, background: eHolo, boxShadow: '0 12px 30px -16px rgba(40,30,15,0.5)' }}>
      <div style={{ borderRadius: 15, overflow: 'hidden', ...eGlass(true, 0.5) }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '11px 12px' }}>
          <div style={{ width: 42, height: 42, flex: '0 0 auto', borderRadius: 12, display: 'grid', placeItems: 'center', background: 'rgba(201,168,76,0.14)', border: `1px solid ${eG}55` }}>
            <span style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 15, ...eGoldText }}>{c.mono}</span>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 15, color: eINK, lineHeight: 1.05 }}>{c.name}</div>
            <div style={{ fontFamily: eSans, fontWeight: 300, fontSize: 9.5, color: eINKS, marginTop: 1 }}>{c.tag}</div>
            <div style={{ fontFamily: eMono, fontSize: 7.5, letterSpacing: '0.08em', color: eINKF, marginTop: 3 }}>{c.members} MEMBERS</div>
          </div>
          <button onClick={() => setJoined((j) => !j)} style={{
            flex: '0 0 auto', padding: '7px 14px', borderRadius: 10, cursor: 'pointer',
            fontFamily: eSerif, fontWeight: 700, fontSize: 11.5, letterSpacing: '0.04em',
            color: joined ? eGD : '#2a1d05',
            background: joined ? 'transparent' : `linear-gradient(135deg, ${eGB}, ${eGD})`,
            border: joined ? `1px solid ${eG}66` : 'none',
            boxShadow: joined ? 'none' : '0 4px 12px -4px rgba(201,168,76,0.7)',
          }}>{joined ? 'Joined' : 'Join'}</button>
        </div>
        <div style={{ height: 2.5, background: PRIDE, opacity: 0.7 }} />
      </div>
    </div>
  );
}
function CommunitiesView() {
  return (
    <React.Fragment>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
        <eUI.SectionLabel>LGBTQ+ COMMUNITIES</eUI.SectionLabel>
        <span style={{ fontFamily: eMono, fontSize: 8, color: eINKF }}>6 near you</span>
      </div>
      <p style={{ fontFamily: eSans, fontWeight: 300, fontSize: 10, color: eINKS, margin: '0 0 13px', lineHeight: 1.5 }}>Verified, member-moderated spaces. Join to see group chats, drops & member-only events.</p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {COMMS.map((c) => <CommunityCard key={c.id} c={c} />)}
      </div>
    </React.Fragment>
  );
}

/* ============ Events ============ */
const SEED_EVENTS = [
  { id: 'e1', type: 'circle', title: 'Sunset Circle', host: 'Marco', rep: 88, img: '1507003211169-0a1dd7228f2d', when: 'Tonight · 10:30 PM', place: 'Marina Penthouse', area: 'Dubai Marina', desc: 'Low-lit lounge, house music, clothing optional. Discreet, respectful crowd only.', going: 9, cap: 12, privacy: 'approval' },
  { id: 'e2', type: 'cosplay', title: 'Latex & Leather Night', host: 'Sven', rep: 74, img: '1492562080023-ab3db95bfbce', when: 'Sat · 11:00 PM', place: 'Private villa', area: 'Palm Jumeirah', desc: 'Full gear encouraged — officer, athlete, exec themes. Lockers & wash on site.', going: 18, cap: 30, privacy: 'public' },
  { id: 'e3', type: 'glory', title: 'Anon Booth', host: 'Rafa', rep: 81, img: '1519085360753-af0119f7cbe7', when: 'Fri · 9:00 PM', place: 'Studio loft', area: 'JBR', desc: 'Anonymous setup, sanitized booths, condoms & PrEP-friendly. ID checked at door.', going: 6, cap: 10, privacy: 'approval' },
  { id: 'e4', type: 'cumgo', title: 'Lunch Express', host: 'Theo', rep: 69, img: '1500648767791-00dcc994a43e', when: 'Today · 1:00 PM', place: 'Business Bay tower', area: 'Business Bay', desc: 'Quick, discreet, in-and-out. Twenty-minute slots — book your time ahead.', going: 4, cap: 8, privacy: 'public' },
];
function MetaRow({ icon, children }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6 }}>
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke={eGD} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ flex: '0 0 auto' }}>{icon}</svg>
      <span style={{ fontFamily: eSans, fontWeight: 600, fontSize: 10.5, color: eINKS }}>{children}</span>
    </div>
  );
}
function EventCard({ ev }) {
  const [rsvp, setRsvp] = React.useState(false);
  const left = Math.max(ev.cap - ev.going - (rsvp ? 1 : 0), 0);
  const priv = ev.privacy === 'approval';
  return (
    <div style={{ position: 'relative', borderRadius: 18, padding: 1, background: eHolo, boxShadow: '0 16px 38px -18px rgba(40,30,15,0.55)' }}>
      <div style={{ borderRadius: 17, overflow: 'hidden', ...eGlass(true, 0.5) }}>
        <div style={{ padding: '12px 13px 13px' }}>
          {/* header */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 34, height: 34, flex: '0 0 auto', borderRadius: 10, display: 'grid', placeItems: 'center', background: 'rgba(201,168,76,0.13)', border: `1px solid ${eG}44` }}>
              <TypeGlyph type={ev.type} />
            </span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: eMono, fontSize: 7, letterSpacing: '0.16em', color: eG }}>{typeLabel(ev.type).toUpperCase()}</div>
              <div style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 16, color: eINK, lineHeight: 1.1 }}>{ev.title}</div>
            </div>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: '4px 8px', borderRadius: 8, flex: '0 0 auto', background: priv ? 'rgba(201,168,76,0.14)' : 'rgba(19,138,62,0.12)', border: `1px solid ${priv ? eG + '55' : eSP + '55'}` }}>
              {priv
                ? <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke={eGD} strokeWidth="2.4"><rect x="5" y="11" width="14" height="9" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></svg>
                : <span style={{ width: 6, height: 6, borderRadius: '50%', background: eSP, boxShadow: `0 0 5px ${eSP}` }} />}
              <span style={{ fontFamily: eMono, fontSize: 6.5, letterSpacing: '0.08em', color: priv ? eGD : eSP }}>{priv ? 'APPROVAL' : 'OPEN'}</span>
            </span>
          </div>

          {/* host */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 10 }}>
            <img src={eIMG(ev.img, 60)} alt="" style={{ width: 22, height: 22, borderRadius: '50%', objectFit: 'cover', display: 'block', border: `1px solid ${eG}66` }} />
            <span style={{ fontFamily: eSans, fontWeight: 600, fontSize: 10.5, color: eINK }}>{ev.host}</span>
            <span style={{ fontFamily: eMono, fontSize: 7.5, color: eINKF }}>· REP {ev.rep}</span>
          </div>

          {/* desc */}
          <p style={{ fontFamily: eSans, fontWeight: 300, fontSize: 11, lineHeight: 1.5, color: eINKS, margin: '9px 0 0', textWrap: 'pretty' }}>{ev.desc}</p>

          {/* meta */}
          <MetaRow icon={<React.Fragment><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></React.Fragment>}>{ev.when}</MetaRow>
          <MetaRow icon={<React.Fragment><path d="M12 21s-7-5.2-7-10a7 7 0 0 1 14 0c0 4.8-7 10-7 10z" /><circle cx="12" cy="11" r="2.4" /></React.Fragment>}>{ev.place} · {ev.area}{priv ? ' · exact address on approval' : ''}</MetaRow>

          {/* attendees + cta */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 10, marginTop: 12 }}>
            <span style={{ fontFamily: eMono, fontSize: 8.5, color: eINKS }}>{ev.going + (rsvp ? 1 : 0)} going · <span style={{ color: left <= 3 ? eGD : eINKF }}>{left} left</span></span>
            <button onClick={() => setRsvp((r) => !r)} style={{
              padding: '8px 16px', borderRadius: 11, cursor: 'pointer', border: rsvp ? `1px solid ${eSP}66` : 'none',
              fontFamily: eSerif, fontWeight: 700, fontSize: 12.5, letterSpacing: '0.04em',
              color: rsvp ? eSP : '#2a1d05',
              background: rsvp ? 'rgba(19,138,62,0.12)' : `linear-gradient(135deg, ${eGB}, ${eGD})`,
              boxShadow: rsvp ? 'none' : '0 4px 14px -4px rgba(201,168,76,0.7)',
            }}>{rsvp ? (priv ? 'Requested' : "You're in") : (priv ? 'Request' : 'RSVP')}</button>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ----- host form (M+ only) ----- */
function HostInput({ label, value, onChange, placeholder, area, max }) {
  const Tag = area ? 'textarea' : 'input';
  return (
    <div style={{ marginTop: 11 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
        <span style={{ fontFamily: eMono, fontSize: 8, letterSpacing: '0.1em', color: eINKF }}>{label}</span>
        {max && <span style={{ fontFamily: eMono, fontSize: 7.5, color: eINKF }}>{(value || '').length}/{max}</span>}
      </div>
      <Tag value={value} maxLength={max} placeholder={placeholder} onChange={(e) => onChange(e.target.value)} rows={area ? 3 : undefined}
        style={{ width: '100%', marginTop: 5, resize: 'none', background: 'rgba(255,255,255,0.5)', border: `1px solid ${eG}55`, borderRadius: 9, padding: '8px 10px', color: eINK, fontFamily: eSans, fontWeight: 600, fontSize: 12, lineHeight: 1.45, outline: 'none', boxSizing: 'border-box' }} />
    </div>
  );
}
function HostForm({ onPublish, onCancel }) {
  const [type, setType] = React.useState('circle');
  const [f, setF] = React.useState({ title: '', desc: '', when: '', place: '', area: '', cap: '12' });
  const [priv, setPriv] = React.useState('approval');
  const set = (k, v) => setF((p) => ({ ...p, [k]: v }));
  const ready = f.title.trim() && f.desc.trim() && f.when.trim() && f.place.trim();
  return (
    <div style={{ position: 'relative', borderRadius: 20, padding: 1.3, background: eHolo, boxShadow: '0 22px 54px -20px rgba(40,30,15,0.6)', marginBottom: 16 }}>
      <div style={{ borderRadius: 19, overflow: 'hidden', ...eGlass(true, 0.55), padding: '15px 15px 16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
            <span style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 18, ...eGoldText, textShadow: eGoldGlow }}>Host an Event</span>
            <span style={{ fontFamily: eMono, fontSize: 7, padding: '2px 6px', borderRadius: 6, background: `${eG}22`, border: `1px solid ${eG}66`, color: eGD }}>M+</span>
          </div>
          <button onClick={onCancel} style={{ width: 26, height: 26, borderRadius: 8, display: 'grid', placeItems: 'center', cursor: 'pointer', background: 'transparent', border: '1px solid rgba(40,33,23,0.16)' }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke={eINKS} strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg>
          </button>
        </div>

        {/* type picker */}
        <div style={{ fontFamily: eMono, fontSize: 8, letterSpacing: '0.1em', color: eINKF, margin: '13px 0 7px' }}>EVENT TYPE</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 7 }}>
          {ETYPES.map((t) => {
            const on = type === t.id;
            return (
              <button key={t.id} onClick={() => setType(t.id)} style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '9px 10px', borderRadius: 11, cursor: 'pointer', textAlign: 'left',
                background: on ? 'rgba(201,168,76,0.16)' : 'rgba(40,33,23,0.05)',
                border: on ? `1px solid ${eG}` : '1px solid rgba(40,33,23,0.12)',
              }}>
                <TypeGlyph type={t.id} size={17} color={on ? eGD : eINKS} />
                <span style={{ fontFamily: eSans, fontWeight: 700, fontSize: 10.5, color: on ? eGD : eINKS }}>{t.label}</span>
              </button>
            );
          })}
        </div>

        <HostInput label="EVENT TITLE" value={f.title} max={32} placeholder="e.g. Sunset Circle" onChange={(v) => set('title', v)} />
        <HostInput label="DESCRIPTION" area value={f.desc} max={160} placeholder="Vibe, dress code, rules, safety notes…" onChange={(v) => set('desc', v)} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 9 }}>
          <HostInput label="DATE & TIME" value={f.when} max={20} placeholder="Sat · 11 PM" onChange={(v) => set('when', v)} />
          <HostInput label="CAPACITY" value={f.cap} max={3} placeholder="12" onChange={(v) => set('cap', v.replace(/[^0-9]/g, ''))} />
        </div>
        <HostInput label="PLACE / VENUE" value={f.place} max={28} placeholder="Marina Penthouse" onChange={(v) => set('place', v)} />
        <HostInput label="AREA" value={f.area} max={24} placeholder="Dubai Marina" onChange={(v) => set('area', v)} />

        {/* privacy */}
        <div style={{ fontFamily: eMono, fontSize: 8, letterSpacing: '0.1em', color: eINKF, margin: '13px 0 7px' }}>VISIBILITY</div>
        <div style={{ display: 'flex', gap: 7 }}>
          {[{ id: 'approval', l: 'Approval required', s: 'Address hidden until you approve' }, { id: 'public', l: 'Open', s: 'Anyone can RSVP' }].map((o) => {
            const on = priv === o.id;
            return (
              <button key={o.id} onClick={() => setPriv(o.id)} style={{ flex: 1, padding: '9px 10px', borderRadius: 11, cursor: 'pointer', textAlign: 'left', background: on ? 'rgba(201,168,76,0.16)' : 'rgba(40,33,23,0.05)', border: on ? `1px solid ${eG}` : '1px solid rgba(40,33,23,0.12)' }}>
                <div style={{ fontFamily: eSans, fontWeight: 700, fontSize: 11, color: on ? eGD : eINK }}>{o.l}</div>
                <div style={{ fontFamily: eSans, fontWeight: 300, fontSize: 8.5, color: eINKS, marginTop: 2 }}>{o.s}</div>
              </button>
            );
          })}
        </div>

        {/* consent note */}
        <div style={{ display: 'flex', gap: 7, marginTop: 13, padding: '9px 11px', borderRadius: 11, background: 'rgba(19,138,62,0.08)', border: `1px solid ${eSP}40` }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={eSP} strokeWidth="1.9" style={{ flex: '0 0 auto', marginTop: 1 }}><path d="M12 21s-7-4.5-7-10a7 7 0 0 1 14 0c0 5.5-7 10-7 10z" /><path d="M9.5 11.5l2 2 3.5-4" strokeLinecap="round" strokeLinejoin="round" /></svg>
          <span style={{ fontFamily: eSans, fontWeight: 300, fontSize: 9.5, lineHeight: 1.45, color: eINKS }}>Hosts agree to Mangasm's safety & consent code. 18+ only, ID at door, no recording.</span>
        </div>

        <button disabled={!ready} onClick={() => ready && onPublish({ id: 'u' + Date.now(), type, title: f.title.trim(), desc: f.desc.trim(), when: f.when.trim(), place: f.place.trim() || 'TBA', area: f.area.trim() || 'Private', cap: Math.max(parseInt(f.cap || '8', 10) || 8, 1), going: 0, privacy: priv, host: 'You', rep: 42, img: '1506794778202-cad84cf45f1d' })}
          style={{ width: '100%', marginTop: 14, padding: '12px', borderRadius: 13, border: 'none', cursor: ready ? 'pointer' : 'default', fontFamily: eSerif, fontWeight: 700, fontSize: 15, letterSpacing: '0.06em', color: '#2a1d05', background: `linear-gradient(135deg, ${eGB}, ${eGD})`, opacity: ready ? 1 : 0.45, boxShadow: ready ? '0 6px 20px -4px rgba(201,168,76,0.8)' : 'none' }}>
          Publish Event
        </button>
      </div>
    </div>
  );
}

/* ----- host CTA / upsell ----- */
function HostCTA({ premium, setPremium, onHost }) {
  if (premium) {
    return (
      <button onClick={onHost} style={{ width: '100%', marginBottom: 16, padding: '13px', borderRadius: 15, border: `1px solid ${eG}66`, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, ...eGlass(true, 0.5), boxShadow: '0 0 20px -6px rgba(201,168,76,0.6)' }}>
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke={eGD} strokeWidth="2.2" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg>
        <span style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 15.5, letterSpacing: '0.05em', ...eGoldText }}>Host an Event</span>
      </button>
    );
  }
  return (
    <div style={{ position: 'relative', borderRadius: 18, padding: 1.3, background: eHolo, marginBottom: 16, boxShadow: '0 16px 40px -18px rgba(40,30,15,0.55)' }}>
      <div style={{ borderRadius: 17, overflow: 'hidden', ...eGlass(true, 0.5), padding: '15px 15px 16px', textAlign: 'center' }}>
        <span style={{ display: 'grid', placeItems: 'center', width: 42, height: 42, borderRadius: 13, margin: '0 auto', background: 'rgba(201,168,76,0.14)', border: `1px solid ${eG}55` }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={eGD} strokeWidth="1.9"><rect x="5" y="11" width="14" height="9" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></svg>
        </span>
        <div style={{ fontFamily: eSerif, fontWeight: 700, fontSize: 18, color: eINK, marginTop: 9 }}>Hosting is an M+ feature</div>
        <p style={{ fontFamily: eSans, fontWeight: 300, fontSize: 10.5, lineHeight: 1.5, color: eINKS, margin: '6px auto 0', maxWidth: 260 }}>Create glory hole, cum &amp; go, circle jerk or cosplay events with private RSVPs, capacity & approval controls.</p>
        <button onClick={() => setPremium(true)} style={{ marginTop: 13, padding: '11px 22px', borderRadius: 13, border: 'none', cursor: 'pointer', fontFamily: eSerif, fontWeight: 700, fontSize: 14.5, letterSpacing: '0.04em', color: '#2a1d05', background: `linear-gradient(135deg, ${eGB}, ${eGD})`, boxShadow: '0 6px 20px -4px rgba(201,168,76,0.8)' }}>
          Unlock M+ · $9.99/mo
        </button>
        <div style={{ fontFamily: eMono, fontSize: 7.5, color: eINKF, marginTop: 8 }}>Cancel anytime · also unlocks extended bio & fetishes</div>
      </div>
    </div>
  );
}

function EventsView({ premium, setPremium }) {
  const [hosting, setHosting] = React.useState(false);
  const [mine, setMine] = React.useState([]);
  const [filter, setFilter] = React.useState('all');
  const all = [...mine, ...SEED_EVENTS];
  const list = filter === 'all' ? all : all.filter((e) => e.type === filter);
  return (
    <React.Fragment>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
        <eUI.SectionLabel>EVENTS NEAR YOU</eUI.SectionLabel>
        <span style={{ fontFamily: eMono, fontSize: 8, color: eINKF }}>{all.length} live</span>
      </div>

      {hosting
        ? <HostForm onCancel={() => setHosting(false)} onPublish={(ev) => { setMine((m) => [ev, ...m]); setHosting(false); }} />
        : <HostCTA premium={premium} setPremium={setPremium} onHost={() => setHosting(true)} />}

      {/* type filters */}
      <div className="mg-scroll" style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 4, marginBottom: 12 }}>
        {[{ id: 'all', label: 'All' }, ...ETYPES].map((t) => {
          const on = filter === t.id;
          return (
            <button key={t.id} onClick={() => setFilter(t.id)} style={{ flex: '0 0 auto', display: 'inline-flex', alignItems: 'center', gap: 5, padding: '6px 11px', borderRadius: 10, cursor: 'pointer', fontFamily: eSans, fontWeight: 700, fontSize: 9.5, whiteSpace: 'nowrap', color: on ? '#2a1d05' : eINKS, background: on ? `linear-gradient(135deg, ${eGB}, ${eGD})` : 'rgba(40,33,23,0.06)', border: on ? 'none' : '1px solid rgba(40,33,23,0.14)' }}>
              {t.id !== 'all' && <TypeGlyph type={t.id} size={13} color={on ? '#2a1d05' : eINKS} sw={2} />}
              {t.label}
            </button>
          );
        })}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {list.map((ev) => <EventCard key={ev.id} ev={ev} />)}
        {list.length === 0 && <div style={{ textAlign: 'center', fontFamily: eMono, fontSize: 9, color: eINKF, padding: '24px 0' }}>No {typeLabel(filter)} events yet — be the first to host.</div>}
      </div>
    </React.Fragment>
  );
}

Object.assign(window.MangasmUI, { DiscoverTabs, CommunitiesView, EventsView });
