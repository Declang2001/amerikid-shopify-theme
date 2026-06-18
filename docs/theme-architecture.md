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
    - **Combined Top-of-Page (ak-top):** `sections/ak-top.liquid` (shipped 2026-04-04) replaces the two adjacent `custom_liquid` sections (holo-rail + aknav) with a single shared section containing one canvas. Rolled out site-wide (2026-04-04) to all 18 templates that had the two-section pattern. **Collection page normalization (2026-04-07):** 12 additional collection templates that used an old CSS-only header/nav system (no canvas, no particles) migrated to ak-top. Old header/nav sections preserved with `"disabled": true`. All 18 Archive-linked collection pages now use ak-top.

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

## Archive Page (Card Stack)
- **Route:** `/collections/` (list-collections template)
- **Section:** `sections/ak-archive.liquid` v6 (shipped 2026-04-07) — single-screen folder-deck selector replacing 18 vertical image-banner sections. Contains all HTML, CSS, JS, and a particle canvas inline. Bottom-aligned card fan: cards are shorter than the stage (76% height), leaving structural headroom for trailing strips. Each trailing card shifts up by 26px per depth — visible strips are guaranteed, not dependent on translateY overcoming card overlap. Flat fan (no perspective/translateZ). Div-based cards with JS navigation (`data-href` + `window.location`). Spring cancellation per card prevents orphaned animations. Particle canvas uses ak-top's proven pattern (dust, floaters, shooters, DPR 1, IO cancel/restart). 18 collection cards with images, titles, and links. Navigation: prev/next arrow buttons + keyboard arrows. **Cassette-case skin (2026-04-07):** CSS-only visual treatment makes cards read as cassette-case/cassette-box objects — visible dark shell housing with inset cover art, plastic sheen, hinge line, and spine-style trailing tabs. Removable by deleting the `CASSETTE CASE SKIN` CSS block.
- **Previous structure:** 18 individual `image-banner-*.liquid` sections + 2 emoji marquee `custom_liquid` sections, all orchestrated by `templates/list-collections.json`. Those section files are preserved in `sections/` but no longer referenced by the template.
- **Archive magazine (LIVE 2026-06-18, ARCH-MAG-LIVE-1):** `/collections/` now renders **`sections/ak-archive-magazine.liquid`** — a self-contained printed-zine flipbook (closed "ARCHIVE" cover → centred two-page spread desktop / single page mobile; masthead + 18-item clickable Contents + one item per page; 18 items + order preserved; real `<a>` collection links; reuses `settings.logo`; CSS-3D page-turn; reduced-motion + no-JS fallback; all HTML/CSS/JS inline). Activated via `templates/list-collections.json` (`ak-archive-magazine` in `order`). The v6 cassette deck `sections/ak-archive.liquid` is set `"disabled": true` and **preserved as the dormant fallback (byte-identical, never edited)**. Pushed directly to the live theme `186464731416` via owner-approved scoped `--only --allow-live` pushes (no draft, no `shopify theme publish`).

## Key Directories and Files
- `layout/theme.liquid`: The main entry point. Currently includes `pagefly-app-header` and large inline styling blocks. EComposer render calls removed 2026-03-27. Gameball include removed 2026-03-27.
- `templates/`: Contains massive JSON template sprawl. Over 15 `collection.[name].json` templates exist, almost all containing a duplicated `custom_liquid` block for the navigation.
- `sections/`: Contains duplicate variations of core sections (e.g., `featured-collection.liquid` vs `featured-collection2.liquid`, and various `image-banner-*.liquid` files).
- `assets/`: Contains standard Dawn assets (`base.css`, `global.js`) mixed with builder assets (`gp-global.css`, `pagefly-animation.css`) and large media (`sparkle.gif`).
