// mangasm-match.jsx — AI Match + Settings screens. Exports to window.MangasmUI.
const { GOLD: $G, GOLD_DEEP: $GD, GOLD_BRIGHT: $GB, SPOTIFY: $SP, serif: $serif, sans: $sans, mono: $mono, goldText: $goldText, goldGlow: $goldGlow, holo: $holo, glass: $glass } = window;
const $UI = window.MangasmUI;
const $IMG = (id, s = 240) => `https://images.unsplash.com/photo-${id}?w=${s}&h=${s}&q=80&auto=format&fit=crop&crop=faces`;
const MATCH_IMG = { m1: '1507003211169-0a1dd7228f2d', m2: '1500648767791-00dcc994a43e', m3: '1519085360753-af0119f7cbe7', m4: '1492562080023-ab3db95bfbce', m5: '1463453091185-61582044d556' };

const MATCHES = [
  { id: 'm1', name: 'Marco', age: 34, dist: '0.4 km', m: 94, astro: 'Cancer', chinese: 'Rat', life: 5, pos: 'Top', shared: ['House music', 'Sailing'], hobbies: ['Sailing', 'House music', 'Vinyl', 'Yachts'], bio: 'Yacht broker by day, vinyl DJ by night. I collect sunrises and rare pressings. Bring an appetite and an open mind.', notes: { astro: 'Water trine — deep & loyal', num: 'Seeker meets free spirit', chin: 'Dragon × Rat — a classic power pair' } },
  { id: 'm2', name: 'Theo', age: 31, dist: '1.2 km', m: 90, astro: 'Pisces', chinese: 'Monkey', life: 3, pos: 'Vers', shared: ['Mixology', 'Vintage cars'], hobbies: ['Mixology', 'Vintage cars', 'Travel'], bio: 'Mixologist with a vintage Porsche problem. Equal parts mischief and manners.', notes: { astro: 'Water harmony — intuitive', num: 'Creative spark, playful', chin: 'Dragon × Monkey — magnetic' } },
  { id: 'm3', name: 'Rafa', age: 36, dist: '2.0 km', m: 87, astro: 'Cancer', chinese: 'Monkey', life: 9, pos: 'Bottom', shared: ['Sailing', 'House music'], hobbies: ['Sailing', 'Architecture', 'House music'], bio: 'Architect, sailor, hopeless romantic. I build things that last — let us see if we do.', notes: { astro: 'Emotional depth', num: 'Old soul meets idealist', chin: 'Dragon × Monkey — magnetic' } },
  { id: 'm4', name: 'Sven', age: 33, dist: '3.1 km', m: 83, astro: 'Scorpio', chinese: 'Rat', life: 7, pos: 'Top', shared: ['Vintage cars'], hobbies: ['Vintage cars', 'Cigars', 'Golf'], bio: 'Old-money taste, new-school energy. Cars, cigars, and quiet luxury.', notes: { astro: 'Twin intensity — electric', num: 'Mirror life paths', chin: 'Dragon × Rat — power pair' } },
  { id: 'm5', name: 'Kai', age: 29, dist: '4.6 km', m: 79, astro: 'Virgo', chinese: 'Rooster', life: 4, pos: 'Vers', shared: ['Mixology'], hobbies: ['Mixology', 'Philosophy', 'Surf'], bio: 'Bartender-philosopher. I make a negroni that will change your evening.', notes: { astro: 'Earth grounds water', num: 'Builder energy', chin: 'Dragon × Rooster — bold duo' } },
];
const VENUES = [
  { id: 'v1', kind: 'Dinner', name: 'Ossiano · Atlantis', sub: 'Underwater fine dining · Sat 8:30 PM', icon: 'M6 3v7a3 3 0 0 0 6 0V3M9 3v18M18 3c-1.5 1-2 3-2 6s.5 4 2 5v7' },
  { id: 'v2', kind: 'Sunrise', name: 'Hot-Air Balloon · Al Ain', sub: 'Private flight for two · Sun 5:15 AM', icon: 'M12 2a7 7 0 0 1 7 7c0 4-3 6.5-5 8h-4c-2-1.5-5-4-5-8a7 7 0 0 1 7-7zM9.5 17h5l-.6 4h-3.8z' },
];

