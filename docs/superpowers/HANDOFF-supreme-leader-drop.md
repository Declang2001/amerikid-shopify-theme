# HANDOFF — Supreme Leader Drop Theme

**Last updated:** 2026-08-30
**Branch:** `experiment/propaganda-drop-theme`
**Status:** Built, QA'd end-to-end in a real browser, pushed to the dev theme.
**Blocking:** owner is waiting on remaining media from the team, then publishes.

> READ THIS FIRST, then `AGENTS.md`, then
> `docs/superpowers/specs/2026-08-29-propaganda-drop-theme-design.md` (the full record).

---

## 1. What this is

A drop of **20 one-of-one shirts** on a dedicated Shopify theme, styled after North
Korean propaganda print. Landing page → a 5x4 wall of the 20 pieces → product page →
cart → Shopify checkout. Nothing else.

**Theme:** `AmeriKid Supreme Leader Drop - DEV` — **`188605497624`**, unpublished.
Preview: `https://iacxyv-w5.myshopify.com/?preview_theme_id=188605497624`
**Collection:** `supreme-leader` (Admin id `520911880472`)
**Products:** 20, handles `sl-s-01` … `sl-xl-05`, all Active, 1 in stock each.

---

## 2. THE THREE RULES

1. **Only ever push to `188605497624`.** Never `186464731416` (LIVE notebook theme) or
   `184615043352` (dark theme, must stay byte-unchanged).
2. **Never run `shopify theme dev --theme <id>`.** It hot-syncs local saves AND git
   checkouts to the target; it reverted the live Archive template on 2026-06-18.
   Safe preview: `shopify theme dev --store iacxyv-w5.myshopify.com` with NO `--theme`.
3. **Never edit these shared files.** All drop styling is page-scoped CSS/JS in an
   `ak-drop-*` file: `ak-top.liquid`, `ak-footer.liquid`, `main-cart-items.liquid`,
   `main-product.liquid`, `layout/theme.liquid`, `config/settings_data.json`.

`scripts/guard-shopify.sh` (a PreToolUse hook) enforces 1 and 2 at the tool layer.
19/19 test cases pass. **Do not weaken it without re-running them.**

---

## 3. The files

| File | Role |
|---|---|
| `sections/ak-drop-wall.liquid` | The whole wall: banner, red band, 5x4 grid. Self-contained. Handle-guarded to `supreme-leader`. |
| `sections/ak-drop-landing.liquid` | The splash. Postcard + propaganda print effect. |
| `snippets/ak-drop-product.liquid` | PDP restyle. **Handle-gated to `sl-`** — everything else falls through to `ak-notebook-product`. |
| `snippets/ak-drop-cart.liquid` | Cart restyle + "Back to the drop" anchor. |
| `snippets/ak-drop-chrome.liquid` | Hides logo/nav/club-launcher, keeps the cart. Repoints old-collection links. |
| `snippets/ak-drop-safety.liquid` | Colour fix + back link for 404 and all 7 `customers/*`. |
| `templates/collection.json` | Hosts `ak-drop-wall`. **Modified — differs from live.** |
| `templates/index.json`, `product.json`, `cart.json`, `404.json`, `customers/*.json` | Modified. All differ from live. |
| `templates/collection.supreme-leader.json` | Unused. See §5. |

---

## 4. HOW TO PUSH — the two-stage rule

**Push section/snippet files FIRST, template JSON SECOND, in separate commands.**

Shopify validates template JSON against the section schema *on upload*. Pushing a
section and a template that uses its new settings in the SAME command silently
**strips the unknown settings**. This bit us once: `banner_url` vanished from
`collection.json` and the banner rendered as nothing.

```bash
# 1. code
shopify theme push --theme 188605497624 --nodelete --store iacxyv-w5.myshopify.com \
  --only sections/ak-drop-wall.liquid --only snippets/ak-drop-chrome.liquid
# 2. THEN the templates
shopify theme push --theme 188605497624 --nodelete --store iacxyv-w5.myshopify.com \
  --only templates/collection.json
```

Always `--only`. Never `--allow-live`. Never `--path .`.

---

## 5. Non-obvious things that will waste your time

- **`?preview_theme_id=` silently fails on a bare request.** Hit
  `https://iacxyv-w5.myshopify.com/?preview_theme_id=188605497624` FIRST to set the
  cookie, then navigate. Without that you are looking at the LIVE theme and will
  "debug" a bug that does not exist. It survives the redirect to `amerikid.ca`.
- **Alternate templates cannot be assigned.** Admin's Theme-template dropdown lists
  templates from the **published** theme, so `collection.supreme-leader.json` can
  never be selected while the drop theme is unpublished. That is why the wall lives
  in the DEFAULT `collection.json` behind a handle guard, matching the house pattern
  at `collection.json:20`. The alternate template is left in place but unused.
- **A literal `{% if %}` inside a CSS comment still opens a Liquid branch.** Liquid
  parses the whole file and does not know CSS comments exist.
- **Alphabetical sort gives L, M, S, XL.** No Shopify `sort_by` produces S,M,L,XL.
  The size order is hard-coded in the section and resolved by handle.
- **`all_products[handle]` is capped at 20 unique handles per page** and the wall uses
  exactly 20. No other section on that template may use `all_products`.
