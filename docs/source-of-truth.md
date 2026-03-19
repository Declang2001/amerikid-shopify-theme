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
The Mystery Crate is currently implemented as an iframe embed pointing to an external Vercel app. The wrapper logic contains fragile styling and its own canvas animation. Do not break this integration. 

## Initial Analysis Learnings
- **Bloat:** The theme suffers from multi-system bloat (PageFly, GemPages, EComposer remnants).
- **Duplication:** Navigation code (Glass menu + Starfield) is hardcoded inside `custom_liquid` blocks across dozens of JSON templates (e.g., `collection.watermelon.json`, `product.json`, etc.).
- **Fragility:** `sections/main-product.liquid` is massive (2800+ lines) with extensive inline CSS and canvas logic.

## Needs Verification
- Which page builder is actively used versus which ones are just leaving leftover asset requests in `theme.liquid`.
- Whether all the `image-banner-[name].liquid` sections are genuinely required or if they can be consolidated.
- How much of `global.js` and `animations.js` is custom versus stock Dawn.

## AI Workflow Expectations
1. Read `AGENTS.md` and this file.
2. Read `docs/known-fragile-areas.md` and `docs/theme-architecture.md` if touching layout or specific pages.
3. Propose changes with risk assessment.
4. Execute approved changes.
5. Log changes in `docs/change-log.md`.