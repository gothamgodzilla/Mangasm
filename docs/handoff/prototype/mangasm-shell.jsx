// mangasm-shell.jsx — TabBar + MangasmApp (state, nav, tweaks). Exports MangasmApp.
const { GOLD: SG, GOLD_DEEP: SGD, GOLD_BRIGHT: SGB, INK: SINK, INK_SOFT: SINKS, serif: sSerif, sans: sSans, glass: sGlass } = window;
const Background = window.Background;
const Equalizer = window.Equalizer;

const PROFILE_DEFAULT = {
  name: 'Julian', age: 32, location: 'Dubai → London',
  headline: 'Slow mornings, fast cars',
  bio: 'Jet-set architect of good nights. Sunsets, fast cars & slow mornings. Find me where the signal shouldn’t reach. 🛥️🥂',
  hobbies: ['Sailing', 'Mixology', 'Vintage cars', 'House music'],
  position: 'Vers', into: ['Feet', 'Roleplay'],
  hiv: 'Negative · on PrEP', lastTested: 'May 2026',
  instagram: 'julianv', x: 'julian_v',
  astro: 'Scorpio', chinese: 'Dragon', life: 7,
};
const VIS_DEFAULT = { headline: true, hobbies: true, position: true, into: false, hiv: true, anthem: true, photos: true, socials: true, instagram: true, x: true };

