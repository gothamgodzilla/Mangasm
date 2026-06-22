# Custom Fonts

Drop `.ttf` or `.otf` files here to enable Mangasm's custom typography.

## Required font files

| Font | File to add | OFL licensed |
|------|-------------|--------------|
| Cormorant Garamond Bold | `CormorantGaramond-Bold.ttf` | Yes (SIL OFL 1.1) |
| Cormorant Garamond Regular | `CormorantGaramond-Regular.ttf` | Yes |
| Mulish | `Mulish-VariableFont_wght.ttf` | Yes (SIL OFL 1.1) |
| Space Mono Regular | `SpaceMono-Regular.ttf` | Yes (SIL OFL 1.1) |
| Space Mono Bold | `SpaceMono-Bold.ttf` | Yes |

All three families are available from [Google Fonts](https://fonts.google.com/) under the SIL Open Font License.

## How registration works

`MGFont` in `Sources/MangasmApp/DesignSystem/Theme.swift` calls
`.custom("CormorantGaramond-Bold", size:)`, `.custom("Mulish", size:)`, and
`.custom("SpaceMono-Regular", size:)`.

SwiftUI resolves `.custom(name:)` at runtime: when the font file is present and
registered (via `Package.swift`'s `.process("Resources")` rule), the named font
is used; when it is absent, SwiftUI silently falls back to the system serif /
default / monospaced font respectively. The app never hard-fails on a missing
font.

## After adding font files

Re-run `swift build` — Swift Package Manager will include the new `.ttf` files
in `Bundle.module` automatically via the `.process("Resources")` rule in
`Package.swift`.
