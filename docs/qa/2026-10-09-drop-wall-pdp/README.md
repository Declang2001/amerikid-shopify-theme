# Drop wall + PDP size chart — DROP-WALL-REFRESH-3 / PDP-SIZE-CHART-1 (2026-10-09)

Theme **188605497624 is LIVE**. Owner requests, reviewed by three adversarial agents plus a
final reviewer (reports in `review/`), then built and QA'd locally. Pushes are owner-run.

## What changed

| # | Owner request | Change | File |
|---|---|---|---|
| 1 | Showcase "takes up too much space in the middle"; "make it faster" | Kept in place after the M row (moving it under the banners pushed ALL of row 1 below the fold at 1440x900, see `review/contact-sheet-showcase.jpg`, B1/B2). Frame `min(100%,48vh,548px)` at **8:7** `object-fit:cover` (+ `min-height:0;overflow:hidden`, required); desktop-only `padding-block:0`; `sizes` updated. M-to-L gap at 1440x900: **787px -> 484px**. Speed: **4s -> 2.5s** per shirt, slide .8s -> .55s. Setting `showcase_seconds` now range 2-10, **step 0.5**, default 2.5 (theme editor). JS waits (max 3 beats) for the next image if it is still downloading. | `sections/ak-drop-wall.liquid` |
| 2 | Sold shirts to the far right of each row | Liquid partition per row: in-stock, then sold, then empty cells, each in design order. Applies to every row (S/M are fully in stock today). Not CSS `order`, so reading/tab order == visual order. | `sections/ak-drop-wall.liquid` |
| 3 | Size chart on every SL tee | New `custom_liquid` block `size_chart` after `description` in the PRODUCT template renders `snippets/ak-drop-size-chart.liquid`: chart image (1200px, 155KB, lazy) + visually-hidden table. Shown when handle starts `sl-` or the product is tagged `size-chart`; never when tagged `no-size-chart` (wins; case-insensitive). | NEW `assets/ak-size-chart.jpg`, NEW `snippets/ak-drop-size-chart.liquid`, `templates/product.json` |

8:7 is the widest frame that does not cut shirts (<=0.17% lost on any of the 20); 4:3 cut
SL-XL-02 by 9.7%. Grid gaps and mobile padding are untouched (the next row's SOLD OUT burst
needs them).

## Caught in local QA (not by the reviews)
The reviewed `showcase_ms` setting (2000-10000 ms) was REJECTED by Shopify on upload:
"max must be less than 10000". A failed upload would have refused the whole section. Switched to
seconds with `step: 0.5`, which Shopify accepted on the dev theme (so decimal steps are proven).

## Local verification (dev theme 189799203096 via `shopify theme dev` with no `--theme`)
- Theme Check: 732 offenses before and after; only the pre-existing RemoteAsset in a touched file.
- python-liquid render, 9 stock scenarios: 20 tiles each, correct order, showcase unchanged.
- Gate test: 10 tag/handle cases pass.
- Headless Chromium (`local/qa-result.json`):
  - all 6 sizes: L = L-05 | L-01..04 sold; XL = XL-02 XL-03 | XL-01 XL-04 XL-05 sold; overflow 0; tab order == visual
  - 1440x900: row-1 titles 888px (above fold); showcase frame 432x378; cadence 2.5s; mouse hover does NOT hold
  - keyboard focus and reduced motion hold; 390x844 frame 354x310
  - PDP sl-l-05 / sl-s-01 / sl-xl-02 / sl-l-01 at 1440 and 390: chart under description, above Share,
    490px / 357px, size header still bold, overflow 0, no Liquid error; flag-tee: no chart.

## Push (owner-run, in this order; agent pulls back and `cmp`s after each)
1. `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only assets/ak-size-chart.jpg --only snippets/ak-drop-size-chart.liquid`
   (inert; HARD GATE: confirm the snippet is live before step 3, or every product page errors)
2. `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only sections/ak-drop-wall.liquid`
3. `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only templates/product.json`

## Rollback
- Wall: `cp docs/qa/2026-10-09-drop-wall-pdp/rollback/ak-drop-wall.liquid.live-2026-10-09 sections/ak-drop-wall.liquid` + push 2's command.
- Size chart, no push: theme editor -> product template -> delete the custom-liquid block (or tag a product `no-size-chart`).
  By push: restore `rollback/product.json.live-2026-10-09` + push 3's command. Never remove the snippet before the template.

## Open owner questions
- SL-L-01 (long sleeve, sold), SL-L-05 (cap-sleeve crop, in stock), SL-XL-02 (black tee, in stock) look like
  different blanks (`review/sl-contact-sheet.png`). If the chart is wrong for them, tag them `no-size-chart` in Admin.
- On phones the wall is 2 columns, so the reorder reads as "in-stock first within each size", not left/right.

## Push log
(filled in after the owner's pushes)
