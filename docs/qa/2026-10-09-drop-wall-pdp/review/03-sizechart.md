# 03: Size chart on SL PDPs (adversarial review)

Reviewer was read-only. No repo edits. No push, dev or publish. One read-only `shopify theme pull --only` into scratch.
Artifacts are in `review/sizechart/`.

## Verdict
**C1 holds up, with three amendments.** The main design (custom_liquid block after `description`, `sl-` gate, two-stage push) is sound. Mocks show no collision with the size header, the sticky column, the media modal or horizontal overflow. Three changes are needed:
1. **(HIGH) The gate needs a per-product opt-out.** Not all 20 SL pieces look like the same blank (see F1).
2. **Render the gate and markup from a snippet.** Use a `visually-hidden` HTML table as the text alternative, and add `quick-add-hidden`.
3. **Ship one 1200px asset.** Not 1600. Do not rely on `image_url` for a theme asset.

## Verified facts (sources)
| # | Fact | Status | Source |
|---|---|---|---|
| V1 | main-product schema declares a `custom_liquid` block (`sections/main-product.liquid:1858`). It renders raw `{{ block.settings.custom_liquid }}` (L690-691) with no wrapper and no `quick-add-hidden`. | CONFIRMED | repo |
| V2 | `description` renders only `if product.description != blank` (L674-679) and carries `quick-add-hidden`. The new block renders on its own, even when the description is empty. | CONFIRMED | repo |
| V3 | Current block_order: title, price, variant_picker, quantity_selector, buy_buttons, **description**, share. The chart lands between the description and Share. | CONFIRMED | `templates/product.json` |
| V4 | Liquid settings can use template objects (`product`) and standard tags. `render` is allowed; the live `custom_liquid_akpdp` already does `{% render 'ak-drop-product' %}`. They cannot use `section`, `layout`, `content_for_*`, `stylesheet`, `javascript` or `schema`. Content limit is 50 KB. | CONFIRMED | shopify.dev input-settings + architecture/limits |
| V5 | JSON template uploads are validated: a block type must be declared in the section schema (JSONMissingBlock). `custom_liquid` is declared. Theme Check passes on the proposed `product.json` and snippet. | CONFIRMED | shopify.dev theme-check json-missing-block; `validate_theme` run on `sizechart/proposed-theme` |
| V6 | A render of a **missing snippet is not caught at template upload**. It is a runtime Liquid error. Because the gate is inside the snippet, pushing `product.json` before the snippet would print an error on **every** default-template product (38 products). Push order is mandatory. | PLAUSIBLE (standard Liquid runtime behaviour; not reproduced on live) | |
| V7 | Docs say `asset_url` theme images are "served as-is, not resizable", and `asset_url \| image_tag` is unsupported. **Empirically**, the CDN still format-negotiates and resizes theme assets: `ak-drop-cover-1.jpg` served `image/webp` 226 KB to an `Accept: webp` request; `&width=400` returned `image/avif` 18 KB; `_400x` returned `image/jpeg` 24 KB. Treat format negotiation as a bonus. Do not build srcset on the undocumented `&width=`. `asset_img_url` (legacy, named sizes) exists. | CONFIRMED (both) | shopify.dev use-shopify-cdn, asset_img_url; curl against live CDN |
| V8 | Responsive images by the documented route mean uploading to Admin Files and using `images['name.jpg'] \| image_url \| image_tag`. This adds an owner Admin step and a filename dependency. Not worth it for one 1200px image. | CONFIRMED | shopify.dev objects/images |
| V9 | Asset file limit is 20 MB; JSON template limit is 512 KB. | CONFIRMED | theme-check MaxFileSize; architecture/limits |
| V10 | `product.json` is the default template for every product with no suffix. All 20 SL products have `template_suffix: ''`. 7 product templates use `main-product`, so editing `main-product.liquid` would reach all 7. The block approach reaches only `product.json`. | CONFIRMED | `/products/<h>.json`; grep |
| V11 | Variant change (`assets/product-info.js:180-193`) swaps only price, Sku, Inventory, Volume and Price-Per-Item. A whole `product-info` viewTransition happens only on product swap. The chart is never re-rendered or lost. SL products have one variant anyway. | CONFIRMED | repo |
| V12 | Quick-add is `none` in every template and schema default, so no surface uses it today. Still add `quick-add-hidden`: quick-add.js would pull the whole `product-info` into the modal. | CONFIRMED | grep |
| V13 | Live == repo for `templates/product.json`, `sections/main-product.liquid` and `snippets/ak-drop-product.liquid` at review time (`cmp`). | CONFIRMED | `sizechart/livepull/` |
| V14 | Only the 20 SL handles start with `sl-` among the 38 public products. Non-SL tees exist (`flag-tee`, `candyfacts-label-t-shirt`). Today the gate is exact. | CONFIRMED | `/products.json` |

