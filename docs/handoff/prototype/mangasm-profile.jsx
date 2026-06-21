// mangasm-profile.jsx — Profile + Discover screens. Exports to window.MangasmUI.
const { GOLD: _GOLD, GOLD_DEEP: _GD, GOLD_BRIGHT: _GB, SPOTIFY: _SP, serif: _serif, sans: _sans, mono: _mono, goldText: _goldText, goldGlow: _goldGlow, holo: _holo, glass: _glass, Refraction: _Refraction, Seal: _Seal } = window;
const _UI = window.MangasmUI;
const PORTRAIT = (id, s = 200) => `https://images.unsplash.com/photo-${id}?w=${s}&h=${s}&q=80&auto=format&fit=crop&crop=faces`;
const _AVATAR = PORTRAIT('1506794778202-cad84cf45f1d', 220);
const _PHOTOS = ['1500648767791-00dcc994a43e', '1519085360753-af0119f7cbe7', '1492562080023-ab3db95bfbce'];
const _NEARBY_IMG = {
  d1: '1507003211169-0a1dd7228f2d', d2: '1500648767791-00dcc994a43e', d3: '1519085360753-af0119f7cbe7',
  d4: '1492562080023-ab3db95bfbce', d5: '1463453091185-61582044d556', d6: '1488161628813-04466f872be2',
};