function Stat({ label, you, them, ok, note }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '7px 0', borderTop: '1px solid rgba(40,33,23,0.08)' }}>
      <span style={{ width: 17, height: 17, borderRadius: '50%', flex: '0 0 auto', display: 'grid', placeItems: 'center', background: ok ? `linear-gradient(135deg, ${$GB}, ${$GD})` : 'rgba(40,33,23,0.12)' }}>
        {ok && <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#2a1d05" strokeWidth="3.6" strokeLinecap="round"><path d="M5 13l4 4L19 6" /></svg>}
      </span>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
          <span style={{ fontFamily: $mono, fontSize: 7.5, letterSpacing: '0.12em', color: 'rgba(42,33,23,0.5)' }}>{label}</span>
          <span style={{ fontFamily: $sans, fontWeight: 700, fontSize: 10.5, color: '#2A2117', whiteSpace: 'nowrap' }}>{you} × {them}</span>
        </div>
        <div style={{ fontFamily: $sans, fontWeight: 300, fontSize: 9.5, color: 'rgba(42,33,23,0.66)' }}>{note}</div>
      </div>
    </div>
  );
}

function VenueCard({ v, match }) {
  const [state, setState] = React.useState('idle');
  return (
    <div style={{ borderRadius: 16, overflow: 'hidden', ...$glass(true, 0.46), border: `1px solid ${$G}33`, opacity: state === 'declined' ? 0.45 : 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '11px 12px' }}>
        <span style={{ width: 38, height: 38, borderRadius: 11, flex: '0 0 auto', display: 'grid', placeItems: 'center', background: 'rgba(232,199,126,0.12)', border: `1px solid ${$G}44` }}>
          <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d={v.icon} /></svg>
        </span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: $mono, fontSize: 7, letterSpacing: '0.16em', color: $G }}>{v.kind.toUpperCase()} · RSVP DATE</div>
          <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 15, color: '#2A2117', lineHeight: 1.1, marginTop: 1 }}>{v.name}</div>
          <div style={{ fontFamily: $sans, fontWeight: 300, fontSize: 9.5, color: 'rgba(42,33,23,0.66)' }}>{v.sub}</div>
        </div>
      </div>
      {state === 'requested' ? (
        <div style={{ padding: '9px 12px', background: 'rgba(29,185,84,0.12)', borderTop: `1px solid ${$SP}33`, display: 'flex', alignItems: 'center', gap: 7 }}>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke={$SP} strokeWidth="2.6" strokeLinecap="round"><path d="M5 13l4 4L19 6" /></svg>
          <span style={{ fontFamily: $sans, fontWeight: 600, fontSize: 10, color: '#2A2117' }}>Reservation requested · awaiting {match.name}</span>
        </div>
      ) : state === 'declined' ? (
        <div style={{ padding: '9px 12px', borderTop: '1px solid rgba(40,33,23,0.09)' }}><span style={{ fontFamily: $sans, fontSize: 10, color: 'rgba(42,33,23,0.6)' }}>Declined — we'll suggest another spot.</span></div>
      ) : (
        <div style={{ display: 'flex', gap: 7, padding: '0 12px 11px' }}>
          <button onClick={() => setState('requested')} style={{ flex: 1, padding: '8px', borderRadius: 10, border: 'none', cursor: 'pointer', fontFamily: $serif, fontWeight: 700, fontSize: 13, letterSpacing: '0.08em', color: '#2a1d05', background: `linear-gradient(135deg, ${$GB}, ${$GD})`, boxShadow: '0 4px 14px -4px rgba(232,199,126,0.7)' }}>RSVP</button>
          <button onClick={() => setState('idle')} style={{ padding: '8px 12px', borderRadius: 10, cursor: 'pointer', fontFamily: $sans, fontWeight: 600, fontSize: 10, color: '#2A2117', ...$glass(false, 0.3), border: '1px solid rgba(40,33,23,0.16)' }}>Message</button>
          <button onClick={() => setState('declined')} style={{ padding: '8px 11px', borderRadius: 10, cursor: 'pointer', fontFamily: $sans, fontWeight: 600, fontSize: 10, color: 'rgba(42,33,23,0.62)', background: 'transparent', border: '1px solid rgba(255,255,255,0.14)' }}>Decline</button>
        </div>
      )}
    </div>
  );
}

