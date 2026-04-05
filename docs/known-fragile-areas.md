# Known Fragile Areas

## "Do Not Break" Principles
- Do not remove canvas tags (`<canvas>`) or their associated Javascript. The ambient particles and starfield effects are core to the brand.
- Do not normalize typography if it removes the "Impact" font. Hardcoded font declarations exist for a reason.

## Major Fragile Files
- `sections/main-product.liquid`: This file is exceptionally large (2800+ lines). It contains custom canvas implementation (`ak-product-field`), deeply nested CSS overrides for transparency, and layout hacks.
- `layout/theme.liquid`: Contains heavy inline CSS defining color schemes and CSS variables, as well as multiple app embeds. Changing script load order here is risky.
- `templates/page.mystery-box.json`: Contains the Vercel iframe embed wrapped in a highly specific locked layout (`ak-mb-wrap`, `ak-mb-canvas`).

## Fragile Systems
- **Starfield Navigation:** The entire `amerikid-button-wrapper` block (glass menu, canvas background, hover glows) is duplicated across many JSON files. Modifying it requires updating it everywhere or successfully consolidating it first.
- **Brand Overrides:** Many custom sections like `featured-collection2.liquid` use `#collection-{{ section.id }} * { font-family: Impact !important; }`. Refactoring CSS may accidentally break these targeted brand styles.
- **Multiple Canvases:** The interaction between multiple active canvases (`aknav-field`, `ak-product-field`, etc.) is likely sensitive to initialization timing.
  - **Note (2026-03-19):** `ak-product-field` now uses a cancel/restart pattern via `IntersectionObserver`. Its rAF loop stops when offscreen and restarts on re-entry. When applying similar patches to other canvases, follow this same pattern: set `animationId = null` on pause, reset `lastFrameTime = 0` on resume, guard against double-start with `if(!animationId)`.
  - **Note (2026-04-04):** `ak-product-field` visible-cost reduction (Phase 1). Dust particle cap reduced from 3,000–17,000 to 800–2,000 and `ctx.shadowBlur` removed from dust draws. Floater/shooter glow intact. This is the proven pattern for propagating to other canvas systems if successful.
  - **Note (2026-03-20):** `ak-collection-field` now uses the same cancel/restart pattern.
  - **Note (2026-03-20):** `ak-back-field` now uses the same cancel/restart pattern. Its existing partial `IntersectionObserver` was upgraded from "skip draws but keep scheduling" to true cancellation.
  - **Note (2026-03-26):** `holo-rail-field` now uses the same cancel/restart pattern. Patched across all 18 JSON templates containing the holo-rail `custom_liquid` section (two code variants: 10 pretty-printed using `step`/`lastFrameTime`, 8 minified using `stp`/`lft`).
  - **Note (2026-03-27):** `aknav-field` now uses the same cancel/restart pattern. Patched across all 18 JSON templates containing the aknav `custom_liquid` section (four code variants: V1/V4 with `hardSeedOnce`/`softResizeKeepPositions`, V2/V3 with simple `reseed`). All five of five known canvas systems are now patched. The IO observer (`aknavIO`) watches `#amerikid-button-wrapper` (position:relative, not fixed/sticky). The nav drawer is detached to `document.body` and is fully independent of the canvas rAF loop.
  - **Note (2026-04-04):** `sections/ak-top.liquid` created as a combined replacement for the two separate `custom_liquid` sections (holo-rail + aknav). Uses one canvas instead of two, with reduced dust (400–800 cap), no dust shadowBlur, preserved floater glow, and full shooting star system. Cart-only prototype: `templates/cart.json` migrated. Remaining 17 templates still use the old two-section pattern. When propagating, each template needs: remove holo-rail section + aknav section from `sections` object and `order` array, add one `ak-top` section reference.

## DO NOT TOUCH FIRST list
- Do not refactor `sections/main-product.liquid` yet.
- Do not edit or attempt to clean up `templates/page.mystery-box.json` yet.
- Do not reorder JavaScript tags in `theme.liquid` without live browser testing.

## Identified Runtime Glitches (2026-03-19)
- **Mystery Box 404:** `crate.glb` fails to load from `amerikid-mystery-crate.vercel.app`.
- **Duplicate Elements:** Console error `the name "video-player" has already been used` suggests script duplication.
- **High GPU Load:** Concurrent canvases on Product and Mystery Box pages.