## Findings (ranked)
**F1 HIGH (CONFIRMED visually; PLAUSIBLE that the measurements are wrong).** "Every shirt on these new blanks so all #SL tees" assumes all 20 share one blank, but the contact sheet (`sizechart/sl-contact-sheet.png`) shows at least three different garments:
- **SL-L-01** is a long sleeve (sold).
- **SL-L-05** is a cap-sleeve, cropped/boxy cut. It is **in stock**.
- **SL-XL-02** is a **black** tee. It is **in stock**.

The other 17 look like one white crew-neck blank. A "T-SHIRT: L = 21 in pit / 30 in length" chart on the in-stock L-05 is a sizing claim that may be false on a one-of-one, which risks returns. Fix: an opt-out tag `no-size-chart` (zero Admin work by default; the owner tags any exceptions). Ask the owner before launch.

**F2 MED (CONFIRMED).** The size "header" styling covers the whole description, not the first line. Each description is ONE `<p>` with `<br><br>`, so `.product__description > *:first-child` (bold, 0.14em tracking, bottom border) applies to all of it. This is pre-existing, not caused by the chart. It matters for **C2**:
- If the owner pastes the image at the top of the description, it becomes `:first-child` and takes the header border and padding.
- Pasted inside the existing `<p>`, it sits above the hairline.
- With C1 the chart is outside `.product__description`. Measured: first-child stays `font-weight:700`, and the chart is never first child at 1440 or 390.

**F3 MED (CONFIRMED).** Push order and freshness. Stage 1 is `--only assets/ak-size-chart.jpg --only snippets/ak-drop-size-chart.liquid`. Stage 2, separately, is `--only templates/product.json`, run immediately after a fresh read-only pull plus `cmp` of live `product.json`. The Admin theme editor or apps can rewrite it (it carries 3 disabled legacy sections). If live differs, merge into the live copy, never the repo copy. The owner runs both pushes (`--allow-live` is guard-blocked for agents).

**F4 MED (CONFIRMED).** The inline chart is visually loud. At 1440 it adds 490px to the info column (603 → about 1100px; the viewport is 900). Its top edge is at y=676, so the top ~220px is above the fold. It ends almost exactly level with the gallery bottom, and the sticky column still reaches its bottom (at scrollY 1200 the info top is -419, so the bottom is about 680 and visible). The red/white/blue title competes with the product photo on a deliberately quiet black page.

The collapsible variant adds only 63px and loads 0 bytes until opened (`imgLoaded:false` while closed). The owner literally said "put this into the product description", so default to **inline** and offer the disclosure mock as the alternative.

**F5 MED (CONFIRMED).** Accessibility. Image-only text fails WCAG 1.1.1 / 1.4.5. A long `alt` with 8 numbers is poor (screen readers read it as one run-on string; ~125 chars is the practical ceiling). Use a short alt plus the same data in a `<table>` with caption and `th scope` inside Dawn's `.visually-hidden` wrapper (`assets/base.css:198`).

Wrap the table in a `div`, because a table ignores `width:1px` and can create overflow. Measured: wrapper 1x1, no horizontal overflow at 390 or 1440.

