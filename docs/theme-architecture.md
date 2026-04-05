# Theme Architecture

## Base Framework
- The underlying structure is **Shopify Dawn** (cart drawers, snippets like `facets.liquid`, `price.liquid`, standard JSON template architecture).

## Custom Amerikid Overrides
- **Font Forcing:** "Impact" font is frequently forced via inline styles or custom CSS blocks targeting specific sections.
- **Glass Navigation:** A highly custom navigation drawer with tilt effects and a "MENU" label, combined with a starfield canvas.
- **Canvases:** Multiple HTML `<canvas>` elements used for particle effects.
    - **Confirmed Redundancy:** Product pages run up to 5 canvases concurrently.
    - **Confirmed IDs:** `aknav-field` (nav), `ak-product-field` (product), `ak-back-field` (background), `holo-rail-field` (rail), and `confetti`.
    - **Offscreen Cancellation:** `ak-product-field` (shipped 2026-03-19), `ak-collection-field` (shipped 2026-03-20), `ak-back-field` (shipped 2026-03-20), `holo-rail-field` (shipped 2026-03-26), and `aknav-field` (shipped 2026-03-27) have true rAF cancellation when offscreen. All 5/5 known canvas systems are now patched.
    - **Combined Top-of-Page (ak-top):** `sections/ak-top.liquid` (shipped 2026-04-04) replaces the two adjacent `custom_liquid` sections (holo-rail + aknav) with a single shared section containing one canvas. Cart-only prototype deployed to `templates/cart.json`; remaining 17 templates still use the old two-section pattern.

## Page Builder Traces (Verified 2026-03-19)
The repository shows evidence of three separate page builders:
- **PageFly (Active):** Driving the homepage and providing scripts globally. `layout/theme.liquid` includes `pagefly-app-header`.
- **GemPages (Inactive):** Not currently observed loading at runtime. `gp-global.css` and `snippets/gp-head.liquid` are present but not called in the main layout.
- **EComposer (Inactive):** Not currently observed driving layouts. Render calls removed from `layout/theme.liquid` (2026-03-27). Still rendered in `theme.pagefly.liquid` and `layout/ecom.liquid`. Snippet files preserved in repo.

## Key Global Scripts
- **Videeo:** `popclips-player`, `popclips-likes-and-views`, and related SDK scripts load globally.
- **Gameball (Removed 2026-03-27):** Hardcoded snippet includes removed from `theme.liquid` and `theme.pagefly.liquid`, snippet file deleted, app embed disabled in `settings_data.json`. The Gameball Shopify app may still need to be uninstalled from the Shopify admin.
- **JustSell:** `latest.js` loads globally.
- **GSAP:** Loaded twice in some cases (via PageFly and theme assets).

## Key Directories and Files
- `layout/theme.liquid`: The main entry point. Currently includes `pagefly-app-header` and large inline styling blocks. EComposer render calls removed 2026-03-27. Gameball include removed 2026-03-27.
- `templates/`: Contains massive JSON template sprawl. Over 15 `collection.[name].json` templates exist, almost all containing a duplicated `custom_liquid` block for the navigation.
- `sections/`: Contains duplicate variations of core sections (e.g., `featured-collection.liquid` vs `featured-collection2.liquid`, and various `image-banner-*.liquid` files).
- `assets/`: Contains standard Dawn assets (`base.css`, `global.js`) mixed with builder assets (`gp-global.css`, `pagefly-animation.css`) and large media (`sparkle.gif`).
