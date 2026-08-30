# Paste this into the next terminal session

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
