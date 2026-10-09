# Paste this into the next terminal session

> ## CURRENT STATE — read this first (2026-10-09, end of DROP-WALL-REFRESH-3 / PDP-SIZE-CHART-1)
> - **LIVE theme: `188605497624` "AmeriKid Supreme Leader Drop - DEV"** (role `main`; the name still says DEV).
>   Rollback theme: `186464731416` notebook (unpublished). `184615043352` dark theme must stay byte-unchanged.
> - **Repo == live.** On 2026-10-09 a full pull of 188605497624 matched the repo byte-for-byte before the change, and every
>   pushed file was pulled back byte-identical after it (2026-09-26: commit `e303e0d` mirrored 19 app/Admin-side files).
>   Before editing, re-check: pull live into a scratch folder and `diff -rq` it, since apps and the Admin can change live at any time.
> - **Branch:** `experiment/propaganda-drop-theme` (fast-forwarded to match `feature/drop-wall-refresh`), both pushed to origin.
> - **Pushing to live:** the only shape is `shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only <file>...`.
>   `scripts/guard-shopify.sh` blocks `--allow-live` for agents and the auto-mode classifier blocked editing the guard,
>   so **the OWNER runs live pushes** by pasting the command with `!`. Push new assets BEFORE the code that uses them.
>   Guard caveats: its `LIVE_ID` still names 186464731416, and it misses the short flags `-a/-t/-l/-p`.
> - **Never** `shopify theme dev --theme <id>` (it hot-syncs to that theme), `theme publish`, `theme delete`, or push `config/settings_data.json`.
> - **What's on the wall now:** full-width 25%-squashed banner (desktop), red Korean band, 5x4 grid, SOLD OUT burst on
>   sold tiles, each row ordered in-stock first then sold (Liquid, every row), and an in-stock showcase after the M row
>   (8:7 frame, 2.5s per shirt via `showcase_seconds` 2-10 step 0.5, no hover pause). PDP label `ALL SHIRTS`.
>   **SL product pages show the owner's size chart** under the description (`size_chart` custom_liquid block in
>   `templates/product.json` -> `snippets/ak-drop-size-chart.liquid`; `sl-` handle or tag `size-chart`; tag
>   `no-size-chart` hides it). Owner pushed product.json without tagging, so all 20 SL shirts show it (incl. the
>   long-sleeve L-01, cropped L-05 and black XL-02).
>   Details: `docs/qa/2026-10-09-drop-wall-pdp/README.md` (latest, with rollback), `docs/qa/2026-09-26-drop-refresh/README.md`,
>   and `docs/known-fragile-areas.md` (top, items 1-11). Three templates host the wall: `collection.json` (live),
>   `collection.supreme-leader.json` and `collection.gp-template-bk-default.json`; freshness-check all three.
> - **If wide banner art arrives** (spec: 6:1, 3840x640, lettering on one line; see the QA README):
>   the current desktop rule `height:25vw;object-fit:fill` in `sections/ak-drop-wall.liquid` would STRETCH it.
>   Change that rule to `height:auto` (natural aspect) when swapping the art, and keep a 3:1 image for mobile.
> - Local QA tooling that worked: python-liquid render of the section with live `products.json`
>   (see the 2026-09-26 QA README), then Playwright at 390/700/1366x700/1440x900.
> - **File map:** the wall is `sections/ak-drop-wall.liquid`, hosted by the DEFAULT `templates/collection.json`
>   behind a `supreme-leader` handle guard (`templates/collection.supreme-leader.json` is UNUSED). The live banner
>   image is `assets/ak-drop-cover-1.jpg` (via the `cover_option` default; no `banner_image` is set). The PDP is
>   `snippets/ak-drop-product.liquid` (only `sl-` handles), rendered from `templates/product.json`.
> - Agents MAY run `shopify theme pull --theme 188605497624 --path <scratch dir>` (read-only; the guard allows it).
>   Never pull into the repo root. The guard also does NOT block `--publish` on `theme push` (long or `-p`); never use it.
> - The old "swap the banner with the theme-editor picker, no code change" instruction is OBSOLETE: the
>   desktop squash rule would distort any new art. See the Banner art spec in the 2026-09-26 QA README.