- **Never wrap the wall in `{% paginate %}`** — a paginated section renders different
  items, or none, on `?page=2`.
- **The leading `html` in the drawer selectors in `ak-drop-chrome.liquid` is
  LOAD-BEARING.** It is the only reason (0,2,1) beats `ak-top.liquid:261`'s
  `display:flex!important` at (0,2,0). Rewriting it as `.ak-drop-page` turns the
  drawer into a full-screen z-99999 overlay of seven notebook links.
- Products are **1 in stock each**, so sold-out is the state the wall will spend most
  of its life in. Each description's first line is the size.
- **Mobile is 4 horizontal size-tracks**, not a grid. Each row (= one size) is a real
  `overflow-x:auto` scroller that drifts right-to-left AND can be swiped. Three
  non-obvious things there, all of which cost time:
  1. **Never animate a marquee by writing sub-pixel values into `scrollLeft`.** The
     browser rounds on read-back, so a 0.4px/frame drift rounds to 0 every frame and
     the track never moves. Keep a float accumulator you own.
  2. **Speed must be px-per-SECOND, not per frame.** A per-frame constant runs at
     double speed on a 120Hz phone.
  3. **`scroll-snap-type` fights a continuous drift** — each increment is re-snapped to
     the nearest item boundary and the track stalls. No snap on these tracks.
  The DOM is row-major (outer Liquid loop = size), which is also why the desktop grid
  needs no `grid-auto-flow` override.

---

## 6. QA status — verified in a real browser 2026-08-30

| Surface | Result |
|---|---|
| Landing | Postcard renders, 4 effect layers, **0 off-journey links** |
| Wall | 20 cells, 5 cols x 4 rows, band correct, stock grid hidden, nav hidden, cart visible, **0 off-journey links**, 40 images 0 broken |
| Hover | Cross-dissolve verified: front 1→0, back 0→1 |
| PDP | One visible H1 (duplicate hidden), size as description line 1, ATC enabled, **0 off-journey links** |
| Add to cart | Works → `/cart`, item at $60 |
| Remove | Works → empty cart, **all 4 escapes hidden**, back link present |
| Band | KO 92px@1440x900 / 84px@1440x800 / 37px@390, rail off on mobile, no overflow anywhere |
| Fold | Row-1 titles above the fold at 1440x900 (103px), 1440x800 (44px), 1920x600 |
| **Self-containment** | A shopper with NO preview cookie gets the **notebook theme** on `/`, `/collections/supreme-leader`, `/products/sl-s-01`, `/cart` — zero drop markup. Live templates contain **0** `ak-drop` references. |

---

## 7. WHAT IS LEFT

### The red band — final copy (2026-08-30)
Line 1: `최고 지도자 티셔츠` = **"Supreme Leader T-shirt"**. Travels LEFT TO RIGHT on a
26s loop, pauses on hover/focus. Do not change the wording.
Line 2: `AMERIKID 지금 구매 가능` = **AMERIKID / "available for purchase now"**.
AMERIKID is deliberately the only English word on the band.
All decoration was removed at the owner's request: the diagonal mis-registration
field, the chevron rail, and the stars flanking line 2. Do not reintroduce them.

### Waiting on media (the owner is handling this)
1. **Final banner image** for the wall. Currently the landing postcard as a
   placeholder, set via `banner_url` in `templates/collection.json`. When real art
   arrives, upload it and use the `banner_image` picker in the theme editor — the
   picker overrides the URL automatically.
2. **Final landing art**, if it changes. Currently the Supreme Leader postcard.

### Decisions still open
3. **`seo/hidden` metafield.** `amerikid.ca/collections/supreme-leader` is **publicly
   reachable right now** — the products are Active. Setting metafield namespace `seo`,
   key `hidden`, value `1`, type `number_integer` on the 20 products and the collection
   adds noindex/nofollow, removes them from the sitemap and from storefront search.
   Reversible by deleting the metafield.
4. **`show_dynamic_checkout`** in `templates/product.json`. Left `true`, the accelerated
   checkout buttons skip `/cart` entirely — so the fastest-converting shoppers never
   see the cart at all.
5. **Korean wording.** Band reads `최고 지도자 티셔츠` ("Supreme Leader T-shirt").
   `위대한 수령 티셔츠` ("Great Leader T-shirt") is the more loaded DPRK phrasing if
   wanted — one field change. Worth a native-speaker check either way.

### Never done, worth doing
6. **Nobody has QA'd the cart or PDP at mobile widths.** The wall was checked at 390;
   the other surfaces were not.
7. The third product image (`-D.jpg`, a detail shot) is unused. A natural PDP addition.

### At launch — OWNER ONLY
8. Publish `188605497624` in Shopify Admin. **No agent runs `shopify theme publish`.**
   Rollback is republishing `186464731416`.

---

## 8. Full record

- Spec, 700+ lines: `docs/superpowers/specs/2026-08-29-propaganda-drop-theme-design.md`
- Plan: `docs/superpowers/plans/2026-08-29-propaganda-drop-theme.md`
- Prototypes v1-v6: `docs/superpowers/specs/2026-08-29-drop-grid-prototype-*.html`
- `git log experiment/propaganda-drop-theme` — every commit message carries its own
  reasoning and the evidence behind it.
