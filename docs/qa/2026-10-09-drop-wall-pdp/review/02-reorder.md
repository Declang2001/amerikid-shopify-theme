# 02 — Reorder: sold shirts to the end of each row (adversarial review)

Reviewer: read-only. No repo file was edited and nothing was pushed. All artefacts are in `review/reorder/`.

## Verdict
**Ship the main agent's design: generic, stable, in-stock | sold | empty, all rows, no new setting.** It is
low risk (one file, markup order only, no CSS/JS/schema-setting change). All scenarios render 20 cells and keep
the showcase where it was, and every tile's HTML is byte-identical to today's, only reordered. I found no blocker.
Findings are mostly about expectations: mobile won't look "left/right", and PDP prev/next stays 01..05.

## Verified facts
- Live data (products.json, 2026-10-09) matches the brief. In stock: S-01..05, M-01..05, L-05, XL-02, XL-03 (13). Sold: L-01..04, XL-01, XL-04, XL-05 (7).
- The only `all_products` user on the collection template is the wall. The other grep hits are `routes.all_products_collection_url` / `collection.all_products_count`. The capture design does one lookup per handle, with the same 20 unique handles as today (the pre-pass reuses the same handles).
- No other file references `.akdw-item`, `.akdw-row` or `data-akdw-*`, and the section's JS never indexes tiles. Nothing depends on tile order.
- Live page: the ETag is `page_cache:…CollectionDetailsController…` with `cdn-cache-control: no-cache, no-store`. The order comes from the same `p.available` that already drives the SOLD OUT burst and the showcase, so it refreshes exactly when the burst does. It adds no new staleness. An open tab does not live-update, the same as today.
- `shopify theme check` on scratch themes gives orig = 1 offense and new = 1 offense, the same pre-existing RemoteAsset warning on the postcard `<img>`. No new offenses.

## Findings (ranked)
1. **LOW, CONFIRMED: on mobile there is no "left/right".** The 2-column grid flows continuously across sizes, and each size has 5 tiles (odd). Neither layout puts in-stock on the left and sold on the right. Lines at 390 and 700 wide (`*` = sold):
   - before: `L-01* L-02* // L-03* L-04* // L-05 XL-01* // XL-02 XL-03 // XL-04* XL-05*`
   - after:  `L-05 L-01* // L-02* L-03* // L-04* XL-02 // XL-03 XL-01* // XL-04* XL-05*`

   The tile count per size is unchanged, so the size boundaries do not move: XL still starts at tile 16, column 2, as today. Nothing gets pushed into new positions; only who fills each slot changes. In-stock L/XL go from tiles 15/17/18 to 11/16/17. That is better, but on a phone it reads as "in-stock first within each size", not "sold on the right". Tell the owner this before he checks on his phone.