**F6 LOW (CONFIRMED).** Page weight and LCP.
- Source 2400px JPG: 743 KB.
- **1200px q80 progressive JPG: 151 KB.** This covers 490 css px @2x (desktop column) and 357 @3x (phones), so 1600 adds about 65 KB for nothing.
- 16-colour PNG: 63 KB, visually identical (`compare-p16-vs-jpg80.png`).
- WebP 1200: 61 KB. The CDN should negotiate WebP/AVIF from the JPG per V7, so the on-wire size is likely about 60 KB (estimate).

LCP stays the product photo. Use `loading=lazy`, `decoding=async`, `fetchpriority=low`, and explicit width/height (no CLS). At 1440 the chart top is in the first viewport, so lazy will not defer it there; fetchpriority=low covers that.

**F7 LOW (CONFIRMED).** Media modal still covers the page (z-index 100000, moved to `<body>`, chart hidden under it) at 1440 and 390 (`*_inline_modal.png`). The `.ak-size-chart` class is unique, so the unscoped 2-rule `{% style %}` cannot leak. It only ships when the gate is true.

**F8 LOW (PLAUSIBLE).** Units and copy:
- amerikid.ca is a Canadian domain, but the chart is inches-only. The hidden table could add cm. Owner call; do not alter the art.
- The chart says "T-SHIRT" on a long sleeve (L-01; sold, so low impact if opted out).
- "Will conform to these measurements after first wash" implies pre-wash garments are larger. Shoppers may misread it as "will shrink to fit".

**F9 LOW.** SEO: neutral. The hidden table adds ~25 identical words to 20 pages, and theme images are not in product feeds. C2 would put the image into `body_html`, which feeds Shopify/Meta catalogs and any app that reads the description.

**F10 INFO.** Not needed on the wall or in the cart. One-of-one size is already the first line of the description and is the tile's row. Possible follow-up: a "SIZE CHART" text link on the wall that anchors to the PDP. Out of scope.

## Approaches compared
- **C1 (recommended, amended):** a theme block plus snippet, one asset, zero Admin work. It touches the shared `product.json` (default template only). Reverting is one file.
- **C2 (Admin paste x20):** zero code, but:
  - 20 manual edits now and on every new shirt.
  - Collides with the first-child header (F2).
  - No text alternative unless alt text is set by hand.
  - Leaks into catalog feeds.
  - Inconsistent placement.
  - Reject, unless the owner wants per-shirt control.
- **C3 (render in `ak-drop-product`, JS-move):** that section renders BEFORE `main`, so it shows nothing without JS, causes a flash or CLS while the move runs, and adds a DOM-order dependency on a Dawn class. Reject.
- **C4 (edit `main-product.liquid` description branch):** reaches all 7 templates in a 3175-line fragile file. Reject.
- **Gate:** prefix, plus opt-out tag `no-size-chart`, plus opt-in tag `size-chart` for future non-`sl-` shirts on the same blanks. Today no tags exist, so the result equals a pure prefix gate. A metafield would also work but needs a definition setup. Tags can be bulk-edited in Admin.

## Proposed files (NOT applied; copies in `sizechart/proposed-theme/`, Theme Check PASS)
**1. `assets/ak-size-chart.jpg`**: `sizechart/ak-size-chart-1200-q80.jpg` (1200x1200, 151 KB, progressive).

