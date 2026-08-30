# Propaganda Drop Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare a third Shopify theme for the 20-piece propaganda drop — landing, a black
5x4 product wall, restyled PDP and cart — staged locally and ready to push to a NEW UNPUBLISHED
theme, without touching the live notebook theme or the preserved dark theme.

**Architecture:** The wall is a NEW SELF-CONTAINED SECTION (`sections/ak-drop-wall.liquid`)
modelled on `sections/ak-archive-magazine.liquid` — its own markup, CSS and JS, all inline,
scoped under a single `html.ak-drop-page` class. It does NOT render `snippets/card-product.liquid`
and does NOT use `sections/main-collection-product-grid.liquid`. That single decision neutralises
six separate hazards (see Global Constraints). The PDP and cart are restyled in place through
their existing `custom_liquid` host slots, following the `html.ak-pdp-page` scoping precedent.

**Tech Stack:** Shopify Liquid (Dawn base), inline CSS/JS, Shopify CLI 3.93.2,
`mcp__shopify-dev-mcp__validate_theme` for linting.

**Spec:** `docs/superpowers/specs/2026-08-29-propaganda-drop-theme-design.md`

## Global Constraints

- **NEVER run `shopify theme dev --theme <id>`.** It hot-syncs local saves AND git checkouts to
  the target and reverted the live Archive template on 2026-06-18 (`docs/change-log.md:15`).
  Safe preview is `shopify theme dev --store iacxyv-w5.myshopify.com` with NO `--theme`.
- **Never run `shopify theme publish` or `shopify theme delete`.** Publishing is owner-only, manual, in Admin.
- **Only sanctioned push shape:** `shopify theme push --only <file> [--only <file>…] --nodelete --theme <NEW_ID>`.
- **Never target `186464731416` (live notebook) or `184615043352` (dark, must stay byte-unchanged).**
- **Never push `config/settings_data.json`.** 478 lines of merchant settings, Admin-overwritable.
- **All new CSS must be page-scoped** under `html.ak-drop-page` / `html.ak-pdp-page` / `html.ak-cart-page`.
  Follow `sections/main-product.liquid:311-436`. NEVER follow `main-collection-product-grid.liquid:27-89`
  (globally scoped `!important`) — forbidden by `docs/known-fragile-areas.md:40` and `:213`.
- **Never edit `sections/ak-top.liquid` or `sections/ak-footer.liquid`.** Restyle page-scoped only
  (`docs/known-fragile-areas.md:209`).
- **`snippets/card-product.liquid` accepts handle-gated additions only**, never restyling (`:40`).
- **Front/back images MUST be addressed as `product.media[0]` / `product.media[1]`**, never by DOM
  position. `snippets/product-media-gallery.liquid:64-87` promotes a variant-attached
  `featured_media` to the first `<li>`, and `templates/product.json:82` has `hide_variants:false`.
- **The style block in `sections/main-product.liquid` ends at `:518`**, and `:495-511` is a comment.
  Any addition goes AFTER `:517`, BEFORE `:518`.
- Verify rendering in a browser at 1440 / 1280 / 1024 / 390 / 375 / 320
  (`docs/runtime-test-checklist.md:8-9`). Static reading has already missed two layout bugs.

### Hazards neutralised by the self-contained-section decision
Because `ak-drop-wall.liquid` emits its own markup and is not hosted by the product-grid section:
`.ak-badge-new` (`assets/base.css:2939-3004`, emitted by `card-product.liquid:190-196` for any
product tagged `new`) is never emitted; `templates/collection.json:50-53` `custom_css` never
applies; `columns_mobile` (capped at 2) is irrelevant; `.glowing-product-box`'s `width:100vw`
overflow never renders; the Impact `3rem !important` card-title rule never matches; and the
`min-width:990px` flip gate in `component-card.css:383` is bypassed.
**`.ak-badge-new` remains an Admin concern ONLY if the drop products are tagged `new` AND are
ever shown through a stock grid elsewhere. On this wall it cannot appear.**

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `AGENTS.md` | Mandated first read; currently has zero deploy guardrails | Modify |
| `.claude/settings.local.json` | Permission allowlist with no deny list | Modify |
| `docs/source-of-truth.md` | Contains a live unscoped-push footgun at `:285-301` | Modify |
| `sections/ak-drop-wall.liquid` | The whole wall: markup + CSS + JS, self-contained | **Create** |
| `snippets/ak-drop-product.liquid` | Page-scoped black restyle of the PDP | **Create** |
| `snippets/ak-drop-cart.liquid` | Page-scoped black restyle of the cart | **Create** |
| `snippets/ak-drop-safety.liquid` | Colour-scheme fix for 404 / customers routes | **Create** |
| `templates/collection.<drop>.json` | Hosts the wall section | **Create** |
| `docs/superpowers/plans/PUSH-RUNBOOK.md` | Exact scoped commands for the owner | **Create** |

