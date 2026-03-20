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

## DO NOT TOUCH FIRST list
- Do not refactor `sections/main-product.liquid` yet.
- Do not edit or attempt to clean up `templates/page.mystery-box.json` yet.
- Do not reorder JavaScript tags in `theme.liquid` without live browser testing.

## Identified Runtime Glitches (2026-03-19)
- **Mystery Box 404:** `crate.glb` fails to load from `amerikid-mystery-crate.vercel.app`.
- **Duplicate Elements:** Console error `the name "video-player" has already been used` suggests script duplication.
- **High GPU Load:** Concurrent canvases on Product and Mystery Box pages.