**2. `snippets/ak-drop-size-chart.liquid`** (new):
```liquid
{% doc %}
  Size chart for SL tees, under the description. Rendered from the `size_chart`
  custom_liquid block in templates/product.json (shared by EVERY product), so the gate
  lives here: handle starts 'sl-' unless tagged 'no-size-chart'; OR tagged 'size-chart'.
  Push this snippet + assets/ak-size-chart.jpg BEFORE templates/product.json.
  @param {product} product - The product being viewed
  @example
    {% render 'ak-drop-size-chart', product: product %}
{% enddoc %}
{%- liquid
  assign ak_show_size_chart = false
  assign ak_handle_prefix = product.handle | slice: 0, 3
  if ak_handle_prefix == 'sl-'
    assign ak_show_size_chart = true
  endif
  if product.tags contains 'no-size-chart'
    assign ak_show_size_chart = false
  endif
  if product.tags contains 'size-chart'
    assign ak_show_size_chart = true
  endif
-%}
{%- if ak_show_size_chart -%}
  <div class="ak-size-chart quick-add-hidden">
    <img class="ak-size-chart__img" src="{{ 'ak-size-chart.jpg' | asset_url }}"
      width="1200" height="1200" loading="lazy" decoding="async" fetchpriority="low"
      alt="AmeriKid T-shirt size chart">
    <div class="visually-hidden">
      <table>
        <caption>AmeriKid T-shirt measurements in inches. Shirts conform to these measurements after the first wash.</caption>
        <thead><tr><th scope="col">Size</th><th scope="col">Pit to pit</th><th scope="col">Length</th></tr></thead>
        <tbody>
          <tr><th scope="row">Small</th><td>18.5</td><td>27</td></tr>
          <tr><th scope="row">Medium</th><td>20</td><td>28</td></tr>
          <tr><th scope="row">Large</th><td>21</td><td>30</td></tr>
          <tr><th scope="row">XL</th><td>22.5</td><td>31</td></tr>
        </tbody>
      </table>
    </div>
  </div>
  {%- style -%}
    .ak-size-chart{ margin-top:2.4rem; }
    .ak-size-chart__img{ display:block;width:100%;max-width:56rem;height:auto; }
  {%- endstyle -%}
{%- endif -%}
```
(No border-top: the description already ends in a hairline. The first mock had a double rule.)

**3. `templates/product.json`** (diff, `sizechart/product.json.diff`):
```diff
@@ blocks
         "description": { "type": "description", "settings": {} },
+        "size_chart": {
+          "type": "custom_liquid",
+          "settings": { "custom_liquid": "{% render 'ak-drop-size-chart', product: product %}" }
+        },
@@ block_order
         "description",
+        "size_chart",
         "share"
```
**Push (owner):**
1. `--only assets/ak-size-chart.jpg --only snippets/ak-drop-size-chart.liquid`.
2. Read-only pull of `templates/product.json` to scratch, then `cmp`.
3. `--only templates/product.json`.

**Rollback:** re-push the previous `product.json` (`git show HEAD~:templates/product.json`). The orphaned snippet and asset are inert under `--nodelete`.

**QA after push:**
- sl-l-05, sl-s-01, sl-xl-02 at 1440 and 390: chart under the description, no overflow.
- `flag-tee`: no `.ak-size-chart` in the HTML (curl + grep).
- A product with an empty description still works.
- Then update the `docs/` files per AGENTS.md.

## Mockups (`review/sizechart/`)
- **Final proposal:** `FINAL_{sl-l-05,sl-s-01}_{1440,390}_{viewport,full}.png`.
- **Option variants:** `{sl-l-05,sl-s-01,sl-l-01}_{1440,390}_{baseline,inline,details-closed,details-open}_{full,info}.png`, plus `_scrolled1200.png` (desktop).
- **Gate check:** `flag-tee_{1440,390}_none_full.png` (non-SL notebook page, untouched).
- **Modal:** `sl-l-05_{1440,390}_inline_modal.png`.
- **Garment evidence:** `sl-contact-sheet.png`.
- **Legibility:** `legibility-370px-1x.png` (legible at 1x; the footer line is smallest but readable).
- **Data:** `mock-results.json`.
- **Scripts:** `mock.py`, `final.py`, `modal.py`.

## Owner questions
1. **Are SL-L-01 (long sleeve), SL-L-05 (cap-sleeve crop) and SL-XL-02 (black tee) on the same blank as the other 17?** If not, tag them `no-size-chart`. L-05 and XL-02 are in stock.
2. Inline (as mocked, about 490px on desktop) or a collapsible "SIZE CHART" row (63px closed)?
3. Should future non-`sl-` shirts on these blanks get it? If yes, tag them `size-chart`.
4. Do you want centimetres in the accessible table too (Canadian store)? The image itself stays as supplied.
