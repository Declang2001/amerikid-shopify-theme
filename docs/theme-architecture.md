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

## Page Builder Traces (Verified 2026-03-19)
The repository shows evidence of three separate page builders:
- **PageFly (Active):** Driving the homepage and providing scripts globally. `layout/theme.liquid` includes `pagefly-app-header`.
- **GemPages (Inactive):** Not currently observed loading at runtime. `gp-global.css` and `snippets/gp-head.liquid` are present but not called in the main layout.
- **EComposer (Inactive):** Not currently observed driving layouts, but `layout/theme.liquid` still includes `ecom_header` and `ecom_footer`, which triggers preconnects/prefetches to `cdn.ecomposer.app`.

## Key Global Scripts
- **Videeo:** `popclips-player`, `popclips-likes-and-views`, and related SDK scripts load globally.
- **Gameball:** `gb-init-shopify.js` and widget scripts load globally.
- **JustSell:** `latest.js` loads globally.
- **GSAP:** Loaded twice in some cases (via PageFly and theme assets).

## Key Directories and Files
- `layout/theme.liquid`: The main entry point. Currently includes `ecom_header`, `gameball`, `pagefly-app-header`, and large inline styling blocks.
- `templates/`: Contains massive JSON template sprawl. Over 15 `collection.[name].json` templates exist, almost all containing a duplicated `custom_liquid` block for the navigation.
- `sections/`: Contains duplicate variations of core sections (e.g., `featured-collection.liquid` vs `featured-collection2.liquid`, and various `image-banner-*.liquid` files).
- `assets/`: Contains standard Dawn assets (`base.css`, `global.js`) mixed with builder assets (`gp-global.css`, `pagefly-animation.css`) and large media (`sparkle.gif`).
