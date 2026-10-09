# Design brief — Drop wall + PDP updates (2026-10-09) — FOR ADVERSARIAL REVIEW

Repo: /Users/declangainey/Desktop/amerikid-shopify-theme-working (branch feature/drop-wall-refresh).
LIVE theme 188605497624 (repo == live, verified byte-identical today). Storefront: https://amerikid.ca
READ FIRST: AGENTS.md, docs/known-fragile-areas.md (top "Drop wall refresh" block), docs/qa/2026-09-26-drop-refresh/README.md,
docs/superpowers/HANDOFF-supreme-leader-drop.md §4-5.

HARD RULES FOR REVIEWERS: READ-ONLY. Do NOT edit any file in the repo. Do NOT run any `shopify theme push/dev/publish/delete`.
You MAY: read files, curl the public storefront, run headless Playwright (python `playwright` is installed; launch your OWN
headless browser — never attach to or kill the user's Chrome), inject JS/CSS client-side into your own headless page to MOCK
options, save screenshots/notes ONLY under the scratchpad `review/` folder given in your prompt.

Live data (2026-10-09): 20 one-of-one SL shirts, $60, 3 images each, NO product tags, no product_type.
In stock (13): sl-s-01..05, sl-m-01..05, sl-l-05, sl-xl-02, sl-xl-03. Sold (7): sl-l-01..04, sl-xl-01, sl-xl-04, sl-xl-05.
SL-L-01 is a LONG SLEEVE (per wall comment). Each product description's FIRST line is "SIZE <X> .:. NUMBER N IN RUN OF M .:."
and ak-drop-product.liquid styles `.product__description > *:first-child` as the size header.

---------------------------------------------------------------------------------------------------
## Owner requests (verbatim)
1. "The Single / Alternating Product Shot Is Dope but Takes Up Too Much Space In The Middle.
   - We Need To Either Remove Some of The Space Above & Below It, or See How It Looks At The Top of The Page Right Under
     The Two Banners.
   - Let's Also Speed Up The Rate That The Shirts Switch At, Make It Faster."
2. "Reorder The Sold Shirts To The End Of Each Row — Just Re-order The Large & XL Tee Rows So The In Stock Ones Are on The
   Left Side, and Anything Sold Is On The Far Right of The Row"
3. "for every product page on the current live theme: This Is The Sizing Chart, We Will Put This Into The Product
   Description For Every Shirt We Have On These New Blanks So All #SL Tees" + chart image
   (/Users/declangainey/Desktop/AMERIKID MEASUREMENTS GUIDE.jpeg, 2400x2400 JPG, 761KB, black ground; title
   "YOUR AMERIKID T-SHIRT"; PIT TO PIT / LENGTH: S 18.5/27, M 20/28, L 21/30, XL 22.5/31 inches;
   footer "WILL CONFORM TO THESE MEASUREMENTS AFTER FIRST WASH").

---------------------------------------------------------------------------------------------------
## 1. Showcase — main's analysis and proposed design

Current code: sections/ak-drop-wall.liquid. `.akdw-show` is a grid item (grid-column:1/-1) emitted after the row whose size
== showcase_after (default M). Vertical budget at 1440x900 (computed, VERIFY by measurement):
  grid row-gap above  clamp(14px,2.1vw,34px)  ≈ 30px
  padding-block top   clamp(10px,2.4vw,40px)  ≈ 35px
  shot (square)       min(100%,68vh,760px)    ≈ 612px   ← object-fit:contain; product photo may itself carry empty margin
  name gap + name                             ≈ 17 + 35px
  padding-block bottom                        ≈ 35px
  grid row-gap below                          ≈ 30px
  TOTAL ≈ 790px ≈ 88% of a 900px viewport.
Timing: data-seconds from setting showcase_seconds (schema range 3–10, default 4; collection.json sets NO value so the
default applies). JS: `Math.max(3, parseInt(...)||4)*1000`; slide transition .8s cubic-bezier.

Option A ("tighten in place", main's lean): keep it after M; remove the padding-block, cancel the grid gaps, shrink the shot
  to ~min(100%,52vh,600px), and if the product photos have built-in empty margin, crop the frame (e.g. aspect-ratio 4/3 or 5/4
  with object-fit:cover centred) so the shirt fills it. Target: block ≤ ~55% of a 900px viewport (~500px).
Option B ("top, under the two banners"): render the showcase between the red band and the wall (outside the grid). Implement
  as `showcase_after` accepting `TOP` (or a new select). Risk main sees: banner 360 + band ~176 = 536px at 1440x900, so the
  showcase starts at 536px and row 1 is pushed ~800px further down — this directly reverses the 2026-09-26 owner goal
  ("smaller [banner] so more of the top row of shirts show"). A top variant would likely need to be much shorter (e.g. a
  ~40vh strip) to be viable. Main proposes delivering MOCK SCREENSHOTS of A and B (desktop 1440x900 + mobile 390x844) so the
  owner picks, rather than shipping B blind.
Speed: 4s → 2.5s per shirt (owner: "faster"), and transition .8s → ~.55s so the shirt is not moving ~1/3 of its dwell.
  Requires: schema range min lowered (e.g. 1.5–10 step 0.5) AND schema default changed AND JS floor lowered + parseFloat.
  Open: is 2.5s right? 2s? Does a faster carousel raise motion/a11y concerns (WCAG 2.2.2 pause for >5s auto-motion; there is
  no visible pause control; keyboard focus + reduced motion + offscreen + hidden tab already hold it)?

## 2. Sold shirts to the end of each row — main's proposed design
Generic, dynamic, stable partition for EVERY row (owner named L and XL; S and M are fully in stock today so the result is
identical now, and it stays correct as more sell): in the single existing per-row loop, `capture` in-stock tiles into one
string and sold tiles into another, then output in-stock, then sold, then empty placeholders. Within each group keep the
design_order (01..05). One all_products lookup per handle — unchanged count (20 unique, the documented cap).
Today's result: L row = L-05 | L-01 L-02 L-03 L-04 (sold). XL row = XL-02 XL-03 | XL-01 XL-04 XL-05 (sold).
Mobile (2 stationary columns, row-major continuous across sizes) keeps working; order within the size block changes.
Open: should PDP prev/next (hard-coded sl-s-01..sl-xl-05 list in snippets/ak-drop-product.liquid) follow the new wall order?
Main's lean: no (out of scope), but check for a jarring mismatch.

## 3. Size chart on every SL PDP — main's proposed design
Recommended (C1): theme-level, data-free.
  - New asset `assets/ak-size-chart.jpg` (resized/optimised from the 2400px source, e.g. 1200x1200 ≲150KB).
  - New snippet `snippets/ak-drop-size-chart.liquid`: the image (lazy, width/height set, full text alt or a visually-hidden
    HTML table with the same measurements) + small scoped CSS.
  - Rendered from a NEW `custom_liquid` block in templates/product.json main-product block_order directly AFTER
    `description`, Liquid-gated `{% if product.handle starts with 'sl-' %}` (Liquid has no starts_with: use
    `product.handle | slice: 0, 3 == 'sl-'`, same as ak-drop-product). product.json is shared by EVERY product → gate.
  - Push order: asset + snippet first, then product.json in a separate command (two-stage rule). Freshness-check live
    product.json right before push (Admin edits could have changed it).
Alternative (C2): owner pastes the image into all 20 product descriptions in Shopify Admin (literally "into the product
  description"). No code; but 20 manual edits, repeated for every future shirt, image text not accessible unless alt set.
Alternative (C3): no template change — render from snippets/ak-drop-product.liquid (already sl- gated, runs BEFORE main) and
  JS-move it after .product__description. Main thinks this is fragile.
Open: future shirts "on these new blanks" may not use the sl- prefix — gate by prefix OR a product tag (e.g. `size-chart-tee`)?
Open: SL-L-01 is a long sleeve — does a "T-SHIRT" chart belong on it?
Open: inline visible vs. collapsible "Size chart" row; mobile size (390px wide square ≈ 370px tall is fine?).
