# Ship — Mangasm build 24

**Bundle ID:** `com.mangasm.app`  
**Marketing version:** 1.1.0  
**CFBundleVersion:** 24  
**Team:** 854XZ2543V  
**Shipped:** 2026-07-23 (swagger)

## Binary

| Item     | Value                                          |
| -------- | ---------------------------------------------- |
| Archive  | `build/Mangasm.xcarchive`                      |
| IPA      | `build/export/Mangasm.ipa`                     |
| Signing  | iPhone Distribution: Mark Webster (854XZ2543V) |
| Profile  | Mangasm App Store 18                           |
| Supabase | Embedded in Info.plist (B3 gate)               |

## App Store Connect

Upload of the same IPA on 2026-07-23 returned:

```text
ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE
previousBundleVersion: 24
The bundle version must be higher than the previously uploaded version: '24'
```

**Conclusion:** Build **24** is **already present** on ASC / TestFlight processing pipeline for `com.mangasm.app`. No re-upload required for this number.

## Git

- `project.yml` → `CURRENT_PROJECT_VERSION: "24"`, `MARKETING_VERSION: "1.1.0"`
- Branch: `ci/ios-build-24`

## Next binary

ASC requires **CFBundleVersion > 24** (i.e. **25+**) for any new IPA.
