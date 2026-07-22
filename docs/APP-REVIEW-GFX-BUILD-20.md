# App Review graphics — Build 1.1.0 (20)

**Ship target:** TestFlight / App Store version using build **20**  
**Date:** 2026-07-22

## App Icon (`App/iOS/Assets.xcassets/AppIcon.appiconset`)

| Check                   | Status                                            |
| ----------------------- | ------------------------------------------------- |
| 1024×1024 marketing     | `AppIcon-1024.png` · true PNG · **no alpha**      |
| All Contents.json slots | iPhone + iPad + marketing regenerated from master |
| Format                  | PNG (not JPEG-with-.png extension)                |
| Transparency            | Flattened (Apple rejects alpha on marketing icon) |

## Marketing web panels (`web/assets/`)

| Asset                                          | Size      | Role                 |
| ---------------------------------------------- | --------- | -------------------- |
| `01-opening-hero.jpg` … `06-rebuild-phone.jpg` | 1280×720  | Landing + storybook  |
| `storyboard-full.jpg`                          | 1024×1024 | Storybook cover / OG |

Re-encoded JPEG quality ~85 for smaller ASC/web payloads. Copy uses **industry archetypes** (not named competitors) for review safety.

## Storybook (public)

- `/storybook` · 18+ comic edition (age badge)
- Not required for binary review; supports marketing / defense brief

## Still human on ASC (not in repo)

- [ ] iPhone 6.7" screenshots (portrait) — real device or Simulator
- [ ] Privacy policy URL live (no 404)
- [ ] App Review demo account Opal `[SET]`
- [ ] Attach build **20** after Processing

## Pre-submit smoke

```bash
# Icons
sips -g hasAlpha -g format App/iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
# Expect: hasAlpha no · format png · 1024

# Archive already uploaded: 1.1.0 (20)
```