2. **LOW, PLAUSIBLE: positions now shift as shirts sell.** A shirt someone looked at can move columns after a sale. That is acceptable for named one-of-ones. Columns already did not mean "the same design" (header comment, lines 27-32).
3. **LOW, CONFIRMED: PDP prev/next stays on the hard-coded 01..05 order.** `snippets/ak-drop-product.liquid:29`. Example: from SL-L-05, which is now first in the L row, "previous" goes to L-04 (sold) and "next" goes to XL-01 (sold). This is not new: prev/next already walks through sold shirts and never matched the wall's left/right. I agree with main: leave it alone. Making it skip sold shirts or follow the wall would need product lookups on the PDP. That is a separate change, so ask the owner.
4. **LOW, CONFIRMED (risk is in the future, not now): empty placeholders go last.** If a shirt is deleted or archived (likely for sold one-of-ones if the owner tidies up), the row becomes `in-stock | sold | [invisible gap]`, so the sold shirts are no longer flush right. The alternative `in-stock | gap | sold` leaves a hole mid-row, which looks worse. Keep empties last. The gap is still needed: dropping it would pull the next size up into this row on desktop.
5. **INFO, CONFIRMED: whitespace and capture are safe under `display:contents`.** The renders have zero non-whitespace text nodes between grid items, and the captured tiles sit flush (`</a><a`) just as today. Each per-row buffer is reset before `<div class="akdw-row">`. If that reset were missing, rows would duplicate. That is the one real trap, and the code comment flags it.
6. **INFO, CONFIRMED: reading order and focus order match the visual order.** I tabbed through it in headless Chromium after the reorder: `S-01…S-05 M-01…M-05 [showcase slide] L-05 L-01 L-02 L-03 L-04 XL-02 XL-03 XL-01 XL-04 XL-05`. That is the reason to do this in Liquid. **Reject any CSS `order` or flex/grid reorder alternative**, because it would break WCAG 1.3.2 and 2.4.3. Pre-existing and out of scope: sold tiles are still focusable links with `aria-disabled`.
7. **INFO, CONFIRMED: the burst overhang and hover dissolve are unaffected.** The burst overhangs only to the left. Measured overlap onto the left neighbour is 0px at 1440, 700 and 390 before and after. Sold tiles keep their hover suppression, and in-stock tiles keep the lift and dissolve. Paint order still puts each burst above its left neighbour.
8. **INFO, CONFIRMED: the showcase pre-pass does not interact.** It runs its own S..XL / 01..05 loop and is identical in all 9 scenarios. It is still emitted after the `showcase_after` row (tested M and L). Its slide order equals the wall's in-stock order.
9. **DOC DRIFT, CONFIRMED.** `docs/superpowers/HANDOFF-supreme-leader-drop.md` §5 still says "Mobile is 4 horizontal size-tracks… overflow-x:auto scroller". The live CSS is a 2-column continuous grid (section lines 664-681). Fix this when docs are updated for this change, as AGENTS.md requires.

## All rows vs only L/XL
The owner literally wrote "Reorder The Sold Shirts To The End Of **Each Row** — Just Re-order The Large & XL Tee Rows". I read "Just" as "only L and XL need it right now". Today S and M have no sold shirts, so the generic version renders S/M byte-identically (verified). It differs only when S or M starts selling, and then "each row" applies. A row-name filter would also be an extra string to keep in sync with `size_order`.
**No setting.** A theme-editor toggle writes `templates/collection.json` on live (repo/live drift), adds schema surface, and isn't needed: rollback is a one-file push of the previous section. If the owner wants a toggle anyway, make it a "keep sold in place" checkbox, so that the value missing from collection.json means reorder ON. That follows the precedent in fragile-areas item (3).

## Recommended final diff — `sections/ak-drop-wall.liquid` only
(also saved as `review/reorder/proposed.diff`; full file `review/reorder/ak-drop-wall.new.liquid`)
```diff
@@ -23,6 +23,9 @@   (header comment)
   handle, never by collection sort order.
+  Within each row, in-stock shirts come first and sold shirts after (2026-10-09,
+  owner), each group in design_order; see the row loop. Do it in Liquid, never
+  with CSS `order`: that would split visual order from reading/focus order.
@@ -165,6 +168,16 @@
         {%- assign size = size | strip -%}
+        {%- comment -%}
+          SOLD TO THE END (2026-10-09, owner): each row is built into three
+          buffers and emitted in-stock, then sold, then empty placeholders. Stable:
+          each buffer keeps design_order. Server-side, so DOM order == visual order
+          == reading/focus order (no CSS `order`). Same single all_products lookup
+          per handle as before. Buffers MUST be reset per row.
+        {%- endcomment -%}
+        {%- assign akdw_open = '' -%}
+        {%- assign akdw_sold = '' -%}
+        {%- assign akdw_gap = '' -%}
         <div class="akdw-row" data-akdw-row="{{ size | downcase }}">
@@ -186,13 +199,17 @@
               {%- comment -%} keep the cell so the 5x4 grid never collapses {%- endcomment -%}
+              {%- capture akdw_tile -%}
               <span class="akdw-item akdw-item--empty" aria-hidden="true">
                 ...
               </span>
+              {%- endcapture -%}
+              {%- assign akdw_gap = akdw_gap | append: akdw_tile -%}
             {%- else -%}
               {%- assign front = p.images[0] -%}
               {%- assign back = p.images[1] -%}
+              {%- capture akdw_tile -%}
               <a
@@ -229,9 +246,16 @@
               </a>
+              {%- endcapture -%}
+              {%- if p.available -%}
+                {%- assign akdw_open = akdw_open | append: akdw_tile -%}
+              {%- else -%}
+                {%- assign akdw_sold = akdw_sold | append: akdw_tile -%}
+              {%- endif -%}
             {%- endif -%}
 
           {%- endfor -%}
+          {{- akdw_open -}}{{- akdw_sold -}}{{- akdw_gap -}}
         </div>
@@ -875,7 +899,7 @@   (schema info text only, optional; no setting added/changed)
-      "info": "Comma separated, one column per entry.",
+      "info": "Comma separated. Order within each row: in-stock shirts first, then sold, each in this order.",
```
Push: `--only sections/ak-drop-wall.liquid` (owner pastes; no new asset; not settings_data). Afterwards, per AGENTS.md:
add a fragile-areas item (8) "row partition is in Liquid; reset buffers per row; never CSS order", and fix the §5 doc drift.

