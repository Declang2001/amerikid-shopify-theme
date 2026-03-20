# Change Log

All structural and performance optimizations must be recorded here.

| Date | Summary | Files Changed | Reason | Risk Level | Follow-up Verification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 2026-03-19 | Documentation Bootstrap | `AGENTS.md`, `docs/*` | Establish AI continuity and source of truth before beginning optimization pass. | None | N/A |
| 2026-03-19 | Runtime Findings Sync | `docs/*` | Update documentation with verified runtime audit findings (PageFly active, EComposer remnants, canvas redundancy). | None | N/A |
| 2026-03-19 | ak-product-field offscreen cancellation | `sections/main-product.liquid` | Stop scheduling `requestAnimationFrame` when the product canvas is offscreen. Restart cleanly when it re-enters the viewport. Reduces idle GPU/CPU cost on product pages when users scroll below the hero area. | Low | Verify canvas animates normally when visible, stops when scrolled out of view, resumes with no flash/pop/reseed on scroll-back. Check desktop, mobile, reduced-motion. |