function AIMatchScreen({ data, onOpen }) {
  const [start, setStart] = React.useState(0);
  const featured = MATCHES[start % MATCHES.length];
  const trio = [0, 1, 2].map((k) => MATCHES[(start + 1 + k) % MATCHES.length]);
  const [ringOn, setRingOn] = React.useState(false);
  React.useEffect(() => { setRingOn(false); const id = setTimeout(() => setRingOn(true), 120); return () => clearTimeout(id); }, [start]);
  const R = 26, C = 2 * Math.PI * R, off = C * (1 - (ringOn ? featured.m : 0) / 100);
  return (
    <$UI.Scroll>
      {/* intro */}
      <div style={{ textAlign: 'center', marginBottom: 14 }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7 }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="1.8"><path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.3 1 2.5h6c0-1.2.3-1.8 1-2.5A6 6 0 0 0 12 3z" /></svg>
          <span style={{ fontFamily: $serif, fontWeight: 700, fontSize: 22, ...$goldText, textShadow: $goldGlow }}>AI MATCHMAKING</span>
        </div>
        <p style={{ fontFamily: $sans, fontWeight: 300, fontSize: 10.5, color: 'rgba(42,33,23,0.68)', margin: '7px auto 0', maxWidth: 280, lineHeight: 1.5 }}>Our engine blends your profile, who you browse, and esoteric compatibility to find the few who truly fit.</p>
        <div style={{ display: 'flex', gap: 5, flexWrap: 'wrap', justifyContent: 'center', marginTop: 10 }}>
          {['Your data', 'Browsing', 'Astrology', 'Numerology', 'Chinese zodiac'].map((s) => <$UI.Chip key={s} tone="gold">{s}</$UI.Chip>)}
        </div>
      </div>

      {/* featured match */}
      <div style={{ position: 'relative', borderRadius: 22, padding: 1.3, background: $holo, boxShadow: '0 22px 54px -18px rgba(0,0,0,0.72)' }}>
        <div onClick={() => onOpen(featured)} style={{ position: 'relative', borderRadius: 21, overflow: 'hidden', cursor: 'pointer', ...$glass(true, 0.52), padding: '14px 14px 15px' }}>
          <div style={{ fontFamily: $mono, fontSize: 7.5, letterSpacing: '0.18em', color: $G, marginBottom: 10 }}>TODAY'S TOP MATCH</div>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ width: 64, height: 64, borderRadius: '50%', overflow: 'hidden', flex: '0 0 auto', border: `2px solid ${$G}`, boxShadow: '0 0 14px rgba(232,199,126,0.5)' }}>
              <img src={$IMG(MATCH_IMG[featured.id], 160)} alt="" style={{ width: 64, height: 64, borderRadius: '50%', objectFit: 'cover', display: 'block' }} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 22, color: '#2A2117' }}>{featured.name} {featured.age}</div>
              <div style={{ fontFamily: $sans, fontWeight: 300, fontSize: 10, color: 'rgba(42,33,23,0.68)' }}>{featured.dist} away · {featured.pos}</div>
              <div style={{ display: 'flex', gap: 5, marginTop: 6, flexWrap: 'wrap' }}>{featured.shared.map((s) => <$UI.Chip key={s}>{s}</$UI.Chip>)}</div>
            </div>
            <div style={{ position: 'relative', width: 64, height: 64, display: 'grid', placeItems: 'center', flex: '0 0 auto' }}>
              <svg width="64" height="64" viewBox="0 0 64 64" style={{ transform: 'rotate(-90deg)' }}>
                <circle cx="32" cy="32" r={R} fill="none" stroke="rgba(40,33,23,0.16)" strokeWidth="4" />
                <circle cx="32" cy="32" r={R} fill="none" stroke={$G} strokeWidth="4" strokeLinecap="round" strokeDasharray={C} strokeDashoffset={off} style={{ filter: 'drop-shadow(0 0 4px rgba(232,199,126,0.8))', transition: 'stroke-dashoffset 1s cubic-bezier(.2,.8,.2,1)' }} />
              </svg>
              <div style={{ position: 'absolute', textAlign: 'center' }}>
                <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 20, lineHeight: 0.8, ...$goldText }}>{featured.m}</div>
                <div style={{ fontFamily: $mono, fontSize: 5.5, letterSpacing: '0.1em', color: 'rgba(42,33,23,0.55)' }}>MATCH</div>
              </div>
            </div>
          </div>
          {/* breakdown */}
          <div style={{ marginTop: 10 }}>
            <Stat label="ASTROLOGY" you={data.astro} them={featured.astro} ok note={featured.notes.astro} />
            <Stat label="LIFE PATH" you={data.life} them={featured.life} ok note={featured.notes.num} />
            <Stat label="CHINESE ZODIAC" you={data.chinese} them={featured.chinese} ok note={featured.notes.chin} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 5, marginTop: 11 }}>
            <span style={{ fontFamily: $mono, fontSize: 8, letterSpacing: '0.12em', color: $G }}>VIEW FULL PROFILE</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 6l6 6-6 6" /></svg>
          </div>
        </div>
      </div>

      {/* request 3 new */}
      <button onClick={() => setStart((s) => s + 1)} style={{ width: '100%', marginTop: 14, padding: '12px', borderRadius: 14, border: `1px solid ${$G}55`, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, ...$glass(true, 0.42), boxShadow: '0 0 18px -6px rgba(232,199,126,0.6)' }}>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="2" strokeLinecap="round"><path d="M21 12a9 9 0 1 1-3-6.7M21 4v4h-4" /></svg>
        <span style={{ fontFamily: $serif, fontWeight: 700, fontSize: 15, letterSpacing: '0.08em', ...$goldText }}>Request 3 new suggestions</span>
      </button>

      {/* trio */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 9, marginTop: 12 }}>
        {trio.map((u) => (
          <div key={u.id} onClick={() => onOpen(u)} style={{ borderRadius: 14, overflow: 'hidden', cursor: 'pointer', ...$glass(true, 0.5), border: '1px solid rgba(40,33,23,0.12)' }}>
            <div style={{ position: 'relative', width: '100%', height: 84 }}>
              <img src={$IMG(MATCH_IMG[u.id], 240)} alt="" style={{ width: '100%', height: 84, objectFit: 'cover', display: 'block' }} />
              <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, transparent 40%, rgba(20,16,12,0.85))' }} />
              <div style={{ position: 'absolute', left: 6, bottom: 5 }}>
                <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 13, color: '#fff', lineHeight: 1 }}>{u.name}</div>
                <div style={{ fontFamily: $mono, fontSize: 6.5, color: $G }}>{u.m}% · {u.pos}</div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* RSVP venues */}
      <div style={{ margin: '18px 0 8px' }}><$UI.SectionLabel>RSVP A FIRST DATE</$UI.SectionLabel></div>
      <p style={{ fontFamily: $sans, fontWeight: 300, fontSize: 10, color: 'rgba(42,33,23,0.66)', margin: '0 0 11px', lineHeight: 1.5 }}>We'll book the table for two. {featured.name} RSVPs to accept — or you message to pick another time & place.</p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {VENUES.map((v) => <VenueCard key={v.id} v={v} match={featured} />)}
      </div>
    </$UI.Scroll>
  );
}

