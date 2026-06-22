# Mangasm — Asset Brief (production art)

The app ships with placeholder art (per the design handoff). These are the
production assets to render and drop into `Resources/`.

## Runway splash video — `runway.mp4`
Portrait (≈464×688), H.264, ~6s, looped & muted.

**Art-direction prompt (user-supplied):**
> A steampunk fashion show featuring high-tech artificial intelligence fashion,
> avant-garde men with striking, angular features walking down a catwalk, set
> against a cyberpunk background with cascading digital rain effects, with a
> highly sophisticated audience in ornate, steampunk-inspired gowns watching on
> both sides. Exposed skin with a "MANGASM" tattoo.

Notes: dark luxury palette; works under the cinematic grade + orange haze
overlays; subject framed for a bottom-anchored wordmark lockup.

## Hero plate — `lambo_hero.jpg`
Portrait green-Lamborghini beach render, car anchored bottom, beach/water/
skyline rising above, twilight sky synthesized above the seam.
`background-position: 50% 100%`. Replace the salvaged mockup plate with a clean
high-res render.

## Sign-in city photography (optional upgrade)
Swap the placeholder SVG skylines for licensed photos of Dubai, London,
Mykonos, Tokyo behind the same veil + Ken-Burns.

## Entrance soundtrack — `entrance.m4a` (or `.mp3`)
A looped **Playa / Burning Man deep-house beat** that scores the runway entrance —
hypnotic, warm, ~120–123 BPM, no vocals, seamless loop. It plays under the
(muted) runway video and **fades out over 0.48s** as the splash hands off to
sign-in, so the loop reads as the model's walk-on music. Drop a licensed/royalty-
free loop at `Sources/MangasmApp/Resources/entrance.m4a`; absent → silent (no crash).
The playback/loop/fade mechanism is already wired in `SplashView` (`RunwayPlayer`).
> Note: the audio file itself must be supplied — it cannot be generated here.

## Fonts (OFL)
Cormorant Garamond, Mulish, Space Mono — add `.ttf` to `Resources/Fonts/`.