> LATEST 2026-09-26: `docs/qa/2026-09-26-drop-refresh/README.md` (DROP-WALL-REFRESH-1).
> v2 same day: desktop banner is a FULL-WIDTH 25% squash (owner's choice, 360px at 1440);
> the showcase no longer pauses on mouse hover (it froze because it covers ~81% of a laptop).
> v1 shrank the banner to 55% (superseded by v2). PDP says ALL SHIRTS, sold-out tiles are full colour
> under the new SOLD OUT burst (`assets/ak-drop-sold-out.png`), and there is a new in-stock showcase
> after the M row. LIVE on 188605497624, pushed by the owner (guard blocks --allow-live
> for agents). If a sold-out burst is missing, the PNG did not ship: push the asset first.


### Paste this into the next session (current)

> Work in `/Users/declangainey/Desktop/Everything/amerikid-shopify-theme-working`. Read `AGENTS.md`, then the
> CURRENT STATE block of `docs/superpowers/START-HERE-next-session.md`. The LIVE theme is `188605497624`
> (the name says DEV, but it is published). Pull live into a scratch folder and `diff -rq` it against the repo before
> editing. Plan first and get the owner's approval. Test locally. Hand the owner the exact scoped
> `--allow-live --nodelete --only` push to run with `!`, assets first. Then pull back, verify, and update the docs.

---
## HISTORICAL NOTES BELOW. Superseded by CURRENT STATE above; do not act on them.
Everything below predates 2026-09-26. Some of it describes the pre-publish world
("unpublished", "never --allow-live", "use the picker", old repo path, mobile tracks).
Where it conflicts with CURRENT STATE, CURRENT STATE wins.

> LATEST 2026-09-11: read `docs/qa/2026-09-11-hotfix/README.md` first.
> Live theme 188605497624 has the delayed PageFly landing takeover suppressed
> on the drop homepage only. Mobile shirt timers removed; front stays visible,
> tap opens PDP, desktop hover retained. Two section files uploaded, no redesign.

> LIVE 2026-09-10: owner has published theme 188605497624. All "unpublished"
> references below are historical. Landing exit flash fixed by keeping its
> artwork opaque through navigation; mobile and desktop navigation verified.

> FINAL 2026-09-10: open `/Users/declangainey/Desktop/Everything/amerikid-shopify-theme-working`.
> Read `docs/qa/2026-09-10-final/README.md`. Only Cover 1 is now shown; slideshow
> disabled. Landing light effects and artwork zoom disabled; bouncing logo kept.
> This supersedes the older instructions below. Theme remains unpublished.

> Updated 2026-09-09: the old one-image-only task below is superseded.
> Read `docs/qa/2026-09-09-drop/README.md` and its `index.html` screenshot gallery.
> Full-width 3:1 slideshow (three covers plus original postcard / 10 seconds),
> no visible pause button, stationary two-column mobile product grid, lower availability strip
> removal, uninterrupted-on-hover Korean headline, full-screen landing artwork,
> enlarged PDP media and previous/next navigation are uploaded to unpublished
> theme 188605497624. Owner QA and manual publication remain. Never publish via CLI.

Open a terminal in `~/Desktop/amerikid-shopify-theme-working` and paste:

---

Read `docs/superpowers/HANDOFF-supreme-leader-drop.md` first — it has everything.

Short version: the AmeriKid "Supreme Leader" drop theme is **built, QA'd and
finished**. Theme `188605497624`, unpublished. The only remaining work is
**replacing one placeholder image**: the banner at the top of the wall on
`/collections/supreme-leader`, which is currently reusing the landing postcard.

To swap it:
1. Upload the new banner to Shopify Files (or have it ready as a URL).
2. Theme editor for theme `188605497624` → the collection page → **AK Drop Wall**
   section → **Banner image** picker. The picker overrides the placeholder URL
   automatically — no code change needed.
3. Preview: open `https://iacxyv-w5.myshopify.com/?preview_theme_id=188605497624`
   FIRST to set the preview cookie, THEN go to `/collections/supreme-leader`.
   Skipping step 3's first URL shows you the LIVE theme instead — this wasted
   real time before.

If a code change IS needed, the three hard rules:
- Only ever push to `188605497624`. Never `186464731416` (LIVE) or `184615043352`.
- Never run `shopify theme dev --theme <id>`.
- Never edit `ak-top.liquid`, `ak-footer.liquid`, `main-cart-items.liquid`,
  `main-product.liquid`, `layout/theme.liquid` or `config/settings_data.json` —
  all drop styling is page-scoped in an `ak-drop-*` file.
And push section/snippet files FIRST, template JSON SECOND, in separate commands.

`scripts/guard-shopify.sh` blocks the dangerous commands at the tool layer.

Do not reintroduce the red band's removed decoration (diagonal lines, chevron
rail, stars) — that removal was deliberate.

Publishing is the owner's job, manually in Shopify Admin.

---
