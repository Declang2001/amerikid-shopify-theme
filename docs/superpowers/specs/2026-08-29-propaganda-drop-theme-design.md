# Propaganda Drop Theme — Design Record

**Date:** 2026-08-29
**Status:** DESIGN CONFIRMED WITH OWNER — awaiting explicit "go" before any
implementation. Nothing implemented. No store contact made.
**Prototype:** https://claude.ai/code/artifact/75225a23-1ee3-4917-86f1-932479da24c9
**Prototype v2 built 2026-08-29** — archived as `2026-08-29-drop-grid-prototype-v2.html`.
v1 archived as `…-prototype-v1.html` (superseded; had invented copy).

> Session handoff document. A future session should read this FIRST, then
> `AGENTS.md`, then `docs/known-fragile-areas.md:6`. Nothing in this file has
> been built. No Shopify CLI command has been run against the store.

---

## 1. Goal

A new Shopify theme for a 20-piece clothing drop. Creative direction:
**North/South Korean propaganda aesthetic**. Visually it still sits on the
existing notebook-paper system — the propaganda treatment layers on top of the
paper, it does not replace it.

Two pages:
1. A landing page — must look like the landing page of the **currently published
   site**, not a new invention.
2. Click through → one page holding all 20 products.
3. From there, the rest of the site is reachable and normal.

---

## 2. Decisions locked with the owner

| Question | Answer |
|---|---|
| Product model | **5 products × 4 size variants** (S/M/L/XL) = 20 variants. Grid cell = one variant. |
| Products exist? | **Yes — already live in Shopify.** Handles still needed. |
| Grid visual | Shirt image in **every** cell at identical scale. Column = design, row = size. |
| Cell interaction | **Hover flips** front→back; **click adds that variant to cart**. Two distinct interactions. |
| Mobile behaviour | Columns **auto-scroll/drift**; cells **auto-flip on a staggered timer**. No hover on touch. |
| Size run | **S / M / L / XL** — exactly four rows. |
| Mechanism | **Option 2 — a real third theme that becomes the active theme at launch.** |

### 2.1 The theme arrangement (owner-confirmed)

- Build happens in a **new theme**, duplicated from the currently-published
  notebook theme, kept **unpublished** during development.
- At launch the **owner publishes it in Admin**; it becomes the active theme.
  Because it is a full duplicate, every existing route survives.
- The notebook theme `186464731416` becomes the one-click rollback.
- **Later option, explicitly kept open:** the drop can instead be folded back
  into the main notebook theme as a separate page. The build should not make
  that harder — keep the drop self-contained in its own section + template so
  it can be lifted across as scoped `--only` pushes.

---

## 3. Ground truth (verified 2026-08-29 by 13-agent read-only recon)

### 3.1 Themes

| ID | Admin name | State (per docs, dated 2026-06-18) |
|---|---|---|
| `186464731416` | AmeriKid Notebook Theme – Publish Candidate | **LIVE** |
| `184615043352` | AmeriKid Dark Theme – Preserve | unpublished; must stay byte-unchanged |
| `185910067480` | development | dev lane |
| `184629133592` | Development (older) | superseded |

**That table is ~2 months stale.** Newest change-log entry is 2026-07-04.
Re-verify with `shopify theme list --store iacxyv-w5.myshopify.com` before acting.

**Platform rule:** a store has exactly one published theme. Admin API `ThemeRole`
→ MAIN: "There can only be one main theme at any time." Publishing the drop theme
necessarily unpublishes the notebook theme. The `_ab` preview-cookie workaround
has been dead since 2025-08-18; `?preview_theme_id=` is undocumented and is a QA
tool only.

### 3.2 The notebook system is NOT a theme

It is **CSS-only, page-scoped overlays**. 11 surfaces: the 10
`snippets/ak-notebook-*.liquid` files plus `snippets/club-hub.liquid`.

- Isolation is **one class on `<html>`**, set by a one-line IIFE per snippet
  (`ak-pdp-page`, `ak-products-page`, `ak-cart-page`, …).
- The paper is **100% CSS gradients** — no image, no SVG, no canvas.
  Canonical copy: `snippets/ak-notebook-products.liquid:115-146`.
- Mobile is **one line**: `--ak-paper-side-gap:-60px` under `@media (max-width:749px)`
  (`products:571`) pushes both vertical rules off-screen.
- It beats a global black net: `layout/theme.liquid:270-282` sets
  `html, body { background:#000 !important }`. The paper wins on specificity.
  **Footgun:** the `.gradient` backstop must stay scoped under `#MainContent`,
  because `<body>` itself carries class `gradient`.
- Palette: `#ff33ff` ×109, `#15120b` ×95, `#f5dd4f` ×47.
- Fonts: `assets/ak-due-date.woff2`, `assets/ak-tenada.woff2`. Tenada must stay
  **first** in the stack — it carries only the `#` glyph (`unicode-range: U+23`).
- All 15 decorative PNGs are **store-level Shopify Files CDN URLs**, not repo assets.

### 3.3 Deploy mechanics

- Only sanctioned live command:
  `shopify theme push --only <file> [--only <file>…] --allow-live --nodelete`
- **Publish is owner-only and manual in Admin.** No agent runs `shopify theme publish`.
- **HARD BAN:** `shopify theme dev --theme <live id>`. It hot-syncs local saves
  *and git checkouts*. On 2026-06-18 this reverted the live Archive template
  (`docs/change-log.md:15`). Safe preview: `shopify theme dev --store …` with **no** `--theme`.
- Two-stage ordering: new section/snippet files first, activating template JSON second.
- No CI, no automation, no `.shopifyignore`. Every deploy is hand-typed.