---

## Task 1: Phase 0 — disarm the three live hazards

No theme file is touched. This must land before any CLI work.

**Files:**
- Modify: `docs/source-of-truth.md:285-301`
- Modify: `.claude/settings.local.json`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: nothing.
- Produces: a repo where the documented prohibitions are machine-enforced, not prose-only.

- [ ] **Step 1: Fence the stale unscoped push**

In `docs/source-of-truth.md`, wrap `:285-301` in an explicit DO-NOT-RUN banner and neutralise the
command so it cannot be copy-pasted. The block currently contains:
`shopify theme push --theme 184615043352 --path . --store iacxyv-w5.myshopify.com`
(no `--only`, no `--nodelete`, aimed at the preserved dark theme) and `:288` mislabels that ID as
"Live theme ID". Replace the command line with a struck-through, clearly-dead reference and add a
pointer to lines 6-18, which supersede it.

- [ ] **Step 2: Add a deny list**

`.claude/settings.local.json` currently has only an `allow` key, with `Bash(shopify theme:*)` at
`:21` and `Bash(shopify theme *)` at `:68`. Add a `deny` array covering:
`Bash(shopify theme publish*)`, `Bash(shopify theme delete*)`, `Bash(shopify theme dev*--theme*)`,
`Bash(shopify theme push*--allow-live*)`, `Bash(shopify theme push*--live*)`.

- [ ] **Step 3: Hoist the guardrails into AGENTS.md**

Append a "Deploy Guardrails" section to `AGENTS.md` copying `docs/known-fragile-areas.md:6`
verbatim, plus the `theme dev --theme` ban and the never-target-these-IDs rule.

- [ ] **Step 4: Verify**

Run: `git diff --stat`
Expected: exactly three files changed, none under `sections/`, `snippets/`, `templates/`,
`assets/`, `layout/` or `config/`.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md .claude/settings.local.json docs/source-of-truth.md
git commit -m "safety: fence unscoped push, add deny list, hoist guardrails into AGENTS.md"
```

---

## Task 2: The wall section

**Files:**
- Create: `sections/ak-drop-wall.liquid`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: section type `ak-drop-wall`, with schema settings
  `heading_image` (image_picker, the banner), `collection` (collection picker), and
  `products_shown` (range, default 20). Sets `html.ak-drop-page` via a one-line IIFE.
  Task 3 relies on the `ak-drop-page` class name; Task 5 relies on the section type string.

- [ ] **Step 1: Write the section with schema, markup, CSS and JS inline**

Model on `sections/ak-archive-magazine.liquid` (self-contained) and copy the flip idiom from
its `:150-178`. Markup per product: an `<a href="{{ product.url }}">` containing a `.akdw-shot`
with two faces emitting `product.media[0]` and `product.media[1]` via `image_url | image_tag`,
then a `.akdw-name` carrying `{{ product.title }}`.

- [ ] **Step 2: Lint**

Use `mcp__shopify-dev-mcp__validate_theme` on the new file.
Expected: no errors. Warnings about missing translations are acceptable.

- [ ] **Step 3: Verify rendering**

Cannot be verified against the store until Task 6. Verify the CSS logic in the standalone
prototype (`docs/superpowers/specs/2026-08-29-drop-grid-prototype-v6-readable.html`), which is
already browser-verified at 1920x1080, 1440x700 and 1920x600.

- [ ] **Step 4: Commit**

```bash
git add sections/ak-drop-wall.liquid
git commit -m "feat: add self-contained ak-drop-wall section"
```

---

## Task 3: PDP restyle

**Files:**
- Create: `snippets/ak-drop-product.liquid`

**Interfaces:**
- Consumes: the `ak-drop-page` scoping convention from Task 2.
- Produces: sets `html.ak-pdp-drop` via a one-line IIFE, matching the
  `snippets/ak-notebook-product.liquid:42-45` pattern.

- [ ] **Step 1: Write the snippet**

Page-scoped CSS only. Must: kill the duplicate title (`sections/main-product.liquid:580-587`
emits both an `<h1>` and a linked `<h2 class="h1">`) with `.product__title a.product__title{display:none}`;
style the description's first line (the size) as a distinct label; keep the existing white-on-black
CTA at `:168-181`. Do NOT edit `sections/main-product.liquid` — if a rule cannot be won from the
snippet, note it rather than editing the section.

- [ ] **Step 2: Lint, then commit**

```bash
git add snippets/ak-drop-product.liquid
git commit -m "feat: add ak-drop-product PDP restyle"
```

---

## Task 4: Cart restyle + the black-on-black safety fix

**Files:**
- Create: `snippets/ak-drop-cart.liquid`
- Create: `snippets/ak-drop-safety.liquid`

**Interfaces:**
- Consumes: nothing.
- Produces: `ak-drop-safety.liquid` sets `--color-foreground: 255,255,255` for routes that emit
  no colour scheme. Rendered from the cart snippet and from any drop template.

- [ ] **Step 1: Write ak-drop-safety.liquid**

`sections/main-404.liquid`, `main-login.liquid` and `main-account.liquid` emit ZERO `color-`
classes, so they inherit `:root`'s scheme-1 (`text=#000000`, verified in
`config/settings_data.json`), and `layout/theme.liquid:108` paints
`body{color:rgba(var(--color-foreground),.75)}` — black on the forced `#000` ground. The empty
cart's LOG IN link (`sections/main-cart-items.liquid:366`) leads straight into one.
Fix by setting the token, not a colour.