const NAV = [
  { id: 'discover', label: 'Discover', d: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z' },
  { id: 'search', label: 'Search', d: 'M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14ZM20 20l-3.5-3.5' },
  { id: 'aimatch', label: 'AI Match', lamp: true, d: 'M9 18h6M10 21h4M12 3a6 6 0 0 0-4 10.5c.7.7 1 1.3 1 2.5h6c0-1.2.3-1.8 1-2.5A6 6 0 0 0 12 3z' },
  { id: 'likes', label: 'Likes', d: 'M12 20s-7-4.6-9.2-9.1C1.2 7.6 3 4.5 6.2 4.5c2 0 3.2 1.2 3.8 2.2.6-1 1.8-2.2 3.8-2.2 3.2 0 5 3.1 3.4 6.4C19 15.4 12 20 12 20Z' },
  { id: 'profile', label: 'Profile', d: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM4.5 20a7.5 7.5 0 0 1 15 0' },
];

function TabBar({ screen, setScreen }) {
  return (
    <div style={{ position: 'absolute', left: 14, right: 14, bottom: 14, zIndex: 50, display: 'flex', justifyContent: 'space-around', alignItems: 'center', padding: '9px 8px', borderRadius: 24, ...sGlass(true, 0.62), boxShadow: '0 14px 40px -12px rgba(40,30,15,0.4), inset 0 1px 0 rgba(255,255,255,0.75)' }}>
      {NAV.map((t) => {
        const on = screen === t.id || (t.id === 'discover' && screen === 'settings' ? false : false);
        if (t.lamp) return (
          <button key={t.id} onClick={() => setScreen(t.id)} style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', display: 'grid', placeItems: 'center' }}>
            <div style={{ width: 44, height: 44, borderRadius: 15, display: 'grid', placeItems: 'center', background: `linear-gradient(135deg, ${SGB}, ${SGD})`, boxShadow: screen === t.id ? `0 0 20px -2px ${SG}, 0 6px 18px -4px rgba(201,168,76,0.7), inset 0 1px 0 rgba(255,255,255,0.6)` : '0 6px 18px -4px rgba(201,168,76,0.5), inset 0 1px 0 rgba(255,255,255,0.6)' }}>
              <svg width="23" height="23" viewBox="0 0 24 24" fill="none" stroke="#3a2c08" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d={t.d} /></svg>
            </div>
          </button>
        );
        const active = screen === t.id;
        return (
          <button key={t.id} onClick={() => setScreen(t.id)} style={{ background: 'none', border: 'none', padding: '2px 6px', cursor: 'pointer', display: 'grid', placeItems: 'center', gap: 4 }}>
            <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke={active ? SGD : SINKS} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" style={{ filter: active ? 'drop-shadow(0 0 5px rgba(201,168,76,0.6))' : 'none', transition: 'all .2s' }}><path d={t.d} /></svg>
            <span style={{ fontFamily: sSerif, fontWeight: 700, fontSize: 10, letterSpacing: '0.08em', color: active ? SGD : SINKS }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

function MangasmApp({ tweakDefaults, launch, initialScreen, noChrome }) {
  const [t, setTweak] = useTweaks(tweakDefaults);
  const [phase, setPhase] = React.useState(launch ? 'launch' : 'app');
  const [screen, setScreen] = React.useState(initialScreen || 'profile');
  const [data, setDataState] = React.useState(PROFILE_DEFAULT);
  const [vis, setVisState] = React.useState(VIS_DEFAULT);
  const [premium, setPremium] = React.useState(false);
  const [match, setMatch] = React.useState(null);
  const openMatch = (c) => { setMatch(c); setScreen('matchdetail'); };
  const setData = (k, v) => setDataState((p) => ({ ...p, [k]: v }));
  const setVis = (k) => setVisState((p) => ({ ...p, [k]: !p[k] }));
  const UI = window.MangasmUI;

  return (
    <React.Fragment>
      <IOSDevice dark>
        {phase === 'launch' ? (
          <window.LaunchFlow onEnter={() => setPhase('app')} />
        ) : (
        <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', fontFamily: sSans, color: '#fff' }}>
          <Background night={t.night} weather={t.weather} starlink={t.starlink} />
          {screen === 'profile' && <UI.ProfileScreen data={data} vis={vis} premium={premium} />}
          {screen === 'discover' && <UI.DiscoverScreen premium={premium} setPremium={setPremium} />}
          {screen === 'search' && <UI.DiscoverScreen />}
          {screen === 'likes' && <UI.DiscoverScreen likes />}
          {screen === 'aimatch' && <UI.AIMatchScreen data={data} onOpen={openMatch} />}
          {screen === 'settings' && <UI.SettingsScreen data={data} setData={setData} vis={vis} setVis={setVis} premium={premium} setPremium={setPremium} />}
          {screen === 'matchdetail' && match && <UI.MatchDetailScreen candidate={match} data={data} onBack={() => setScreen('aimatch')} onMessage={() => setScreen('chat')} />}
          {screen === 'chat' && match && <UI.ChatScreen candidate={match} onBack={() => setScreen('matchdetail')} />}

          {screen !== 'chat' && <UI.TopBar weather={t.weather} starlink={t.starlink} settingsOpen={screen === 'settings'} onSettings={() => setScreen(screen === 'settings' ? 'profile' : 'settings')} />}

          {t.bubbles && screen === 'profile' && (
            <React.Fragment>
              <UI.ChatBubble init={{ x: 18, y: 648 }} tail="left"><span style={{ fontFamily: sSans, fontWeight: 400, fontSize: 11, lineHeight: 1.35 }}>Hey — in Dubai this weekend? 🛥️</span></UI.ChatBubble>
              <UI.ChatBubble init={{ x: 232, y: 706 }} tail="right"><Equalizer color={SG} n={7} /></UI.ChatBubble>
            </React.Fragment>
          )}

          {screen !== 'chat' && !noChrome && <TabBar screen={screen} setScreen={setScreen} />}
        </div>
        )}
      </IOSDevice>

      <TweaksPanel>
        <TweakSection label="Scene" />
        <TweakToggle label="Night / god rays" value={t.night} onChange={(v) => setTweak('night', v)} />
        <TweakToggle label="Starlink overlay" value={t.starlink} onChange={(v) => setTweak('starlink', v)} />
        <TweakToggle label="AIM chat bubbles" value={t.bubbles} onChange={(v) => setTweak('bubbles', v)} />
        <TweakSection label="Live weather (WeatherKit)" />
        <TweakSelect label="Condition" value={t.weather} options={['clear', 'cloudy', 'rain', 'heavyRain', 'snow', 'sleet']} onChange={(v) => setTweak('weather', v)} />
        <TweakSection label="Membership" />
        <TweakToggle label="Mangasm M+ (premium)" value={premium} onChange={(v) => setPremium(v)} />
        <TweakSection label="Launch" />
        <TweakButton label="Replay intro" onClick={() => { setScreen('profile'); setPhase('launch'); }} />
      </TweaksPanel>
    </React.Fragment>
  );
}

window.MangasmApp = MangasmApp;
