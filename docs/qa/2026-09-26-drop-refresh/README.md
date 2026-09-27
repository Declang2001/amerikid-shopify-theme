# Drop wall refresh — DROP-WALL-REFRESH-1 (2026-09-26)

Theme **188605497624 is LIVE** ("AmeriKid Supreme Leader Drop - DEV" — the name
still says DEV; its role is `main`). Owner-requested, owner-approved, pushed
**straight to live without a preview theme** at the owner's choice.
Branch `feature/drop-wall-refresh`, code commit `1f9fa31`.

## What changed

| # | Owner request | Change | File |
|---|---|---|---|
| A | Banner smaller so more of row 1 shows | Desktop (>=750px) cover scaled to 55% width, centred on black: 264px tall at 1440 (was 480). Never cropped — the lettering touches both edges. Mobile unchanged (~130px). | `sections/ak-drop-wall.liquid` |
| B | "All shirts" in caps | PDP nav label -> `ALL SHIRTS` | `snippets/ak-drop-product.liquid` |
| C | New SOLD OUT graphic, big, over the corner | Full-colour shirt under the owner's burst, top-left (per example.jpeg), 62% of tile, overhang capped at the page gutter, re-anchored to the shirt on short laptops. Removed greyscale / 26% opacity / diagonal strike / title strikethrough; title dimmed. Visually-hidden "(sold out)". | `sections/ak-drop-wall.liquid`, NEW `assets/ak-drop-sold-out.png` (800x663, 77KB, trimmed + quantised from the owner's 2400px 2.6MB PNG) |
| D | Rotating big front shot of every available shirt between M and L rows | Full-width showcase after the M row: image 1 of each in-stock shirt, slides right-to-left every 4s, name only, links to the PDP. Hidden at 0 in stock, static at 1. Holds on real mouse movement or keyboard focus, when offscreen or the tab is hidden; no autoplay with reduced motion. | `sections/ak-drop-wall.liquid` |

New section settings (schema defaults apply — `templates/collection.json` was
NOT changed or pushed): `showcase_hidden` (checkbox, default off — a "hide"
toggle on purpose, because a missing checkbox reads as false),
`showcase_after` (default `M`; must exactly match a Row order size; M or XL
sit cleanly on phones, S or L leave one empty cell), `showcase_seconds`
(3-10, default 4).

## Deploy (run by the owner via `!`, because scripts/guard-shopify.sh blocks `--allow-live` for agents)

1. `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only assets/ak-drop-sold-out.png`
   — verified 200 `image/png` on `//amerikid.ca/cdn/shop/t/47/assets/` and the section still the old version before step 2.
2. `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only sections/ak-drop-wall.liquid --only snippets/ak-drop-product.liquid`

The asset MUST go first: the new sold-out CSS has no other visual cue, so a
missing PNG would make sold shirts look available.

## Verification

- **Pull-back:** all three files plus `templates/collection.json` byte-identical to the repo.
- **Live HTML:** no Liquid error; 1 showcase after rows S,M; 15 slides (= in-stock count); 5 sold tiles; burst URL live; `ALL SHIRTS` on PDPs.
- **Live browser, fresh context:** `Shopify.theme.id` 188605497624, role `main`.
  - 1440x900: banner 264px, row-1 titles end at 792px (above the fold), burst image loads (800px), no horizontal overflow.
  - 390x844: banner 130px, showcase directly after tile 10, leftmost burst 3px inside the viewport, no overflow.
  - PDP sl-l-05: `ALL SHIRTS` -> `/collections/supreme-leader`, ATC enabled, no overflow.
- **Console:** only pre-existing third-party errors (favicon 404, Videeo `video-player` double define, Shop Pay monorail fetch in headless).
- **Pre-push local render** (python-liquid with live product data): 0/1/15/20 in-stock scenarios; 4.0s cadence; hover hold and resume; reduced motion; 700px and 1366x700 regressions fixed.
- **Theme Check:** no new offences (one pre-existing RemoteAsset warning for the postcard URL).
- **Adversarial review:** 3 lenses (Liquid/platform, CSS, JS/a11y), 16 confirmed findings (10 distinct), all applied before the push.

Screenshots: `LIVE-*.png` are the live storefront after the push; `local-*.png` are the pre-push local render.

## Rollback

```
git checkout 1f9fa31~1 -- sections/ak-drop-wall.liquid snippets/ak-drop-product.liquid
shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only sections/ak-drop-wall.liquid --only snippets/ak-drop-product.liquid
```
`rollback/` also holds byte copies of both files as they were live before this
change. The PNG can stay on the theme; unused it is harmless.

## Open items

- `scripts/guard-shopify.sh` is stale and has gaps: `LIVE_ID` still names the
  notebook theme 186464731416 (now unpublished), and short flags `-a`
  (allow-live), `-t` (theme), `-l` (live) and `-p` (**publish**) are not
  matched. The agent was not permitted to edit the guard
  (auto-mode self-modification denial), so live pushes remain owner-run.