- [ ] **Step 2: Write ak-drop-cart.liquid**

Respect the documented hover-specificity trap: `.cart-item-card` (0,1,0) at
`main-cart-items.liquid:148` vs `.cart-item-card:hover` (0,2,0) at `:179`, declared later. A
rest-state override at equal specificity loses on hover. Note `/cart` has NO `ak-footer`
(`templates/cart.json:68-74`), so write no footer rules for it.

- [ ] **Step 3: Lint, then commit**

```bash
git add snippets/ak-drop-cart.liquid snippets/ak-drop-safety.liquid
git commit -m "feat: add cart restyle and colour-scheme safety fix"
```

---

## Task 5: The drop template

**Files:**
- Create: `templates/collection.<drop-handle>.json`

**BLOCKED** on the collection handle. Everything else can ship without it; this one file cannot
be named until the handle is known. Structure is fixed:
`order: [ak-top, ak-drop-wall, ak-footer]`, with `ak-collection-bg` deliberately absent
(`sections/ak-collection-bg.liquid:12` force-paints `html,body{background:#000!important}` and is
`"disabled": true` in all 22 templates that reference it).

---

## Task 6: Create the theme and push

**BLOCKED** on two owner actions — see the runbook. Never run by an agent unattended.

- [ ] **Step 1: Owner confirms current state**

```bash
shopify theme list --store iacxyv-w5.myshopify.com
```
Confirms `186464731416` is still live and shows how many theme slots are used. The docs table is
dated 2026-06-18 and is ~2 months stale.

- [ ] **Step 2: Create the new unpublished theme**

```bash
shopify theme push --unpublished --theme "AmeriKid Drop" --store iacxyv-w5.myshopify.com --nodelete
```
Note: here `--theme` supplies the NEW THEME'S NAME, not a target ID. Record the returned ID.

- [ ] **Step 3: Scoped pushes thereafter**

```bash
shopify theme push --theme <NEW_ID> --nodelete \
  --only sections/ak-drop-wall.liquid \
  --only snippets/ak-drop-product.liquid \
  --only snippets/ak-drop-cart.liquid \
  --only snippets/ak-drop-safety.liquid \
  --only templates/collection.<drop-handle>.json
```

- [ ] **Step 4: Preview**

`https://iacxyv-w5.myshopify.com/?preview_theme_id=<NEW_ID>` — QA only, never a customer channel.

---

## Self-Review

**Spec coverage:** Landing (spec §13, no work needed — `ak-landing.liquid` is already the brief,
only two CDN URLs change, deferred until artwork exists), wall (Task 2), PDP (Task 3), cart
(Task 4), 404/account safety (Task 4), Phase 0 (Task 1), theme creation (Task 6). Checkout is
not a theme route (spec §15.1) — correctly no task.

**Placeholders:** Tasks 5 and 6 are marked BLOCKED with the exact blocker named, not "TBD".

**Type consistency:** `ak-drop-page` (wall), `ak-pdp-drop` (PDP), section type `ak-drop-wall`
used consistently across Tasks 2, 3 and 5.