function ProfileScreen({ data, vis, premium }) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => { const id = setTimeout(() => setMounted(true), 60); return () => clearTimeout(id); }, []);
  const { RepRing, Anthem, Social, Card } = _UI;
  const bioMax = premium ? 600 : 300;
  return (
    <_UI.Scroll>
      {/* vouches + AI match strip */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 10, opacity: mounted ? 1 : 0, transition: 'opacity .8s' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '6px 11px', borderRadius: 12, ..._glass(true, 0.5), border: '0.7px solid rgba(255,255,255,0.7)' }}>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke={_GD} strokeWidth="2"><path d="M12 17.3 6.2 21l1.5-6.5L3 10.2l6.6-.6L12 3.5l2.4 6.1 6.6.6-4.7 4.3L17.8 21z" strokeLinejoin="round" /></svg>
          <span style={{ fontFamily: _sans, fontWeight: 700, fontSize: 11, color: window.INK }}>1,204</span>
          <span style={{ fontFamily: _mono, fontSize: 7.5, letterSpacing: '0.1em', color: window.INK_FAINT }}>VOUCHES</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '6px 12px', borderRadius: 12, ..._glass(true, 0.5), border: `1px solid ${_GOLD}66`, boxShadow: '0 6px 16px -8px rgba(201,168,76,0.6)' }}>
          <span style={{ fontFamily: _serif, fontWeight: 700, fontSize: 21, lineHeight: 0.85, ..._goldText, textShadow: _goldGlow }}>98</span>
          <span style={{ fontFamily: _mono, fontSize: 6.5, letterSpacing: '0.12em', color: window.INK_SOFT, lineHeight: 1.2 }}>AI<br />MATCH</span>
        </div>
      </div>

      {/* headline */}
      {vis.headline && data.headline && (
        <div style={{ textAlign: 'center', margin: '16px 0 -2px', opacity: mounted ? 1 : 0, transition: 'opacity .9s .1s' }}>
          <span style={{ fontFamily: _serif, fontStyle: 'italic', fontWeight: 600, fontSize: 19, ..._goldText, textShadow: _goldGlow }}>“{data.headline}”</span>
        </div>
      )}

      {/* profile card */}
      <div style={{ marginTop: 14, opacity: mounted ? 1 : 0, transform: mounted ? 'none' : 'translateY(16px)', transition: 'all .9s .15s cubic-bezier(.2,.8,.2,1)' }}>
        <div style={{ position: 'relative', borderRadius: 26, padding: 1, background: _holo, boxShadow: '0 26px 64px -22px rgba(40,30,15,0.55)' }}>
          <div style={{ position: 'relative', borderRadius: 25, padding: '15px 15px 16px', overflow: 'hidden', ..._glass(true, 0.5) }}>
            <_Refraction radius={25} />
            {/* avatar + name */}
            <div style={{ position: 'relative', display: 'flex', gap: 13, alignItems: 'center' }}>
              <div style={{ position: 'relative', width: 72, height: 72, flex: '0 0 auto' }}>
                <div style={{ position: 'absolute', inset: -3, borderRadius: '50%', background: `linear-gradient(135deg, ${_GB}, ${_GD})`, WebkitMask: 'radial-gradient(circle, transparent 31px, #000 32px)', mask: 'radial-gradient(circle, transparent 31px, #000 32px)', boxShadow: '0 0 14px rgba(201,168,76,0.45)' }} />
                <img src={_AVATAR} alt="" style={{ width: 72, height: 72, borderRadius: '50%', objectFit: 'cover', display: 'block' }} />
                <div style={{ position: 'absolute', bottom: 2, right: 2, width: 15, height: 15, borderRadius: '50%', background: _SP, border: '2px solid rgba(255,253,249,0.9)', boxShadow: `0 0 8px ${_SP}` }} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ whiteSpace: 'nowrap' }}>
                  <span style={{ fontFamily: _serif, fontWeight: 700, fontSize: 27, color: window.INK, letterSpacing: '0.01em', verticalAlign: 'middle' }}>{data.name} {data.age}</span>
                  <span style={{ marginLeft: 7, verticalAlign: 'middle' }}><_Seal size={17} /></span>
                </div>
                <div style={{ fontFamily: _sans, fontWeight: 400, fontSize: 10.5, color: window.INK_SOFT, marginTop: 2 }}>{data.location}</div>
                <div style={{ display: 'flex', gap: 6, marginTop: 8, flexWrap: 'wrap' }}>
                  {vis.position && <_UI.Chip tone="gold">{data.position}</_UI.Chip>}
                  <_UI.Chip tone="gold">Elite</_UI.Chip>
                  <_UI.Chip>4.2k MGC</_UI.Chip>
                </div>
              </div>
            </div>

            {/* bio */}
            <p style={{ position: 'relative', fontFamily: _sans, fontWeight: 400, fontSize: 11.5, lineHeight: 1.55, color: window.INK_SOFT, margin: '13px 0 0', textWrap: 'pretty' }}>{data.bio}</p>
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 3 }}>
              <span style={{ fontFamily: _mono, fontSize: 7, color: premium ? _GD : window.INK_FAINT }}>{data.bio.length}/{bioMax}{premium ? ' · M+' : ''}</span>
            </div>

            {/* hobbies */}
            {vis.hobbies && (
              <div style={{ position: 'relative', marginTop: 11 }}>
                <div style={{ fontFamily: _mono, fontSize: 7.5, letterSpacing: '0.14em', color: window.INK_FAINT, marginBottom: 7 }}>HOBBIES</div>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{data.hobbies.map((h) => <_UI.Chip key={h}>{h}</_UI.Chip>)}</div>
              </div>
            )}
            {/* into / fetishes (premium) */}
            {vis.into && premium && (
              <div style={{ position: 'relative', marginTop: 11 }}>
                <div style={{ fontFamily: _mono, fontSize: 7.5, letterSpacing: '0.14em', color: window.INK_FAINT, marginBottom: 7 }}>INTO</div>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>{data.into.map((h) => <_UI.Chip key={h} tone="gold">{h}</_UI.Chip>)}</div>
              </div>
            )}

            {/* HIV status */}
            {vis.hiv && (
              <div style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 9, marginTop: 12, padding: '9px 11px', borderRadius: 12, background: 'rgba(19,138,62,0.10)', border: `1px solid ${_SP}55` }}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={_SP} strokeWidth="1.9"><path d="M12 21s-7-4.5-7-10a7 7 0 0 1 14 0c0 5.5-7 10-7 10z" /><path d="M9.5 11.5l2 2 3.5-4" strokeLinecap="round" strokeLinejoin="round" /></svg>
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: _sans, fontWeight: 700, fontSize: 11, color: window.INK }}>HIV {data.hiv}</div>
                  <div style={{ fontFamily: _mono, fontSize: 7.5, color: window.INK_FAINT }}>Last tested · {data.lastTested}</div>
                </div>
              </div>
            )}

            {/* socials */}
            {vis.socials && (vis.instagram || vis.x) && (
              <div style={{ position: 'relative', display: 'flex', gap: 8, marginTop: 11 }}>
                {vis.instagram && <Social kind="ig" handle={data.instagram} />}
                {vis.x && <Social kind="x" handle={data.x} />}
              </div>
            )}

            {/* anthem */}
            {vis.anthem && <Anthem />}

            {/* encryption */}
            <div style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 7, marginTop: 12 }}>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={_GD} strokeWidth="2"><path d="M6 10V8a6 6 0 0 1 12 0v2" /><rect x="4" y="10" width="16" height="11" rx="2.5" /></svg>
              <span style={{ fontFamily: _mono, fontSize: 8, color: window.INK_SOFT }}>End-to-End Encrypted</span>
              <span style={{ width: 3, height: 3, borderRadius: '50%', background: window.INK_FAINT }} />
              <span style={{ fontFamily: _mono, fontSize: 8, color: _GD }}>Privacy Zones Active</span>
            </div>

            {/* photos */}
            {vis.photos && (
              <React.Fragment>
                <div style={{ position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
                  <span style={{ fontFamily: _serif, fontWeight: 700, fontSize: 15, letterSpacing: '0.18em', color: window.INK }}>PHOTOS</span>
                  <span style={{ fontFamily: _mono, fontSize: 7.5, color: window.INK_FAINT }}>reputation-gated</span>
                </div>
                <div style={{ position: 'relative', display: 'flex', gap: 12, marginTop: 9 }}>
                  {_PHOTOS.map((pid) => (
                    <div key={pid} style={{ position: 'relative', width: 58, height: 58 }}>
                      <div style={{ position: 'absolute', inset: -2, borderRadius: '50%', background: `linear-gradient(135deg, ${_GOLD}, ${_GD})`, WebkitMask: 'radial-gradient(circle, transparent 24px, #000 25px)', mask: 'radial-gradient(circle, transparent 24px, #000 25px)' }} />
                      <img src={PORTRAIT(pid, 140)} alt="" style={{ width: 58, height: 58, borderRadius: '50%', objectFit: 'cover', display: 'block' }} />
                    </div>
                  ))}
                  <div style={{ width: 58, height: 58, borderRadius: '50%', display: 'grid', placeItems: 'center', border: '1px dashed rgba(201,168,76,0.5)', background: 'rgba(201,168,76,0.08)' }}>
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke={_GD} strokeWidth="1.5"><circle cx="12" cy="12" r="9" /><path d="M12 8v8M8 12h8" strokeLinecap="round" /></svg>
                  </div>
                </div>
              </React.Fragment>
            )}
          </div>
        </div>
      </div>
    </_UI.Scroll>
  );
}