/* ============ Settings ============ */
function Row({ label, sub, on, onClick, locked, mPlus }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 13px', borderTop: '1px solid rgba(40,33,23,0.08)' }}>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ fontFamily: $sans, fontWeight: 600, fontSize: 12.5, color: '#2A2117' }}>{label}</span>
          {locked && <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="rgba(42,33,23,0.5)" strokeWidth="2.4"><rect x="5" y="11" width="14" height="9" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></svg>}
          {mPlus && <span style={{ fontFamily: $mono, fontSize: 7, padding: '1px 5px', borderRadius: 6, background: `${$G}22`, border: `1px solid ${$G}55`, color: $G }}>M+</span>}
        </div>
        {sub && <div style={{ fontFamily: $sans, fontWeight: 300, fontSize: 9.5, color: 'rgba(42,33,23,0.6)', marginTop: 1 }}>{sub}</div>}
      </div>
      <$UI.Switch on={on} onClick={onClick} locked={locked || mPlus} />
    </div>
  );
}
const HIV_OPTIONS = ['Negative', 'Negative · on PrEP', 'Positive · Undetectable', 'Prefer not to say'];

function SettingsScreen({ data, setData, vis, setVis, premium, setPremium }) {
  const { Card, Field } = $UI;
  return (
    <$UI.Scroll>
      <$UI.SectionLabel>EDIT PROFILE</$UI.SectionLabel>
      <Card>
        <Field label="DISPLAY NAME" value={data.name} max={12} sanitize={(v) => v.replace(/[^A-Za-z ]/g, '')} hint="8–12 characters · letters only, no symbols" onChange={(v) => setData('name', v)} />
        <div style={{ borderTop: '1px solid rgba(40,33,23,0.08)' }} />
        <Field label="HEADLINE" value={data.headline} max={30} hint="A mantra, mood or what you're into" onChange={(v) => setData('headline', v)} />
        <div style={{ borderTop: '1px solid rgba(40,33,23,0.08)' }} />
        <Field label={`BIO ${premium ? '· M+ extended' : ''}`} value={data.bio} max={premium ? 600 : 300} hint={premium ? 'Premium: up to 600 characters + emoji' : 'Up to 300 characters incl. emoji'} onChange={(v) => setData('bio', v)} />
      </Card>

      <div style={{ height: 16 }} />
      <$UI.SectionLabel>SHOW ON PROFILE</$UI.SectionLabel>
      <Card>
        <Row label="Username" sub="Always visible" on locked />
        <Row label="Reputation" sub="Always visible" on locked />
        <Row label="Headline" on={vis.headline} onClick={() => setVis('headline')} />
        <Row label="Hobbies" on={vis.hobbies} onClick={() => setVis('hobbies')} />
        <Row label="Position" sub="Top / Vers / Bottom" on={vis.position} onClick={() => setVis('position')} />
        <Row label="Fetishes" sub={premium ? 'Feet, roleplay & more' : 'Unlock with Premium'} on={premium && vis.into} mPlus={!premium} onClick={() => setVis('into')} />
        <Row label="HIV status" on={vis.hiv} onClick={() => setVis('hiv')} />
        <Row label="Spotify anthem" on={vis.anthem} onClick={() => setVis('anthem')} />
        <Row label="Photos" on={vis.photos} onClick={() => setVis('photos')} />
      </Card>

      <div style={{ height: 16 }} />
      <$UI.SectionLabel>SOCIAL LINKS</$UI.SectionLabel>
      <Card>
        <Row label="Show social links" on={vis.socials} onClick={() => setVis('socials')} />
        <Field label="INSTAGRAM" value={data.instagram} max={30} sanitize={(v) => v.replace(/[^A-Za-z0-9_.]/g, '')} onChange={(v) => setData('instagram', v)} />
        <Row label="Show Instagram" on={vis.instagram} onClick={() => setVis('instagram')} />
        <Field label="X (TWITTER)" value={data.x} max={15} sanitize={(v) => v.replace(/[^A-Za-z0-9_]/g, '')} onChange={(v) => setData('x', v)} />
        <Row label="Show X" on={vis.x} onClick={() => setVis('x')} />
      </Card>

      <div style={{ height: 16 }} />
      <$UI.SectionLabel>HEALTH</$UI.SectionLabel>
      <Card>
        <div style={{ padding: '11px 13px' }}>
          <div style={{ fontFamily: $mono, fontSize: 8.5, letterSpacing: '0.1em', color: 'rgba(42,33,23,0.5)', marginBottom: 8 }}>HIV STATUS</div>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {HIV_OPTIONS.map((o) => {
              const on = data.hiv === o;
              return <button key={o} onClick={() => setData('hiv', o)} style={{ fontFamily: $sans, fontWeight: 600, fontSize: 10, padding: '6px 10px', borderRadius: 9, cursor: 'pointer', color: on ? '#2a1d05' : '#2A2117', background: on ? `linear-gradient(135deg, ${$GB}, ${$GD})` : 'rgba(40,33,23,0.06)', border: on ? 'none' : '1px solid rgba(40,33,23,0.14)' }}>{o}</button>;
            })}
          </div>
        </div>
        <Field label="LAST TESTED" value={data.lastTested} max={16} hint="When did you last get checked?" onChange={(v) => setData('lastTested', v)} />
      </Card>

      <div style={{ height: 16 }} />
      <$UI.SectionLabel>MEMBERSHIP</$UI.SectionLabel>
      <div style={{ position: 'relative', borderRadius: 18, padding: 1.3, background: $holo }}>
        <div style={{ borderRadius: 17, overflow: 'hidden', ...$glass(true, 0.5) }}>
          <Row label="Mangasm M+" sub="Extended bio, fetishes, more profile freedom & ways to stand out" on={premium} onClick={() => setPremium(!premium)} />
        </div>
      </div>
      <div style={{ height: 8 }} />
    </$UI.Scroll>
  );
}

