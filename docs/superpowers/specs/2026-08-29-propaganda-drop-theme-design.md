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