## Test evidence — python-liquid 2.3.4 render (`reorder/scripts/harness.py`, outputs `reorder/renders/*.html`, `summary.txt`)
Stubs: `image_url` / `image_tag` / `asset_url` filters, `{% style %}` mapped to `<style>`, `{% schema %}` stripped, `render 'ak-drop-chrome'` rendered as empty.
**Engine gap patched:** python-liquid evaluates `nil == blank` as FALSE, but Shopify evaluates it as TRUE. The live missing-product check `p.title == blank` relies on the Shopify behaviour, so the harness patches `_eq` to match. Without the patch, a missing product renders as a broken `<a href="">` tile, in BOTH the original and the new code. That was a harness artefact, not a bug.
Every scenario: tiles=20, stray text nodes=0, tile-HTML multiset identical to the original, showcase identical, everything outside the grid identical.
| scenario | L row (new) | XL row (new) | other | showcase |
|---|---|---|---|---|
| today | L-05 \| L-01* L-02* L-03* L-04* | XL-02 XL-03 \| XL-01* XL-04* XL-05* | S, M unchanged | 13 slides, after M |
| all in stock | 01..05 | 01..05 | identical to orig | 20, after M |
| all sold | 01*..05* | 01*..05* | identical to orig | none (0 blocks) |
| L row 0 in stock | L-01*..L-05* | XL-02 XL-03 \| sold | — | 12, after M |
| missing in-stock XL-03 | as today | XL-02 \| XL-01* XL-04* XL-05* \| [empty] | — | 12, after M |
| missing sold L-02 | L-05 \| L-01* L-03* L-04* \| [empty] | as today | — | 13 |
| S partial (S-02, S-04 sold) | as today | as today | S: S-01 S-03 S-05 \| S-02* S-04* | 11, after M |
| title fallback (L-05 handle renamed) | L-05 first, href `/products/sl-l-05-1` | as today | — | 13 |
| showcase_after = L | as today | as today | showcase sits between L and XL | 13 |

## Screenshots (own headless Chromium on LIVE amerikid.ca + client-side DOM partition mock; `reorder/shots/`)
- `desktop-1440x900-{before,after}-L-XL.png`
- `mobile-390x844-{before,after}-L-XL.png`, `mobile-390x844-{before,after}-wall-full.png`
- `phablet-700x900-{before,after}-L-XL.png`
- `*-measure.json`: per-tile column, line, burst overlap and tab order. `mock-summary.txt` is the text summary.
Desktop after: the L row reads L-05, then 4 sold; the XL row reads XL-02 XL-03, then 3 sold. Clean, with no layout shift and scrollWidth equal to the viewport at every size.

## Owner questions
1. When S or M shirts start selling, should they also move right? Recommended: yes, "each row".
2. On phones the wall is 2 columns flowing across sizes, so "far right" becomes "after the in-stock ones of that size". OK?
3. Should PDP prev/next follow the wall order or skip sold shirts? Recommended: not now.
4. Do you archive or delete sold shirts? If so, they will leave an invisible gap at the row end, and the burst disappears for that shirt.
