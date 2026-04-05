# Source of Truth

## Repo Purpose
This repository holds the unpublished working copy of the live Amerikid Shopify theme. It serves as a staging ground for performance optimization and cleanup before pushing updates to the live store.

## High-Level Theme Description
This theme is based on Shopify Dawn but contains heavy custom aesthetic overrides, most notably a global "Impact" font style, neon elements, and custom interactive "starfield" canvas animations. It also shows traces of multiple page builder apps coexisting.

## Current Known Priorities
1. Establish cross-AI continuity and reliable documentation (Complete).
2. Reduce lag and unnecessary fat (bloat, large global assets, duplicated scripts) without altering visual output.
3. Consolidate duplicated navigation code currently hardcoded across multiple JSON templates.
4. Future Phase: Mystery Crate integration work.

## Locked / Non-Negotiable
- The visual identity, animations, and "feel" of the website must not change.
- Mystery Crate logic is critical and must not be broken during cleanup.

## Optimization Goal
Make the theme less glitchy, faster, leaner, and more maintainable while preserving the exact current experience.

## Mystery Crate Note
The Mystery Crate is currently implemented as an iframe embed pointing to an external Vercel app. The wrapper logic contains fragile styling and its own canvas animation. 
- **Verified Runtime Finding:** The Vercel app is currently returning a 404 for `crate.glb`. This is an external issue but affects the "glitchy" feel.
- **Static Lock Removed (2026-04-02):** The wrapper's `LOCKED_DEFAULT` boolean was changed from `true` to `false` on the unpublished theme. The blur overlay and pointer-events block are now disabled, exposing the iframe for interaction. No dynamic entitlement gating exists — the wrapper does not check `customer.tags`, `crate_spins:*`, or metafields. It passes `customer_id` and `demo` to the iframe but no entitlement data. Future entitlement gating will require new Liquid conditionals and potentially new iframe params.

## Verified Runtime Findings (2026-03-19)
- **Active Builder:** **PageFly** is confirmed active and driving the homepage.
- **App Bloat:** **Videeo** and **JustSell** are initializing globally on every page (Home, Product, Collection, Mystery Box). Empty PopClips carousel app blocks have been removed from `page.club-hub.json`, `page.json`, and `page.badmusic.json` (2026-04-03). The global Videeo app embed SDK remains enabled in `config/settings_data.json` — disabling it is the next step pending business confirmation that Videeo/PopClips is unused. **Gameball** has been fully removed from theme code (2026-03-27): hardcoded snippet includes removed from both layouts, snippet file deleted, app embed disabled in settings_data.json. Note: the Gameball Shopify app may still need to be uninstalled from the Shopify admin separately.
- **Redundant Canvas Systems:** Product pages and Mystery Box pages are running up to 5 and 4 concurrent `<canvas>` elements respectively (e.g., `aknav-field`, `ak-product-field`, `ak-back-field`, `holo-rail-field`). This is a major source of GPU lag.
  - **Confirmed Optimization (2026-03-19):** `ak-product-field` now uses true offscreen cancellation — its `requestAnimationFrame` loop stops entirely when scrolled out of viewport and restarts on re-entry.
  - **Confirmed Optimization (2026-03-20):** `ak-collection-field` now uses the same true offscreen cancellation pattern. Its rAF loop stops entirely when the collection product grid scrolls out of viewport and restarts on re-entry.
  - **Confirmed Optimization (2026-03-20):** `ak-back-field` now uses the same true offscreen cancellation pattern. Its existing partial `IntersectionObserver` (which previously kept scheduling rAF frames while offscreen) was upgraded to fully cancel the loop when offscreen and restart cleanly on re-entry.
  - **Confirmed Optimization (2026-03-26):** `holo-rail-field` now uses the same true offscreen cancellation pattern. Its rAF loop stops entirely when the header/rail scrolls out of viewport and restarts on re-entry. Patched across all 18 JSON templates (two code variants: 10 pretty-printed, 8 minified).
  - **Confirmed Optimization (2026-03-27):** `aknav-field` now uses the same true offscreen cancellation pattern. Its rAF loop stops entirely when the nav starfield scrolls out of viewport and restarts on re-entry. Patched across all 18 JSON templates (four code variants). All 5/5 known canvas systems now have offscreen cancellation.
  - **Confirmed Optimization (2026-04-04):** `ak-product-field` visible-cost reduction (Phase 1). Dust particle cap reduced from 3,000–17,000 to 800–2,000 and `ctx.shadowBlur` removed from dust draw calls. Floater glow, shooter glow, colors, blend mode, and all other behavior unchanged. Not yet propagated to other canvas systems.
  - **Combined Top-of-Page System (2026-04-04):** `sections/ak-top.liquid` created — a single shared section replacing the two adjacent `custom_liquid` sections (holo-rail + aknav) with one canvas, one header bar, and one nav panel. Dust capped at 400–800, no dust shadowBlur, floater glow and full shooting star system preserved. Visual continuity refinement applied same day: frosted-glass effect stripped from nav area so particles render continuously across full section height. **Site-wide rollout (2026-04-04):** All 17 remaining two-section templates migrated to ak-top (total 18/18 including cart). Removed ~1,310KB of inline custom_liquid. 15 aknav-only collection templates (no holo-rail) intentionally skipped — different pattern requiring separate handling.
- **Builder Remnants:** **EComposer** and **GemPages** are inactive in terms of page layout. EComposer render calls (`ecom_header`, `ecom_footer`) have been removed from `layout/theme.liquid` (2026-03-27), eliminating 6 preconnect/prefetch links to `cdn.ecomposer.app` and 167+ lines of conditional JS on every page. Note: `theme.pagefly.liquid` and `layout/ecom.liquid` still render these snippets. GemPages assets (`gp-global.css`) were not observed loading at runtime.

## Needs Verification
- Whether all the `image-banner-[name].liquid` sections are genuinely required or if they can be consolidated.
- How much of `global.js` and `animations.js` is custom versus stock Dawn.
- If `assets/gp-global.css` is truly orphaned (it appears so from runtime traces).

## AI Workflow Expectations
1. Read `AGENTS.md` and this file.
2. Read `docs/known-fragile-areas.md` and `docs/theme-architecture.md` if touching layout or specific pages.
3. Propose changes with risk assessment.
4. Execute approved changes.
5. Log changes in `docs/change-log.md`.
