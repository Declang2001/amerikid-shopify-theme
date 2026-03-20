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

## Verified Runtime Findings (2026-03-19)
- **Active Builder:** **PageFly** is confirmed active and driving the homepage.
- **App Bloat:** **Videeo**, **Gameball**, and **JustSell** are initializing globally on every page (Home, Product, Collection, Mystery Box).
- **Redundant Canvas Systems:** Product pages and Mystery Box pages are running up to 5 and 4 concurrent `<canvas>` elements respectively (e.g., `aknav-field`, `ak-product-field`, `ak-back-field`, `holo-rail-field`). This is a major source of GPU lag.
  - **Confirmed Optimization (2026-03-19):** `ak-product-field` now uses true offscreen cancellation — its `requestAnimationFrame` loop stops entirely when scrolled out of viewport and restarts on re-entry. Other canvas systems (`aknav-field`, `ak-back-field`, `holo-rail-field`) have not yet been patched.
- **Builder Remnants:** **EComposer** and **GemPages** are inactive in terms of page layout, but EComposer still has an active preconnect/prefetch in `theme.liquid`. GemPages assets (`gp-global.css`) were not observed loading at runtime.

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
