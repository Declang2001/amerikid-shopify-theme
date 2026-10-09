# 04 — FINAL REVIEW (2026-10-09): showcase + reorder + size chart

Read-only. No repo file edited, nothing pushed/served. One read-only `shopify theme pull` of live into
`review/final/livepull/`. All artefacts in `review/final/`.

## (a) Verdicts
| # | Change | Verdict | One line |
|---|---|---|---|
| 1 | Showcase: A3 desktop trim + 8:7 cover frame + 2.5s/.55s + hold-for-image | **GO-WITH-CHANGES** | A3 is right; but ship the schema as **integer ms** (`showcase_ms` 2000–10000 step 250, default 2500), and use my hardened image guard (the reviewer's version can stall forever on a 404 / never-loading image). |
| 2 | Reorder: in-stock → sold → empty, per row, Liquid capture | **GO** | Merges cleanly with #1; 9 scenarios render correctly; 0 new theme-check offenses. |
| 3 | Size chart: snippet + asset + `custom_liquid` block after `description` | **GO-WITH-CHANGES** | Gate made case-insensitive and opt-out-wins; 3-stage push with a hard "snippet is live" gate before `product.json`. |

## (b) Claims: verified vs unverified
| Claim | Status | Evidence |
|---|---|---|
| Repo == live for product.json, collection.json, collection.supreme-leader.json, collection.gp-template-bk-default.json, ak-drop-wall.liquid, main-product.liquid, ak-drop-product.liquid | **VERIFIED today** | `final/livepull/` + `cmp` (all SAME) |
| No template stores any `showcase_*` value (so schema default applies; renaming the id is safe) | **VERIFIED** | grep of all 3 templates that host `ak-drop-wall`, repo and live; live HTML shows `data-seconds="4"` = schema default |
| Reorder + showcase diffs merge without overlap | **VERIFIED** | `final/ak-drop-wall.diff` (one file, disjoint hunks) |
| Merged file renders correctly in all scenarios | **VERIFIED** | `final/harness/summary.txt`: today / all-in-stock / all-sold / L row 0 in stock / missing in-stock / missing sold / S partial / title fallback / showcase_after=L. 20 tiles each, 0 stray text nodes, tile-HTML multiset == original, showcase slides unchanged, `data-ms="2500"`, 13 `sizes` strings updated |
| Theme Check: no new offenses | **VERIFIED** | Full-theme scratch copies, `shopify theme check`: base 732 = new 732, 0 new; only touched-file offense is the pre-existing RemoteAsset on the postcard `<img>` |
| JS cadence 2.5s, guard works | **VERIFIED (headless, my own Chromium)** | `final/runtime/results.json`: normal 2500 ms steps; 404 on slide 2 → no stall (2500/5000/7500); 6s-slow image → held to 7500 then advanced; 30s-slow image → capped, advanced at 10000 |
| A3 geometry | **VERIFIED** | frame 432×378 at 1440×900 (block ≈423 + 2 grid gaps ≈ 483px ≈ 54% vh); 354×310 at 390×844 |
| 4:3 crop cuts XL-02 9.7%; 8:7 ≤0.17% | Reviewer-verified (`showcase/crop-risk.json`), not re-run | accepted |
| Option B pushes row 1 below the fold | Reviewer-verified, not re-run | accepted |
| Decimal `step: 0.5` uploads | **UNVERIFIED** | shopify.dev says step "defaults to 1", values "can't be strings"; nothing forbids decimals, but Theme Check doesn't enforce server-side range rules and there is no precedent in this theme. → zero-risk integer-ms design chosen |
| Range ≤101 steps | Recollection, unverified | moot: 2000–10000/250 = 32 steps |
| Gate logic (`contains` on array = exact element) | **VERIFIED** | `final/gate-test.txt` (python-liquid): sl-*→chart; `no-size-chart`/`No-Size-Chart`→none; `size-chart` on flag-tee→chart; both tags→none; `size-chart-tee`→no effect; `slick-*`→none |
| Missing snippet breaks every default-template product page | PLAUSIBLE (standard runtime Liquid error, not reproduced) | handled by push order + hard gate |
| `{% doc %}` accepted by live Shopify | **VERIFIED** | already live in `ak-drop-product/-safety/-cart/-chrome.liquid` |
| SL-L-05 / SL-XL-02 may be different blanks | Reviewer visual evidence only | owner question (non-blocking, see i) |

## (c) NEW findings (missed by all three reviewers)
1. **HIGH — the reviewer's wait-for-image guard can freeze the showcase permanently.** It holds while `!(complete && naturalWidth)`. A broken image (404, deleted product image, decode error) is `complete && naturalWidth==0` forever, so `advance()` returns every tick and the carousel never moves again. Fixed: hold only while `!img.complete` (still downloading; `complete` is also true for broken images) and cap at 3 beats (`showWait`), then advance anyway. Runtime-proven (see b).
2. **MED — decimal range step is unproven server-side;** a rejected schema would fail the *whole* section upload, taking the reorder down with it. Switched to integer ms with a NEW id `showcase_ms` (old `showcase_seconds` removed). Safe because no template (repo or live) stores either id. Pre-push freshness check must re-confirm that (owner could have opened the editor).
3. **MED — three templates host `ak-drop-wall`, not one** (`collection.json` live, plus `collection.supreme-leader.json` "unused" and `collection.gp-template-bk-default.json`). None stores showcase values; all stay valid. Freshness check must cover all three.
4. **LOW — tag case.** `product.tags contains 'no-size-chart'` is case-sensitive; an owner typing `No-Size-Chart` would silently not opt out. Snippet now lower-cases tags (`join|downcase|split`). Also flipped precedence so the opt-out always wins (reviewer's version let `size-chart` override `no-size-chart`).
5. **LOW — A3 also shrinks the showcase on short phones** (the `48vh` clamp is global): 375×667 → 320px wide (was 339). Phones ≥ ~740px tall are unchanged in width (width-bound). Acceptable; noted for the owner.
6. **LOW — rollback copy in docs is stale.** `docs/qa/2026-09-26-drop-refresh/rollback/ak-drop-wall.liquid.live-2026-09-26` ≠ current live (v2). Save fresh rollback copies before pushing (see g).
7. **LOW (pre-existing) — guard script.** `LIVE_ID` still 186464731416; short flags (`-a/-t/-p`) unguarded. Already in START-HERE caveats; not a blocker because the CLI itself refuses a live push without `--allow-live`, which the guard blocks for agents.
8. **INFO — `liquid` tag comment.** I moved the snippet's comment out of the `{%- liquid %}` block into a normal `{% comment %}` (avoids relying on in-tag comment support).

## (d) Final change set
| File | Action | Proposed copy |
|---|---|---|
| `sections/ak-drop-wall.liquid` | modify (reorder + showcase merged) | `review/final/ak-drop-wall.liquid`; diff `review/final/ak-drop-wall.diff`; generator `review/final/scripts/merge.py` |
| `snippets/ak-drop-size-chart.liquid` | **new** | `review/final/ak-drop-size-chart.liquid` |
| `assets/ak-size-chart.jpg` | **new** (1200×1200 progressive JPG q80, 155,242 B) | `review/final/ak-size-chart.jpg` |
| `templates/product.json` | modify (+`size_chart` custom_liquid block after `description`) | `review/final/product.json`; diff `review/final/product.json.diff` |

Wall diff summary: per-row `akdw_open/akdw_sold/akdw_gap` capture buffers reset before each `<div class="akdw-row">`, emitted open→sold→gap; showcase `sizes` → `(min-width: 750px) and (max-height: 1142px) 48vh, (min-width: 750px) 548px, (orientation: landscape) 48vh, 92vw`; `data-ms="{{ section.settings.showcase_ms | default: 2500 }}"`; desktop-only `padding-block:0` + slide `gap:6px` (`@media screen and (min-width:750px)`); slide transition `.55s`; frame `width:min(100%,48vh,548px);aspect-ratio:8/7;min-height:0;overflow:hidden`; img `object-fit:cover`; JS `showMs = Math.max(2000, parseInt(data-ms)||2500)` + hold guard; schema `showcase_ms` (range 2000–10000 step 250 unit ms default 2500, info "2500 = 2.5 seconds."); design_order info text. Grid gaps and mobile padding untouched. Load-bearing JS:
```js
var nextIndex = (showIndex + 1) % slides.length;
var nxt = slides[nextIndex];
var nimg = nxt.querySelector('img');
if (nimg && !nimg.complete && showWait < 3) { showWait++; warm(nextIndex); return; }
showWait = 0;
var cur = slides[showIndex];
showIndex = nextIndex;
```
Implement by copying the four files from `review/final/` into the repo (they were built from HEAD `abf082b`, which == live).

## (e) Local QA the main agent must run BEFORE handing over push commands
1. `cmp` each copied file against `review/final/`; `shopify theme check` → no offenses in the 3 touched/new Liquid files beyond the pre-existing RemoteAsset.
2. Re-run `review/final/scripts/harness.py` (point `R` at the repo copy) → 9 scenarios as in `final/harness/summary.txt`.
3. `shopify theme dev --store iacxyv-w5.myshopify.com` (**no `--theme`**), own headless Playwright on 127.0.0.1:9292, never the user's Chrome:
   - `/collections/supreme-leader` at 1440×900, 1440×800, 1366×700, 1920×1080, 700×900, 390×844: L row = L-05 | L-01..04 sold; XL = XL-02 XL-03 | XL-01 XL-04 XL-05; row-1 titles above the fold at 1440×900 (≈889px); showcase frame 432×378 at 1440×900; `scrollWidth == innerWidth`; burst does not touch the showcase name on 390; cadence ≈2500 ms; reduced-motion holds on slide 1; Tab into a slide holds; mouse hover does NOT hold; console clean; tab order matches visual order.
   - PDPs `sl-l-05`, `sl-s-01`, `sl-xl-02`, `sl-l-01` at 1440 and 390: chart directly under description, above Share; `.product__description > *:first-child` still the size header; no horizontal overflow; media modal still covers it. `flag-tee` (and one more non-SL product): no `.ak-size-chart` in HTML; no "Liquid error" anywhere.
4. Commit on `feature/drop-wall-refresh` (do not push to the store). Show the owner: showcase contact sheet (`review/showcase/contact-sheet-showcase.jpg`, A3 vs B2), reorder before/after shots, size-chart `FINAL_*` mocks.

## (f) Owner-run push commands (paste with `!`, from the repo root, in this order)
Before EACH push the agent runs a read-only freshness pull to a NEW scratch dir and `cmp`s live against `git show abf082b:<file>`; any difference → STOP and merge into the live copy.
```
shopify theme pull --theme 188605497624 --store iacxyv-w5.myshopify.com --path <scratch> --only templates/collection.json --only templates/collection.supreme-leader.json --only templates/collection.gp-template-bk-default.json --only sections/ak-drop-wall.liquid --only templates/product.json
```
(also `grep showcase_` those templates → must be empty.)

**Push 1: inert size-chart files (nothing references them yet)**
```
shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only assets/ak-size-chart.jpg --only snippets/ak-drop-size-chart.liquid
```
Verify: pull both back to scratch and `cmp` == repo. **HARD GATE: if the snippet is not present live byte-identical, do NOT run push 3.**

**Push 2: the drop wall (reorder + showcase)**
```
shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only sections/ak-drop-wall.liquid
```
Verify: pull back + `cmp`; `curl -s https://amerikid.ca/collections/supreme-leader` contains `data-ms="2500"` and the L/XL name order above (page is `no-store`, so immediate); headless Playwright 1440×900 + 390×844 screenshots, cadence ≈2.5s, console clean.

**Push 3: product template (separate command, LAST, only after push 1's gate and a fresh product.json cmp)**
```
shopify theme push --theme 188605497624 --store iacxyv-w5.myshopify.com --nodelete --allow-live --only templates/product.json
```
Verify: pull back + `cmp`; `curl` `/products/sl-l-05`, `/products/sl-xl-02`, `/products/sl-s-01` each contain `ak-size-chart` once; `/products/flag-tee` contains it 0 times; `grep -c "Liquid error"` = 0 on all four; Playwright 1440/390 shots.

## (g) Rollback
- **Before pushing:** copy current HEAD versions to `docs/qa/2026-10-09-drop-wall-pdp/rollback/` (`ak-drop-wall.liquid.live-2026-10-09`, `product.json.live-2026-10-09`).
- **Wall (reorder + showcase together):** `git show abf082b:sections/ak-drop-wall.liquid > sections/ak-drop-wall.liquid`, owner runs the push-2 command, then restore the working tree. Reverting the schema id is safe unless someone saved `showcase_ms` in the editor meanwhile (check collection templates first).
- **Size chart, fastest (no push):** theme editor → Product template → delete the custom-liquid block, or tag individual products `no-size-chart`. **By push:** `git show abf082b:templates/product.json > templates/product.json` and push 3's command. Snippet and asset are inert under `--nodelete` and can stay.
- Never roll back by pushing the snippet away first (that is the order that breaks every product page).

## (h) Docs to update (AGENTS.md: after the approved change)
- `docs/known-fragile-areas.md` top drop block: amend (5) with the 2.5s/.55s cadence, `showcase_ms` (ms, not s), the invariant transition < 900 ms cleanup < 2000 ms min, and the hold-for-image guard (`!complete`, 3-beat cap — never `naturalWidth`). Add (8) the row partition is Liquid capture, buffers reset per row, never CSS `order`. Add (9) the 8:7 cover frame needs `min-height:0`, 4:3 cuts XL shirts, desktop-only padding trim, never cancel grid gaps. Add (10) the size chart: `product.json` is shared by every product; snippet + asset before template; gate = `sl-` prefix or `size-chart` tag, `no-size-chart` wins, tags lower-cased.
- `docs/change-log.md`: new row(s) (DROP-WALL-REFRESH-3 + PDP-SIZE-CHART-1), files, risk, verification.
- New `docs/qa/2026-10-09-drop-wall-pdp/README.md` (measurements, scenarios, push log, rollback copies).
- `docs/superpowers/START-HERE-next-session.md` CURRENT STATE: "showcase after the M row (4s…)" → 2.5s/8:7/`showcase_ms`; add the size chart and the opt-out tag; note 3 templates host the wall.
- `docs/superpowers/HANDOFF-supreme-leader-drop.md` §4–5 if it states the 4s cadence or the wall order.

## (i) Owner decisions
**Genuinely blocking: none.** Each has a safe default that matches the owner's literal words:
| Question | Safe default (ship) | Why non-blocking |
|---|---|---|
| Showcase in place (A3) vs top (B2) | **A3** | B pushes all of row 1 below the fold at 1440×900, undoing the 2026-09-26 goal. Show him the contact sheet; B2 is a follow-up if he insists |
| 2.5s vs 2s | **2500 ms** | He can change it himself in the editor (2000–10000) with no code |
| Are SL-L-05 (cap-sleeve crop), SL-XL-02 (black), SL-L-01 (long sleeve) on the same blank? | **Chart on all `sl-`** (his words: "all #SL tees") | Opt-out is an Admin tag `no-size-chart`, no code. **Ask before push 3**, because L-05 and XL-02 are in stock |
| Inline vs collapsible chart | **Inline** (literal "into the product description") | Collapsible is a later snippet-only change |
| PDP prev/next follow the wall order | **No change** | Out of scope |
| Visible pause control (WCAG 2.2.2) | **None** (pre-existing gap) | Design change for the owner; not a hover pause |
| Mobile "left/right" | Tell him: on phones it reads "in-stock first within each size" | Expectation only |