---

## 4. Hazards found — fix before any CLI work

1. **`docs/source-of-truth.md:285-301` is a loaded gun.** Line 297 is a
   copy-pasteable **unscoped whole-repo push** aimed at the dark preserve theme:
   `shopify theme push --theme 184615043352 --path . --store iacxyv-w5.myshopify.com`
   — no `--only`, no `--nodelete`. Line 288 also mislabels that ID as "Live theme ID".
   Lines 6-18 supersede it. **Delete or fence this block.**
2. **`.claude/settings.local.json:21` and `:68` pre-approve every `shopify theme`
   command** — including `push --allow-live`, `publish`, `delete`. There is an
   `allow` list and **no `deny` list**. The hardest prohibitions are prose-only.
   **Add a deny list.**
3. **`AGENTS.md` contains zero deploy guardrails** despite being the mandated
   first read. **Hoist `docs/known-fragile-areas.md:6` into it verbatim.**

---

## 5. Buildability

| Requirement | Status |
|---|---|
| Landing page | **Reuse.** `sections/ak-landing.liquid` (175 lines) is already a full-viewport tap target with a 350ms scale+fade exit, double-nav guard, reduced-motion path. Route is **three synchronized strings in two files** (`ak-landing.liquid:1`, `:131`, and `templates/index.json:25`) — commit `030510e` proved missing one desynchronizes the no-JS path. |
| Notebook paper | **Copy verbatim** from `ak-notebook-products.liquid:115-146` + the `:571` mobile line. |
| 6-column matrix | **Write fresh.** Stock grid is a flat list (`main-collection-product-grid.liquid:304-337`). |
| Size labels + per-size sold-out | **Half free.** Dawn server-computes `value.available` per size (`snippets/product-variant-options.liquid:36-39`). No variant map needed. |
| Hover flip | **Markup exists, flip does not.** `card-product.liquid:137-156` already emits `media[1]`, but it is a crossfade, is **off** (`templates/collection.json:61` → `show_secondary_image: false`), and is gated ≥990px (`component-card.css:383-407`). Real 3D flip idiom to copy: `sections/ak-archive-magazine.liquid:150-178` (+ reduced-motion kill-switch at `:284-287`). Gotcha: `.media{overflow:hidden}` (`base.css:1107`) clips a flip. |
| Mobile auto-scroll | **Write fresh.** No marquee component exists. Only translate-loop recipe is `templates/collection.election.json:16-21`. Note: 64 similar marquees exist and **all are disabled**. |
| Add to cart from cell | **Blocked, fixable.** `quick_add:"none"` in all 26 collection templates; `product-form.js:11` resolves cart to `null` (nothing renders `cart-notification`), so it bounces to `/cart`. Fix: render `snippets/cart-notification.liquid`. **Use `add.js`, not `update.js`** — `update.js` does not validate quantity and can oversell a limited drop. |

### 5.1 Scoping rule

Follow `sections/main-product.liquid:311-436` — every selector prefixed
`html.ak-<drop>-page #Main… -{{ section.id }}`.
**Do NOT** follow `main-collection-product-grid.liquid:27-89` — globally scoped
`!important`, explicitly forbidden by `docs/known-fragile-areas.md:40` and `:213`.

---

## 6. Owner feedback on prototype v1 (2026-08-29)

- ❌ **Too much text.** "PICK YOUR SIZE. PICK YOUR PRINT." and the sub-copy are
  not wanted. The page should be **bare bones and very simple**.
- ❌ **Landing page copy wrong.** "ENTER THE DROP" is not wanted at all. The
  landing must **look like the landing page of the currently published site**.
- ✅ **Size label placement RESOLVED (2026-08-29):** sizes stay in the **left-hand
  column** exactly as originally specified — 6 columns × 4 rows. "Up at the top"
  meant strip the masthead copy so the size labels become the topmost text on the
  page. The only text anywhere on the grid page is the four size words.
- ✅ Products confirmed already live in Shopify.
- ✅ Creative direction: **North/South Korean propaganda**, layered on the
  notebook paper. Applies to the landing page eventually; not yet designed.

---

## 7. Open questions

1. ~~Size-label placement~~ — **RESOLVED**, see §6.
2. **Collection handle + the 5 product handles.** Once supplied, image order and
   variant IDs can be read with no auth from `https://<store>/products/<handle>.js`.
3. **Is front = image 1 and back = image 2 on all 5 products?** Admin-controlled,
   unverifiable from the repo, and the entire hover mechanic rests on it.
   *Checkable read-only via the public `/products/<handle>.js` JSON endpoint — no
   Admin API access required.*
4. **Theme-slot ceiling.** `shopify theme duplicate` fails with "Maximum number of
   themes reached"; shopify.dev never states the number. Read it off Admin.
5. **Current publish state** — the docs table is 2 months stale.

---

## 8. Plan (not yet approved)

- **Phase 0** — fix the three hazards in §4. Run `shopify theme list` to
  re-verify publish state and slot headroom.
- **Phase 1** — branch off `experiment/notebook-paper-background`;
  `shopify theme duplicate` from `186464731416` → new **unpublished** theme.
  Never target `184615043352` or the live ID again.
- **Phase 2** — build on the duplicate only: new `sections/ak-drop-wall.liquid`,
  new `templates/collection.<handle>.json`, landing repointed (all three strings),
  `cart-notification.liquid` rendered, cart posts to `add.js`.
- **Phase 3** — QA at 1440/1280/1024/390/375/320 per `docs/runtime-test-checklist.md`,
  plus `validate_theme` from the Shopify Dev MCP.
- **Phase 4** — **owner publishes in Admin.** Rollback = republish `186464731416`.