/* ============ expanded match profile ============ */
function MatchDetailScreen({ candidate: c, data, onBack, onMessage }) {
  const [ringOn, setRingOn] = React.useState(false);
  React.useEffect(() => { const id = setTimeout(() => setRingOn(true), 150); return () => clearTimeout(id); }, []);
  const R = 30, C = 2 * Math.PI * R, off = C * (1 - (ringOn ? c.m : 0) / 100);
  return (
    <$UI.Scroll>
      <button onClick={onBack} style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 13px 7px 9px', borderRadius: 12, cursor: 'pointer', marginBottom: 12, ...$glass(true, 0.42), border: `1px solid ${$G}33` }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 6l-6 6 6 6" /></svg>
        <span style={{ fontFamily: $serif, fontWeight: 700, fontSize: 14, letterSpacing: '0.06em', color: $G }}>Matches</span>
      </button>

      {/* hero */}
      <div style={{ position: 'relative', borderRadius: 24, padding: 1.4, background: $holo, boxShadow: '0 24px 60px -18px rgba(0,0,0,0.72)' }}>
        <div style={{ position: 'relative', borderRadius: 23, overflow: 'hidden' }}>
          <div style={{ position: 'relative', width: '100%', height: 300 }}>
            <img src={$IMG(MATCH_IMG[c.id], 600)} alt="" style={{ width: '100%', height: 300, objectFit: 'cover', display: 'block' }} />
            <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(20,16,12,0.12) 0%, transparent 32%, transparent 48%, rgba(20,16,12,0.9))' }} />
            <div style={{ position: 'absolute', top: 12, right: 12, padding: '5px 11px', borderRadius: 12, ...$glass(true, 0.5), border: `1px solid ${$G}66` }}>
              <span style={{ fontFamily: $serif, fontWeight: 700, fontSize: 16, ...$goldText }}>{c.m}%</span>
              <span style={{ fontFamily: $mono, fontSize: 7, letterSpacing: '0.12em', color: 'rgba(42,33,23,0.55)', marginLeft: 4 }}>MATCH</span>
            </div>
            <div style={{ position: 'absolute', left: 15, right: 15, bottom: 13 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontFamily: $serif, fontWeight: 700, fontSize: 30, color: '#fff', textShadow: '0 2px 8px rgba(0,0,0,0.6)' }}>{c.name} {c.age}</span>
                <span style={{ width: 9, height: 9, borderRadius: '50%', background: $SP, boxShadow: `0 0 8px ${$SP}` }} />
              </div>
              <div style={{ display: 'flex', gap: 7, marginTop: 5 }}>
                <$UI.Chip tone="gold">{c.pos}</$UI.Chip>
                <$UI.Chip>{c.dist} away</$UI.Chip>
                <$UI.Chip>{c.astro}</$UI.Chip>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* compatibility */}
      <div style={{ marginTop: 14, position: 'relative', borderRadius: 20, padding: 1.2, background: $holo }}>
        <div style={{ borderRadius: 19, overflow: 'hidden', ...$glass(true, 0.5), padding: '13px 14px 14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ position: 'relative', width: 72, height: 72, display: 'grid', placeItems: 'center', flex: '0 0 auto' }}>
              <svg width="72" height="72" viewBox="0 0 72 72" style={{ transform: 'rotate(-90deg)' }}>
                <circle cx="36" cy="36" r={R} fill="none" stroke="rgba(40,33,23,0.16)" strokeWidth="4" />
                <circle cx="36" cy="36" r={R} fill="none" stroke={$G} strokeWidth="4.5" strokeLinecap="round" strokeDasharray={C} strokeDashoffset={off} style={{ filter: 'drop-shadow(0 0 5px rgba(232,199,126,0.8))', transition: 'stroke-dashoffset 1.1s cubic-bezier(.2,.8,.2,1)' }} />
              </svg>
              <div style={{ position: 'absolute', textAlign: 'center' }}>
                <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 22, lineHeight: 0.8, ...$goldText }}>{c.m}</div>
                <div style={{ fontFamily: $mono, fontSize: 6, letterSpacing: '0.1em', color: 'rgba(42,33,23,0.55)' }}>COMPAT</div>
              </div>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: $serif, fontWeight: 700, fontSize: 17, ...$goldText, textShadow: $goldGlow }}>Cosmically aligned</div>
              <p style={{ fontFamily: $sans, fontWeight: 300, fontSize: 10, color: 'rgba(42,33,23,0.68)', margin: '3px 0 0', lineHeight: 1.45 }}>Esoteric & behavioral signals point the same way — rare.</p>
            </div>
          </div>
          <div style={{ marginTop: 8 }}>
            <Stat label="ASTROLOGY" you={data.astro} them={c.astro} ok note={c.notes.astro} />
            <Stat label="LIFE PATH" you={data.life} them={c.life} ok note={c.notes.num} />
            <Stat label="CHINESE ZODIAC" you={data.chinese} them={c.chinese} ok note={c.notes.chin} />
            <Stat label="SHARED" you={data.position} them={c.pos} ok note={`Also into ${c.shared.join(', ')}`} />
          </div>
        </div>
      </div>

      {/* about */}
      <div style={{ marginTop: 14, borderRadius: 18, overflow: 'hidden', ...$glass(true, 0.5), border: '1px solid rgba(40,33,23,0.12)', padding: '13px 14px' }}>
        <div style={{ fontFamily: $mono, fontSize: 7.5, letterSpacing: '0.16em', color: $G, marginBottom: 7 }}>ABOUT {c.name.toUpperCase()}</div>
        <p style={{ fontFamily: $sans, fontWeight: 300, fontSize: 11.5, lineHeight: 1.55, color: 'rgba(42,33,23,0.8)', margin: 0, textWrap: 'pretty' }}>{c.bio}</p>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginTop: 11 }}>{c.hobbies.map((h) => <$UI.Chip key={h}>{h}</$UI.Chip>)}</div>
      </div>

      {/* actions */}
      <div style={{ display: 'flex', gap: 9, marginTop: 14 }}>
        <button onClick={onMessage} style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, padding: '13px', borderRadius: 14, border: 'none', cursor: 'pointer', fontFamily: $serif, fontWeight: 700, fontSize: 16, letterSpacing: '0.06em', color: '#2a1d05', background: `linear-gradient(135deg, ${$GB}, ${$GD})`, boxShadow: '0 6px 20px -4px rgba(232,199,126,0.8)' }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#2a1d05" strokeWidth="2"><path d="M21 11.5a8.5 8.5 0 0 1-12.3 7.6L3 21l1.9-5.7A8.5 8.5 0 1 1 21 11.5z" /></svg>
          Message
        </button>
        <button style={{ width: 52, borderRadius: 14, cursor: 'pointer', display: 'grid', placeItems: 'center', ...$glass(true, 0.42), border: `1px solid ${$G}44` }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={$G} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M7 11v9H4v-9zM7 11l4-7a2 2 0 0 1 2.8 1.8V8h5a2 2 0 0 1 2 2.4l-1.3 7A2 2 0 0 1 17.5 19H7" /></svg>
        </button>
        <button style={{ width: 52, borderRadius: 14, cursor: 'pointer', display: 'grid', placeItems: 'center', background: 'transparent', border: '1px solid rgba(40,33,23,0.16)' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="rgba(42,33,23,0.55)" strokeWidth="2.2" strokeLinecap="round"><path d="M6 6l12 12M18 6 6 18" /></svg>
        </button>
      </div>
    </$UI.Scroll>
  );
}

Object.assign(window.MangasmUI, { AIMatchScreen, SettingsScreen, MatchDetailScreen });