const NEARBY = [
  { id: 'd1', name: 'Marco', dist: '0.4 km', m: 94, pos: 'Top' }, { id: 'd2', name: 'Theo', dist: '1.2 km', m: 88, pos: 'Vers' },
  { id: 'd3', name: 'Rafa', dist: '2.0 km', m: 81, pos: 'Bottom' }, { id: 'd4', name: 'Sven', dist: '3.1 km', m: 77, pos: 'Top' },
  { id: 'd5', name: 'Kai', dist: '4.6 km', m: 72, pos: 'Vers' }, { id: 'd6', name: 'Andre', dist: '5.0 km', m: 69, pos: 'Bottom' },
];
function DiscoverScreen({ likes, premium, setPremium }) {
  const [tab, setTab] = React.useState('nearby');
  const list = likes ? NEARBY.slice(0, 4) : NEARBY;
  // pin coordinates on the faux map (percent)
  const PINS = [
    { id: 'd1', x: 30, y: 34 }, { id: 'd2', x: 62, y: 26 }, { id: 'd3', x: 48, y: 58 },
    { id: 'd4', x: 78, y: 62 }, { id: 'd5', x: 18, y: 70 },
  ];

  // Communities / Events tabs (Discover only, not the Likes surface)
  if (!likes && tab === 'communities') {
    return <_UI.Scroll><_UI.DiscoverTabs tab={tab} setTab={setTab} /><_UI.CommunitiesView /></_UI.Scroll>;
  }
  if (!likes && tab === 'events') {
    return <_UI.Scroll><_UI.DiscoverTabs tab={tab} setTab={setTab} /><_UI.EventsView premium={premium} setPremium={setPremium} /></_UI.Scroll>;
  }

  return (
    <_UI.Scroll>
      {!likes && <_UI.DiscoverTabs tab={tab} setTab={setTab} />}
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
        <_UI.SectionLabel>{likes ? 'LIKED YOU' : 'NEARBY'}</_UI.SectionLabel>
        <span style={{ fontFamily: _mono, fontSize: 8, color: window.INK_FAINT }}>{likes ? '4 admirers' : '2,847 online'}</span>
      </div>

      {!likes && (
        <div style={{ position: 'relative', height: 200, borderRadius: 20, overflow: 'hidden', marginBottom: 14, padding: 1, background: _holo, boxShadow: '0 18px 44px -20px rgba(40,30,15,0.5)' }}>
          <div style={{ position: 'absolute', inset: 1, borderRadius: 19, overflow: 'hidden', background: 'linear-gradient(150deg, #eef2f4, #e6ece6 50%, #f1ece2)' }}>
            {/* faux map streets */}
            <svg viewBox="0 0 320 200" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.5 }}>
              <g stroke="#c8cfd2" strokeWidth="7" fill="none" strokeLinecap="round">
                <path d="M-10 60 L120 50 L200 90 L340 70" /><path d="M40 -10 L70 90 L50 220" /><path d="M150 -10 L170 100 L240 220" /><path d="M-10 140 L130 150 L260 130 L340 150" /><path d="M250 -10 L270 80 L260 220" />
              </g>
              <g stroke="#d6dbd2" strokeWidth="2.5" fill="none">
                <path d="M0 30 L320 20" /><path d="M0 110 L320 100" /><path d="M100 0 L120 200" /><path d="M210 0 L225 200" />
              </g>
            </svg>
            <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(120% 90% at 50% 0%, rgba(201,168,76,0.12), transparent 55%)' }} />
            {/* pins */}
            {PINS.map((p) => {
              const u = NEARBY.find((n) => n.id === p.id); const hot = u.m >= 85;
              return (
                <div key={p.id} style={{ position: 'absolute', left: `${p.x}%`, top: `${p.y}%`, transform: 'translate(-50%,-50%)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '3px 8px 3px 3px', borderRadius: 999, ..._glass(true, 0.7), border: hot ? `1.5px solid ${_GOLD}` : '0.7px solid rgba(255,255,255,0.8)', boxShadow: hot ? `0 4px 14px -4px rgba(201,168,76,0.7), 0 0 0 3px rgba(201,168,76,0.15)` : '0 4px 12px -4px rgba(40,30,15,0.35)' }}>
                    <div style={{ position: 'relative', width: 26, height: 26, flex: '0 0 auto' }}>
                      <div style={{ position: 'absolute', inset: -2, borderRadius: '50%', background: hot ? `linear-gradient(135deg, ${_GB}, ${_GD})` : 'transparent', WebkitMask: 'radial-gradient(circle, transparent 11px, #000 12px)', mask: 'radial-gradient(circle, transparent 11px, #000 12px)' }} />
                      <img src={PORTRAIT(_NEARBY_IMG[u.id], 80)} alt="" style={{ width: 26, height: 26, borderRadius: '50%', objectFit: 'cover', display: 'block' }} />
                    </div>
                    <span style={{ fontFamily: _mono, fontSize: 8, fontWeight: 700, color: hot ? _GD : window.INK_SOFT }}>{u.m}%</span>
                  </div>
                  <div style={{ width: 2, height: 8, margin: '0 auto', background: hot ? _GOLD : 'rgba(255,255,255,0.85)' }} />
                </div>
              );
            })}
            <div style={{ position: 'absolute', left: 10, bottom: 9, display: 'flex', alignItems: 'center', gap: 5, padding: '4px 9px', borderRadius: 10, ..._glass(true, 0.7), border: '0.7px solid rgba(255,255,255,0.8)' }}>
              <span style={{ width: 6, height: 6, borderRadius: '50%', background: _SP, boxShadow: `0 0 6px ${_SP}` }} />
              <span style={{ fontFamily: _mono, fontSize: 7.5, color: window.INK_SOFT }}>Privacy zone · Dubai Marina</span>
            </div>
          </div>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {list.map((u) => (
          <div key={u.id} style={{ position: 'relative', borderRadius: 18, padding: 1, background: _holo, boxShadow: '0 14px 34px -18px rgba(40,30,15,0.5)' }}>
            <div style={{ borderRadius: 17, overflow: 'hidden', ..._glass(true, 0.5) }}>
              <div style={{ position: 'relative', width: '100%', height: 150 }}>
                <img src={PORTRAIT(_NEARBY_IMG[u.id], 320)} alt="" style={{ width: '100%', height: 150, objectFit: 'cover', display: 'block' }} />
                <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, transparent 42%, rgba(20,16,12,0.82))' }} />
                <div style={{ position: 'absolute', top: 7, right: 7, padding: '3px 7px', borderRadius: 8, ..._glass(true, 0.7), border: u.m >= 85 ? `1px solid ${_GOLD}` : '0.7px solid rgba(255,255,255,0.7)' }}>
                  <span style={{ fontFamily: _serif, fontWeight: 700, fontSize: 12, ..._goldText }}>{u.m}%</span>
                </div>
                <div style={{ position: 'absolute', left: 9, bottom: 8, right: 9 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                    <span style={{ fontFamily: _serif, fontWeight: 700, fontSize: 17, color: '#fff', textShadow: '0 1px 4px rgba(0,0,0,0.6)' }}>{u.name}</span>
                    <span style={{ width: 7, height: 7, borderRadius: '50%', background: _SP, boxShadow: `0 0 6px ${_SP}` }} />
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 2 }}>
                    <span style={{ fontFamily: _mono, fontSize: 7.5, color: 'rgba(255,255,255,0.78)' }}>{u.dist}</span>
                    <span style={{ fontFamily: _mono, fontSize: 7.5, color: _GB }}>{u.pos}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </_UI.Scroll>
  );
}

Object.assign(window.MangasmUI, { ProfileScreen, DiscoverScreen });