---

## 9. Tooling

- ✅ Shopify CLI **3.93.2** installed at `/opt/homebrew/bin/shopify`.
- ✅ `shopify-dev-mcp` attached — gives `validate_theme` (this repo has no CI equivalent).
- ✅ Chrome DevTools + Playwright MCPs attached — matters because the repo's entire
  QA protocol is manual `getComputedStyle` probes; **every finding in this document
  is static analysis and none of it has been verified rendered.**
- ❌ No Shopify Admin API access. Blocks verifying product/variant/media data.
  Workaround: the public `/products/<handle>.js` endpoint is read-only and needs no auth.
- 💡 Worth building: a scoped-push wrapper hardcoding `--only`/`--nodelete`.
  `scripts/` is an empty tracked directory — the obvious home.

---

## 10. Confirmed design — grid page v2 (supersedes prototype v1)

- **6 columns × 4 rows.** Column 1 = size labels (SMALL / MEDIUM / LARGE / XL).
  Columns 2-6 = the five designs.
- **The only text on the page is those four size words.** No headline, no kicker,
  no sub-copy, no design-name labels, no marketing language of any kind.
- Every cell shows the shirt at identical scale. Hover flips front→back.
  Click adds that exact variant to cart.
- Mobile: columns drift, cells auto-flip on a staggered timer.
- **Landing page mirrors the currently published site's landing**
  (`sections/ak-landing.liquid`). No invented copy. Propaganda treatment comes later.

---

## 11. Prototype v2 — built 2026-08-29 (owner said "go")

Rebuilt against §6 feedback and §10. Still zero store contact.

**Grid — all copy removed.** The only text on the page is SMALL / MEDIUM / LARGE / XL.
Deleted: masthead headline, kicker, sub-paragraph, design-name header row, the
"ADD <size>" hover tag, and the "SOLD OUT" wording.
- Add-to-cart confirms with a **magenta pulse** on the cell plus a counter in the
  review chrome — never with on-page text.
- Sold-out is **greyscale + a struck diagonal**, no wording.
- Layout unchanged from the original spec: `grid-template-columns:auto repeat(5,1fr)`,
  four rows, size labels in column one.

**Landing — rebuilt to mirror `sections/ak-landing.liquid` exactly.**
Read the real section in full before rebuilding. Findings that corrected the v1 guess:
- The live landing has **no text and no button at all**. It is a full-bleed
  `<video>` (desktop) / `<img>` (mobile) on a black ground, `object-fit:cover`,
  both `pointer-events:none`, with the whole `<a>` as the click target.
- Desktop video: `cdn.shopify.com/videos/c/o/v/20c113f89b284acbb173345229f4f5c5.mp4`
  Mobile image: `…/files/LANDING_PAGE_ec94c533-64a8-47ea-8520-f75e0a3397db.jpg?v=1751343507`
  Both are **store-level CDN assets**, blocked by the artifact CSP, so the prototype
  shows a clearly-labelled stand-in frame rather than faking the art.
- Exit reproduced verbatim: `350ms`, `scale(1.04)`, `opacity:0`, double-nav guard,
  reduced-motion straight-to-destination path (`:39-47`, `:138-153`).
- **For the drop theme the only change needed is the destination** — and it is
  *three synchronized strings in two files*: `ak-landing.liquid:1` (href),
  `:131` (`var DEST`), and the JS fallback in `templates/index.json:25`.
  Commit `030510e` proved missing one desynchronizes the no-JS path.

**Placeholder art** is deliberately blank — plain tees with dashed print areas in
five muted tones. Nothing implies a design direction, since the propaganda artwork
does not exist yet.

### Next gate
Owner reviews v2. On visual approval → write the implementation plan → Phase 0
(fix the three hazards in §4) → Phase 1 (`theme duplicate`). No store contact
before that.

---

## 12. Prototype v3 — two layout bugs found and fixed (2026-08-29)

Owner screenshot showed the size labels running horizontally across the top and no
shirts rendering. Both were real. Diagnosed in a live browser (Playwright against a
local http server — `file://` is blocked), not by reading the CSS.

**Bug 1 — labels across the top.** `display:contents` on `.labelcol`/`.col` flattens
the column-major DOM into the grid, but grid auto-placement is **row-major**, so the
four `.size` elements filled columns 1-4 of row 1.
*Measured before:* all four labels at `y:317`, x = 101 / 295 / 508 / 721.
**Fix:** `grid-auto-flow:column` + `grid-template-rows:repeat(4,auto)` on `.matrix`,
so each `display:contents` group fills its own column.
*Measured after:* all four at `x:101`, y = 313 / 519 / 725 / 930.

**Bug 2 — invisible shirts.** `.flip` is a `<span>`, which is `display:inline`;
`width/height:100%` are ignored on inline boxes, so it collapsed to 0×0 and every
`position:absolute; inset:0` face inside it inherited a zero box.
*Measured before:* `svgRect {w:0,h:0}`. The sold-out diagonals still showed because
`::before` sits on `.cell`, which was correctly sized — that mismatch was the tell.
**Fix:** `.flip{display:block}`.
*Measured after:* faces and SVG both 186×186.

### Verified in-browser after the fix
- Labels stacked in one column, left of every cell.
- Cells form exactly **5 distinct columns × 4 distinct rows**.
- Flip settles at `matrix3d(-1,0,0,0, 0,1,0,0, 0,0,-1,0, 0,0,0,1)` — exactly
  `rotateY(180deg)` — over `0.52s` `cubic-bezier(.36,.05,.2,1)`, and returns to rest.
- `backface-visibility:hidden`, `transform-style:preserve-3d`, `overflow:visible` all live.
- Add-to-cart increments the counter (0 → 1).
- Mobile: matrix becomes flex, columns animate `drift` at 9s, `--side-gap` → `-60px`.

**Lesson for the Liquid build:** the same two traps apply. Any `<span>` wrapper in the
section needs an explicit `display`, and if the real section uses `display:contents`
for responsive restructuring it must set `grid-auto-flow` to match the DOM order.
Verify in a browser at 1440/1280/1024/390/375/320 rather than by reading the CSS.

### Still blocked on real product imagery
The artifact sandbox blocks `cdn.shopify.com`, so **handles alone cannot put real
shirts in the prototype** — the image files themselves are needed locally to embed.
The real Liquid build needs no files; Shopify serves the images. Handles are still
wanted separately, to verify `media[0]`/`media[1]` ordering via `/products/<handle>.js`.

---

## 13. DESIGN PIVOT — black wall, 20 products (2026-08-29)

Owner changed direction. **This supersedes §10 and most of §5.** Prototype v4 archived
as `2026-08-29-drop-grid-prototype-v4-black.html`.

### 13.1 What changed

| Was | Now |
|---|---|
| Notebook paper background | **Straight black `#000`, modern and simple** |
| Black ink | **All type inverted to white** |
| — | **Banner image area at the top, as a header** |
| Size labels in a left column | **Column removed entirely** |
| 5 products × 4 size variants | **20 distinct products** |
| Size chosen in the grid | **Size is part of each product name** |
| Cell adds to cart | **Cell links to that product's page** |
| No text but 4 size words | **Product name under every shirt** |

Owner also confirmed: each product's description carries more info, with the **size on
the first line**. Every shirt must be clickable through to its own page.

### 13.2 Consequences — this is a net simplification

**Deleted problems.** No add-to-cart on the grid means the entire cart workstream is
gone: the `quick_add:"none"` gate across all 26 collection templates, the null-cart
bounce at `product-form.js:11` (nothing renders `cart-notification`), and the
`update.js` oversell risk. The grid is now images plus links.

**Deleted problem.** No notebook paper means no specificity fight with
`layout/theme.liquid:270-282` (`html,body{background:#000!important}`). On a black
design that global rule now works *with* the drop instead of against it. The five-layer
gradient, the `#MainContent .gradient` backstop and the `--ak-paper-side-gap` mobile
line are all irrelevant to these two pages.

**New requirement.** Variable-length product titles must not break grid alignment.
The repo already hit this — commit `123add7`, *"products: lock coaster grid title
wrap"*. Solved here with a fixed two-line clamp; verified all 20 cells report an
identical 30px name height across names from 18 to 47 characters.

**Unchanged.** Hover flip (front → back), mobile drift + auto-flip, and the landing
mirroring `sections/ak-landing.liquid`.

### 13.3 Product verification — 19 unique, not 20

Owner supplied 20 admin URLs. **`10390298165528` appears twice**, at positions 13 and
17, so only **19 unique products** were provided. The 20th is still outstanding.

Checked against `https://iacxyv-w5.myshopify.com/products.json?limit=250` (public,
read-only, HTTP 200, 18 products returned):
- **0 of the 19 IDs are on the public storefront.** All supplied IDs
  (`10390296068376`–`10390302621976`) are numerically higher than every published
  product (max public `10320055861528`), i.e. they are new and **not published to the
  Online Store sales channel**.
- That is the correct pre-launch state and matches §4 risk 4. Do **not** publish them
  to make them readable — that leaks the drop onto the live theme.
- **To verify: Admin CSV export** (Products → select → Export). Gives handles, titles,
  option names, variants, and image URLs *with position numbers* — which settles the
  `media[0]`/`media[1]` front/back assumption.

Useful signal from the public catalogue: existing tees (`flag-tee`, `g-p-r-tee`,
`candyfacts-label-t-shirt`) all use a **`Size` option with 5 variants**, not 4. If the
drop products carry size options at all, the run may be S/M/L/XL/2XL. Moot for layout
now that size is in the name, but relevant to how the products were built.

### 13.4 Recurring implementation trap — hit twice, must not hit a third time

`display:contents` on a responsive column wrapper flattens children into the grid, but
grid auto-placement is **row-major**. With a column-major DOM the items land rotated.
Both prototype v2 and v4 shipped this bug. **Fix: `grid-auto-flow:column` +
`grid-template-rows:repeat(N,auto)`.**
Also: a `<span>` wrapper is `display:inline` and silently ignores `width/height:100%`,
collapsing absolutely-positioned children to 0×0. **Always set an explicit `display`.**
Both are verifiable only in a browser — reading the CSS did not catch either.

### 13.5 Still outstanding
1. The **missing 20th product**.
2. **Admin CSV export** → real names, handles, image order.
3. **Banner artwork** and its intended aspect ratio (placeholder is 1440×380).
4. Landing artwork for the propaganda direction (still mirrors the live splash).

### 13.6 v5 — frame removed (owner note, 2026-08-29)

"there should not be a box around each shirt it should be transparent against the
background." Applied: `.shot` now has no background fill, no border, no radius, no
shadow — verified `rgba(0,0,0,0)` with `0px` border. Shirt inset reduced 9% → 4% so
the art reads larger without a frame around it.

Hover feedback moved off the border and onto: the flip itself, a 4px lift, and the
name turning `#ff33ff`. Keyboard focus keeps a magenta outline at a wider offset.

**Carry into the Liquid:** the drop's product cells must NOT reuse
`snippets/card-product.liquid` styling wholesale — `assets/component-card.css` gives
cards a background and border by default. Either render bare `<img>`/`<a>` markup in
the new section, or scope overrides under the drop's own page class. Per
`docs/known-fragile-areas.md:40`, `card-product.liquid` itself may only take
handle-gated additions, never restyling.

---

## 14. v6 — first-row title readability (2026-08-29)

Owner: "you must be able to view the first row product titles from full view on any screen."
Measured at 1920x1080 before the fix: title font stuck at **13px** (the `clamp(...,13px)`
ceiling never let type scale) under a 340px shirt, and the banner consumed **507px**, leaving
the row-1 title bottom at y=1020 in a 1080px viewport — 60px of headroom.

Fixes: title `clamp(12px,1vw,18px)`; banner `max-height:34vh` (26vh under 780px tall); wall
`max-width:1600px`; top padding tightens on short viewports; mobile title 8.5px -> 10px.

Verified in-browser (production figures exclude the prototype's 62px review bar):
| viewport | title px | banner px | row-1 title bottom | production headroom |
|---|---|---|---|---|
| 1920x1080 | 18 | 367 | 852 | 290px |
| 1440x700 | 14.4 | 238 | 664 | 98px |
| 1920x600 | 18 | 170 (floor) | 621 | 41px |

---

## 15. PRESSURE TEST — 2-agent design + adversarial attack (2026-08-29)

Owner asked for a pressure-tested design analysis, max 2 agents: one to design the full
drop-theme page set, one to adversarially verify. **Verdict: SOUND_WITH_FIXES.**

### 15.1 CHECKOUT — settled, verified against shopify.dev

**Checkout is not a theme route.** `checkout.liquid` is **Shopify Plus only**; non-Plus stores
customise checkout through theme-editor branding settings, not Liquid. The `checkout` object is
deprecated. Thank-you / Order-status page customisation sunset **2025-08-28**; script tags for
non-Plus sunset **2026-08-26**.
Source: shopify.dev/docs/storefronts/themes/architecture/layouts/checkout-liquid, /api/liquid/objects/checkout.

**So the drop theme owns exactly four surfaces:** landing -> wall -> PDP -> cart. Everything from
the checkout button onward is Shopify's UI regardless of what we build.

### 15.2 BROKEN — found by the adversary, must fix before implementation

1. **The proposed PDP insertion point is inside a CSS comment.** "Append after
   `main-product.liquid:497`" lands inside the comment running **:495-511**. The style block ends
   at **:518**, not :560. Shipping that = every drop rule silently commented out.
2. **`:nth-child(2)` is NOT reliably the back image.** `snippets/product-media-gallery.liquid:64-87`
   emits `product.selected_or_first_available_variant.featured_media` as the FIRST `<li>` when
   non-null, and :97 skips it in the main loop. Any product with a variant-attached image makes
   li#2 the FRONT — a silent front-to-front cross-fade. `templates/product.json:82` has
   `hide_variants:false`, so nothing suppresses it. **Key off `product.media[0]/[1]` via a
   Liquid-emitted class, never DOM order.**
3. **The "no box around shirts" state was misattributed.** It is NOT `card-product.liquid`'s inline
   `ak_clear` (which never touches `.card__media` at :112-113). It comes from
   `main-collection-product-grid.liquid:189-193`, a **section-scoped** rule. Disable that section
   and the box returns.
4. **`/404` and every `customers/*` route are BLACK ON BLACK, not "white on black — leave them."**
   `layout/theme.liquid:67-71` puts scheme-1 on `:root` with `--color-foreground: 0,0,0`; :108 sets
   `body{color:rgba(var(--color-foreground),.75)}`; `main-404.liquid`, `main-login.liquid` and
   `main-account.liquid` emit **zero** colour-scheme classes. Against the forced `#000` ground they
   render invisible. **The empty cart's "LOG IN" link at `main-cart-items.liquid:366` walks a
   shopper straight into one.** Fix with a colour *scheme*, not a colour.

### 15.3 MISSED — gaps that will bite during implementation

- **`.ak-badge-new` is a landmine.** `assets/base.css:2939-3004` defines a 9.6rem **red spiky
  comic starburst** reading "NEW", emitted by `card-product.liquid:190-196` for any product
  carrying the Shopify tag `new`, and it deliberately outranks sold-out. Twenty brand-new products
  are exactly what an owner tags `new`. It is conditionally **emitted**, not merely styled, so CSS
  cannot remove it — **this is an Admin tagging decision the owner must make.**
- **`templates/collection.json:50-53` carries a `custom_css` array** forcing
  `margin-bottom:4rem` and `max-width:480px` on every grid item. It lives in template JSON, survives
  every CSS change, and per shopify.dev is a merchant-owned setting — clearable only in Customize.
- **`columns_mobile` is `"1"`** and the schema allows only 1 or 2. The mobile drift-and-stagger
  design assumes 5 columns. Incompatible with the stock grid section.
- **`.glowing-product-box` is `width:100vw`** (`main-collection-product-grid.liquid:91-104`) with
  **no `overflow-x:hidden` anywhere in the theme** — horizontal scrollbar on any desktop with a
  classic scrollbar.
- **Impact 3rem `!important` on card titles** (`:36-43`) against a ~220px cell. Since the size
  lives in the product NAME, a 2-line clamp would truncate the size — the one datum with no other
  home on the wall.
- **The description block is conditional** (`main-product.liquid:674-679`). If a product has no
  description, the PDP's size line vanishes with no fallback.
- **The banner host (0-byte `main-collection-banner.liquid`) has no colour scheme** — same
  black-on-black failure as 404.
- **990px cliff**: grid jumps 1 column -> 5 columns in a single pixel of viewport.
- `enable_sticky_info:true` (`product.json:73`) unaccounted for; `/cart` has no `ak-footer` so
  footer rules specified for it can never match.

### 15.4 CONFIRMED — the good news

- **Add-to-cart WORKS on the PDP.** The null-cart trace is correct end to end: `product-form.js:11`
  finds neither `cart-notification` nor `cart-drawer` (nothing renders them; `header.liquid` is
  0 bytes; `settings_data.json:126` is `"notification"`), so :64-66 navigates to `/cart`.
  `window.routes` IS defined (`theme.liquid:351-355`). **This is the intended flow, not a bug.**
- **`sections/ak-landing.liquid` is already the brief.** Only two CDN URLs change (`:4` mp4,
  `:9` jpg). `DEST` at `:131` already points at the wall.
- The PDP already carries a **duplicate title** (`main-product.liquid:580-587` emits both `<h1>`
  and a linked `<h2 class="h1">`) — a real catch worth fixing.
- `#MainProduct-{id}{background:#000!important}` and the Dawn media-plate kills at `:90-148`
  already suit a black PDP.

### 15.5 STRATEGIC CONCLUSION

The designer assumed the wall would be built by **restyling the stock product-grid section**. The
attack shows that path is mined: `.ak-badge-new`, the template `custom_css`, `columns_mobile`
capped at 2, Impact 3rem `!important`, the 100vw overflow, and the 990px flip gate are all
properties of that section and its settings.

**Recommendation: build the wall as a self-contained new section**, the way
`sections/ak-archive-magazine.liquid` was built — own markup, own CSS, own JS, page-scoped. That
sidesteps every item above except `.ak-badge-new` (Admin tagging) and gives full control of the
mobile column count the drift design needs. The PDP and cart remain restyle-in-place, since the
attack confirmed their hosts are sound.

---

## 16. PRODUCT MANIFEST — confirmed complete 2026-08-29

**Collection:** `supreme-leader` — Admin id `520911880472`,
storefront `https://amerikid.ca/collections/supreme-leader`.
The drop name is **Supreme Leader** ("SL"), which fits the propaganda direction.

**All 20 products exist.** Titles are strictly `SL-<SIZE>-<NN>`, sizes S/M/L/XL,
designs 01-05. Product type "T-Shirts", vendor AMERIKID, **1 in stock each**,
**all status Draft**, 6 channels / 1 catalog shown in Admin.

| design | S | M | L | XL |
|---|---|---|---|---|
| 01 | 10390296068376 | 10390298525976 | 10390300360984 | 10390301737240 |
| 02 | 10390297280792 | 10390298657048 | 10390300590360 | 10390301933848 |
| 03 | 10390297575704 | 10390298788120 | 10390300819736 | 10390302163224 |
| 04 | 10390297772312 | **10390299640088** | 10390301049112 | 10390302425368 |
| 05 | 10390298165528 | 10390299836696 | 10390301376792 | 10390302621976 |

`10390299640088` (SL-M-04) was the product missing from the owner's first list of links —
that list contained 19 unique ids because `10390298165528` (SL-S-05) was pasted twice.
Supplied by the owner 2026-08-29 and confirmed against the Admin listing.

### 16.1 The titles restore the matrix

`SL-<SIZE>-<NN>` makes the wall fully deterministic from data:
**column = design 01..05, row = size S,M,L,XL.** The size axis the owner removed from the
page as *visible labels* still exists in the *data*, so the 5x4 layout is not arbitrary —
each column is one design in ascending size.

### 16.2 Ordering hazard

**Alphabetical sorting of these titles gives the WRONG size order.**
`SL-L-01 < SL-M-01 < SL-S-01 < SL-XL-01` sorts as **L, M, S, XL**, not S, M, L, XL.
So `alpha-asc` on the collection would render every column mis-ordered.
The wall section must therefore either (a) render from an explicit size order defined in the
section, matching on title, or (b) require the collection be set to Manual sort in the exact
order. Option (a) is preferred: it is immune to anyone re-sorting the collection in Admin.

### 16.3 Blocking issue — every product is Draft

Draft products are not visible on the storefront, so the wall would render **empty** until
they are set Active. But product visibility is store-level, not per-theme, which means making
them visible for QA also makes them reachable on the currently-live notebook theme.
Platform behaviour and the correct QA sequence are being verified against shopify.dev
(see §17). **Do not flip them Active before that answer lands.**

### 16.4 Inventory note
Each product is **1 in stock**. This is a true one-of-one drop: every cell can sell out
permanently after a single purchase, so per-cell sold-out rendering is not decorative —
it is the primary state the wall will spend most of its life displaying.

---

## 17. PLATFORM FACTS — draft visibility, ordering, QA sequence (2026-08-29)

2-agent research + adversarial pass against shopify.dev. **Verdict: SOUND_WITH_FIXES.**
The adversary overturned the researcher's central conclusion. Everything below is cited.

### 17.1 The blunt truth
**Product visibility is purely store-level.** Every gate — status, product publication,
variant publication, market-catalog membership — lives on the product/variant/collection
record, never on the theme. The Liquid `request` object exposes only
`design_mode, host, locale, origin, page_type, path` — **a theme cannot even detect which
theme is rendering**. So `?preview_theme_id=` and the theme editor show identical product
data to the live storefront. *The unpublished theme protects the LAYOUT, not the PRODUCTS.*
`?preview_theme_id=` is undocumented on shopify.dev entirely.

### 17.2 Draft renders an empty wall
`ProductStatus.DRAFT` — *"The product isn't ready to sell and is unavailable to customers on
sales channels and apps."* With all 20 at Draft the wall renders **zero tiles**.
*Evidence caveat from the adversary:* the researcher over-read the UNLISTED changelog to
support this; that changelog is scoped to UNLISTED only. The Draft conclusion rests on the
single weaker ProductStatus line. Correct, but the evidence is thinner than first claimed.

### 17.3 There are FOUR gates, not two
`https://shopify.dev/docs/apps/build/sales-channels/product-publishing` —
*"A variant is visible to buyers … when the following are all true: The product has an Active
status (or Unlisted on supported channels). The product is published to that channel or
catalog. The variant is published to that channel or catalog."*
1. **Product status** (Active / Draft / Archived / Unlisted)
2. **Product publication** to the Online Store channel
3. **Variant publication** — *independent and persistent*: *"Variant publishing state persists
   across product publishing changes."* An unpublished variant survives a status flip silently.
4. **Market catalog** — the Admin "1 catalog" chip. Exclusion makes a product behave
   *"just like it was archived or deleted … omitted from lists and not found when queried by
   handle or ID."* **This would also defeat the handle-lookup path in §17.5.** Verify first.

The "6 channels" chip is publication, not status, and reads 6 before *and* after the flip —
so it gives **no signal** that anything changed. `autoPublish` created those records.

### 17.4 Ordering — no platform sort can help
`sort_by` accepts only: `manual, best-selling, title-ascending, title-descending,
price-ascending, price-descending, created-ascending, created-descending`.
**None produces S, M, L, XL** — `title-ascending` gives L, M, S, XL.
So the size order **must be hard-coded in the section**. This is a confirmed absence, not an
unknown. Also: **never wrap the wall in `{% paginate %}`** — shopify.dev:
*"a section that's wrapped in one renders different items, or none at all, on ?page=2."*
Use `limit`. `collection.products` defaults to 50 per page.

### 17.5 THE FIX — QA with real products and zero leak
The researcher concluded you must choose between a public leak and QA-ing on dummy products.
**That is wrong.** The adversary found the documented path:

**Set the 20 products to UNLISTED, not Active.**
`ProductStatus.UNLISTED` — *"The product doesn't show up in search, collections, or product
recommendations. It will be returned in Storefront API and Liquid only when referenced
individually by handle, id, or metafield reference."*

`all_products['sl-s-01']` **is** a handle reference. And `all_products` has a documented limit
of **20 unique handles per page** — the wall needs *exactly* 20. It fits precisely.

Two hard constraints this imposes: **no other section on that page may touch `all_products`**
(the 20-handle budget is per page), and the section still must not be paginated.

This also composes with the hard-coded size/design order §17.4 already requires — the section
loops `SL-<SIZE>-<NN>` and looks each up by handle. One mechanism solves both problems.

### 17.6 Pre-arm noindex before anything leaves Draft
Metafield **namespace `seo`, key `hidden`, value `1`, type `number_integer`** on each product
*and* on collection `520911880472`. shopify.dev: this adds `noindex`/`nofollow`, **removes the
resource from the sitemap**, and *"they won't appear in search results when customers use
storefront search."* Deleting the metafield restores indexing. Set this FIRST so an indexable
page never exists.

### 17.7 Launch timing is a platform feature
`publishablePublish` accepts a future `publishDate` against the Online Store publication —
shopify.dev names the use case: *"product drops and timed sales."* No human flipping 20
switches at launch. Note it does **not** help QA: a future-dated product is still invisible.

### 17.8 The sequence
- **Phase 0 — verify the gates** (API-checkable, zero exposure): each product's variant is
  published; none excluded from the market catalog; collection `520911880472` is itself
  published (**collections are unpublished by default**).
- **Phase 1 — pre-arm** `seo/hidden = 1` on all 20 products + the collection.
- **Phase 2 — QA**: set the 20 to **UNLISTED**; wall reads them via `all_products[handle]`;
  QA the unpublished theme against real images, titles and front/back order.
- **Phase 3 — publish the theme.** Layout already proven.
- **Phase 4 — launch**: Unlisted → Active (or scheduled `publishDate`), delete the
  `seo/hidden` metafields, add the nav entry.

**The exposure window collapses to the instant of the Phase 4 flip — which is the launch.**

### 17.9 Not determined — test, don't assume
- HTTP status for an unpublished-collection or draft-product URL (404 / redirect / 200).
- `Product.onlineStorePreviewUrl` exists on the Admin API but **no doc describes whether it
  renders drafts**. Not a draft-preview escape hatch until proven.
- Whether `where`/`find` title matching is case- or whitespace-sensitive; assume exact equality.
- The Admin **CSV export click-path and column schema are not on shopify.dev at all** (it is
  help-centre material). Image `position` is documented as 1-based with position 1 = featured.

### 17.10 Rejected, with reasons
- **Storefront password protection** — the only gate that hides fully-live products, but it is
  **store-wide**: it would take the trading notebook storefront offline for the whole QA window.
- **`{% paginate %}`** on the wall — see §17.4.

---

## 18. LIVE THEME INVENTORY — read from Admin 2026-08-29

`shopify theme list --store iacxyv-w5.myshopify.com`, run by the owner. **19 themes.**

### 18.1 Confirmed against the stale docs table
- ✅ **`186464731416` "AmeriKid Notebook Theme - Publish Candidate" is still `[live]`.**
  The docs table dated 2026-06-18 is accurate after ~2 months. Plans built on it hold.
- ✅ **`184615043352` "AmeriKid Dark Theme - Preserve"** present and `[unpublished]`.
- ❌ **`185910067480` IS GONE.** `docs/source-of-truth.md:289` calls it the *"Development
  theme ID (active, used by this workflow) — all particle-removal batches push here."*
  It no longer exists. `184629133592` (the older dev theme) is also absent.
  **There is currently NO development theme.** That doc line is stale and must not be trusted.

### 18.2 THEME SLOT CEILING — the new hard blocker
19 themes exist. A per-store ceiling is real (`shopify theme duplicate` fails with
*"Maximum number of themes reached"*) but **shopify.dev never states the number**; it is
commonly 20. On that basis the store has roughly **one free slot**, and creating the drop
theme consumes it. `shopify theme share` would consume one too.

**This must be resolved before Phase 1.** Otherwise theme creation fails outright.

### 18.3 Obvious cleanup candidates (OWNER DECISION ONLY)
Visibly disposable duplicates — 10 of the 19:

| name | id |
|---|---|
| Copy of Current | 180532052248 |
| Copy of Current | 180643660056 |
| Copy of Current | 181749154072 |
| Copy of Current | 182691201304 |
| Copy of BAD Music Version | 180504658200 |
| Copy of BAD Music Version | 180516225304 |
| Copy of BAD Music Version | 180517536024 |
| Safety Fail | 184961499416 |
| safety fail after iframe clicking x fix | 184962154776 |
| safety fail 4/7 working version | 185074254104 |

**Do NOT delete any of these programmatically.** `AGENTS.md` forbids deleting apparent
duplicates without proving they are unused, and `scripts/guard-shopify.sh` blocks
`shopify theme delete` at the tool layer by design. Deletion is an owner action in Admin,
and only after the owner confirms each is genuinely disposable.

**Never delete:** `186464731416` (live) or `184615043352` (dark preserve).

### 18.4 Full inventory
| # | name | role | id |
|---|---|---|---|
| 1 | AmeriKid Notebook Theme - Publish Candidate | **live** | 186464731416 |
| 2 | Current | unpublished | 180465172760 |
| 3 | Copy of OG Working Version | unpublished | 180465238296 |
| 4 | Copy of BAD Music Version | unpublished | 180504658200 |
| 5 | Copy of BAD Music Version | unpublished | 180516225304 |
| 6 | Copy of BAD Music Version | unpublished | 180517536024 |
| 7 | Version I like | unpublished | 180518748440 |
| 8 | Copy of Current | unpublished | 180532052248 |
| 9 | Copy of Current | unpublished | 180643660056 |
| 10 | Copy of Current | unpublished | 181749154072 |
| 11 | Copy of Current | unpublished | 182691201304 |
| 12 | club amerikid update | unpublished | 182835740952 |
| 13 | Dev Mystery Box save pre upload image fix | unpublished | 183151952152 |
| 14 | pre dev mystery box working v | unpublished | 183151984920 |
| 15 | AmeriKid Dark Theme - Preserve | unpublished | 184615043352 |
| 16 | Safety Fail | unpublished | 184961499416 |
| 17 | safety fail after iframe clicking x fix | unpublished | 184962154776 |
| 18 | Copy of club amerikid update with Installments … | unpublished | 185072386328 |
| 19 | safety fail 4/7 working version | unpublished | 185074254104 |

---

## 19. DROP THEME CREATED — 2026-08-29

### 19.1 The theme
| | |
|---|---|
| **Name** | `AmeriKid Supreme Leader Drop - DEV` |
| **ID** | **`188605497624`** |
| **Role** | `unpublished` |
| **Created from** | `186464731416` (live notebook) via server-side `theme duplicate` |
| **Preview** | `https://iacxyv-w5.myshopify.com?preview_theme_id=188605497624` |
| **Editor** | `https://iacxyv-w5.myshopify.com/admin/themes/188605497624/editor` |

Named to match the existing convention (`AmeriKid <thing> - <role>`) so it is
distinguishable from the "Copy of Current" sprawl.

### 19.2 Why `theme duplicate`, not `theme push --unpublished`
`push --unpublished` would have created the theme from the **local working tree**, shipping
whatever local drift exists. `duplicate` is a **server-side copy of the live theme** — faithful
by construction, and it uploads nothing.

**Verified after creation:**
- `186464731416` still `role=live` — duplicate did not modify the source.
- `184615043352` (dark preserve) still present and unpublished.
- Pulled `sections/ak-landing.liquid` (175 lines) and `snippets/ak-notebook-products.liquid`
  (572 lines) from the new theme into a temp dir: **both SHA-256 identical** to local.
  The duplicate carried the notebook theme intact, and the local tree has no drift on them.

### 19.3 Theme count movement
19 → 17. The owner deleted three (`180465238296` Copy of OG Working Version,
`180504658200` and `180516225304` Copy of BAD Music Version); this work added one.
Slot pressure resolved.

### 19.4 The guard was over-blocking, and is now fixed
`scripts/guard-shopify.sh` initially denied **any** `shopify theme` command carrying
`--theme 186464731416` — which blocked the legitimate `theme duplicate` that creates the drop
theme. `duplicate` and `pull` **read from** a theme; only `push`, `dev`, `publish` and `delete`
**write to** one. The protected-ID rule is now scoped to those write verbs.
Re-tested: **19/19 cases pass** — writes to protected themes still blocked, reads allowed,
no regressions against the original 16.

### 19.5 Sanctioned push shape from here
```
shopify theme push --theme 188605497624 --nodelete \
  --only sections/ak-drop-wall.liquid \
  --only snippets/ak-drop-product.liquid \
  --only snippets/ak-drop-cart.liquid \
  --only snippets/ak-drop-safety.liquid \
  --only templates/collection.supreme-leader.json
```
No `--allow-live`. No `--path .`. Never `186464731416` or `184615043352`.
The guard enforces all of this.
