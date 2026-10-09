# 01 — Showcase review (request #1): adversarial findings

Reviewer: showcase subagent, 2026-10-09. READ-ONLY. Nothing in the repo was edited and nothing was pushed or served.
Everything was measured on the LIVE page (https://amerikid.ca/collections/supreme-leader) in my own headless
Chromium (python Playwright). The mockups are client-side CSS/DOM injection into that private page only.
Artifacts are in `review/showcase/`.

## (a) Measured facts

**Live state:** banner is the static squash (`cover_slideshow:false` in collection.json), 13 slides, `data-seconds="4"`, and
`collection.json` has no `showcase_*` keys, so schema defaults apply. The showcase is grid item #10, after the M row.

| viewport | gap above | pad top | shot (square) | name gap + name | pad bottom | gap below | **break total** | share of vh |
|---|---|---|---|---|---|---|---|---|
| 1440x900 | 30.2 | 34.6 | 612 | 17.3 + 28 | 34.6 | 30.2 | **787px** (block 726) | **87%** (block 81%) |
| 1440x800 | 30.2 | 34.6 | 544 | 17.3 + 28 | 34.6 | 30.2 | 719 (block 658) | 90% |
| 1366x700 | 28.7 | 32.8 | 476 | 16.4 + 27 | 32.8 | 28.7 | 642 (block 585) | 92% |
| 1920x1080 | 34 | 40 | 734 | 18 + 35 | 40 | 34 | 935 (block 867) | 87% |
| 390x844 | 16 | 10 | 354 (width-bound) | 8 + 20 | 10 | 16 | 434 (block 402) | 51% |

Main's estimate (≈790px, 88%) is correct. Row-1 titles end at 889 (1440x900, above the fold), 873 (1440x800, **below**,
already known), 747 (1366x700), 1100 (1920x1080, below), and 444 on the phone.

**Product photos:** all 20 front images were downloaded and alpha-bboxed (`bbox.json`). They are transparent PNGs served as webp.
- **S and M (10 shirts):** the shirt fills about 74% of the square's height. There are **11–15% empty rows top and 11–15% bottom**, and the shirt sits about 2% left of centre.
- **L:** 8% top and 7.5–11% bottom. L-05 has 17% bottom.
- **XL: the photos are NOT square** (2318–2357 x 1980–2041, about 1.14–1.19:1) and are **cropped edge-to-edge**: the shirt touches all four image edges.
- At 1440x900 the 787px break therefore holds ≈455px of shirt, 28px of name, **≈157px of empty photo pixels (20%)** and **≈146px of CSS spacing (19%)**. The "space" is about half padding and half empty pixels, but only for S and M. L and XL have almost no slack.

**Bytes per slide** (webp, DPR2 laptop picks 1600w from the current `sizes`): 126–169KB. With a 432px frame it picks 900w, about 50–67KB.

## (b) Mockup files (`review/showcase/`)

- **`contact-sheet-showcase.jpg`** compares all 7 options. Each column has its measurements, desktop top (red line = fold), desktop centred on the showcase, the worst-case XL-02 shot, and phone top plus showcase.
- `shots/<option>_<WxH>_top.png`, `shots/<option>_<WxH>_showcase.png`, `shots/<option>_<WxH>_showcase_sl-xl-02.png` and `..._sl-l-05.png`: full-size screenshots for each option.
  - Options: A0-current, A1-light-trim, A2-medium, A3-strong, A4-main-4x3-crop, B1-top-full, B2-top-strip.
- **`shots/crop-risk-sheet.png`** shows every in-stock shirt plus L-01, L-04 and XL-05 in square, 8:7, 5:4 and 4:3 cover frames. Lost shirt pixels are painted red, with the % lost under each frame.
- Data files: `measure.json`, `mock-measure.json`, `mock-measure-2.json` (the corrected A2, A3, A4 and B2), `crop-risk.json`, `cadence.json`, `cadence2.json`, `bbox.json`. Scripts are in `scripts/`.

| option | CSS (desktop) | 1440x900 break | row-1 titles | 390x844 break |
|---|---|---|---|---|
| A0 current | — | 787 (87%) | 889 above | 434 (51%) |
| A1 light trim | padding-block 0, slide gap 6px | 706 (78%) | 889 above | 412 (49%) |
| A2 medium | A1 + shot `min(100%,64vh,686px)` 8:7 cover | 598 (66%) | 889 above | 367 (43%) |
| **A3 strong** | A1 + shot `min(100%,48vh,548px)` 8:7 cover | **472 (52%)** | 889 above | 367 (43%) |
| A4 main's 4:3 crop | A1 + shot `min(100%,62vh,700px)` 4:3 cover | 513 (57%) | 889 above | 323 (38%) |
| B1 top, full | moved before `.akdw-grid` | 821 (91%) | **1645, below** | row 1 at 649 |
| B2 top, strip | B1 + shot `min(100%,36vh,412px)` 8:7 | 403 (45%) | **1227, below; row-1 IMAGE top 910 > 900** | row 1 at 534, titles 783 |

A3 computed at the other viewports: about 430px at 1440x800 (54%), about 384px at 1366x700 (55%) and about 562px at 1920x1080 (52%).

## (c) Findings, ranked

1. **HIGH, CONFIRMED: Option B reverses the owner's explicit 2026-09-26 goal.** At 1440x900 even the compact strip (B2) pushes **all of row 1 below the fold**: the row-1 image top is at 910px, titles at 1227. B1 puts the titles at 1645, and above the fold you see banner + band + one shirt. The QA README records the banner squash as made "so more of the top row of shirts show". B is defensible only if the owner now values the showcase over row 1. On the phone B2 is milder: row 1 starts at 534 and the first two titles still end above the fold, at 783.
2. **HIGH, CONFIRMED: main's 4:3 cover crop cuts in-stock shirts.** Shirt pixels lost: **XL-02 9.7%, XL-03 8.3%** (collar and hem visibly sliced, see `A4-main-4x3-crop_1440x900_showcase_sl-xl-02.png`) and L-05 1.2%. Sold shirts would lose more: L-01 (long sleeve) 5.3%, L-04 4.8%, XL-05 6.9%.
   - 5:4 still cuts XL-02 by 5.1%.
   - **8:7 is the widest safe frame:** at most 0.17% lost on any of the 20 shirts, only a few edge pixels on the edge-to-edge XL photos.
   - S and M survive even 4:3. The risk sits entirely in the L and XL photography, so a crop ratio tuned on S and M will cut future shirts shot like the XL set.
3. **HIGH, CONFIRMED: changing only the schema does not change the speed.** The JS line `Math.max(3, parseInt(data-seconds,10)||4)` truncates "2.5" to 2 and then clamps it to **3s**. All three must change together: schema (min/default), the Liquid `| default: 4`, and the JS (parseFloat plus a lower floor). Verified with a patched copy: the cadence was exactly 2504–2508ms per step.
4. **MEDIUM, CONFIRMED: the 8:7 frame silently does nothing without `min-height:0`.** `.akdw-show__img{height:100%}` inside an `aspect-ratio` box makes the box grow to the image's square height. My first mock measured 576x576 for an "8/7" frame. Add `min-height:0;overflow:hidden` on `.akdw-show__shot`. Overflow-clip does not affect the focus ring, because the ring uses a negative `outline-offset` and paints inside the box.
5. **MEDIUM, CONFIRMED: slides arrive blank on slow 3G, today, at 4s.** Throttled tests, DPR2, 1440x900, cache disabled, 6 advances each:

   | network | 4s | 3s | 2.5s | 2s |
   |---|---|---|---|---|
   | Slow 3G (current 1600w) | 6/6 blank | 6/6 blank | 6/6 blank | 6/6 blank |
   | Fast 3G | 0 blank | 0 | 0 | 0 |
   | 4G | 0 blank | 0 | 0 | 0 |

   - Speeding up does not create the slow-3G problem, but it removes headroom.
   - A3's smaller frame plus an updated `sizes` (fetches 900w) gives **0/6 blank at 4s** on slow 3G, but still 6/6 at 2.5s.
   - **A one-line "hold until the next image has loaded" guard in `advance()` gives 0 blanks at 2.5s on slow 3G.** The cadence degrades gracefully to 5–7.5s there instead of sliding in empty frames.
6. **MEDIUM, CONFIRMED by geometry: do not cancel the grid gaps with negative margins, and do not trim mobile padding.**
   - The SOLD OUT burst overhangs its tile by `top:-7%`: about 17.5px on desktop (tile 250) and **12px on the phone (tile 169)**.
   - The row right after the showcase is L, which has 4 sold shirts. With padding 0 on the phone, the burst sits **4px** under the "SL-S-01" name (name bottom 1702, next row 1718, minus the 12px overhang). With the gap cancelled it would **overlap** the name on every width.
   - Desktop and mobile gaps also use different clamps: `2.1vw` versus `4vw`. A single negative margin would be wrong on one of them.
   - The phone is already lean at 51% vh. Recommendation: trim padding at **≥750px only**, keep both grid gaps, and leave mobile padding at 10px. The 8:7 crop is fine on mobile: it saves 44px and loses no shirt pixels.
7. **MEDIUM, CONFIRMED: `sizes` must change with the frame.** Otherwise A3 keeps downloading 1600w (169KB) to paint 432 CSS px. The current string bakes in `68vh` and `max-height:1117px` (=760/0.68).
8. **LOW, CONFIRMED: there is no interaction with the `(min-width:750px) and (max-height:740px)` rules.** They target `.akdw-shot` (tiles) and `.akdw-item--sold .akdw-shot::before`, never `.akdw-show__*`. Fragile item (4), its source order, is untouched by A. At 1366x700 A3 renders a 336x294 frame, still bigger than the 210px-tall tiles.
9. **LOW, PLAUSIBLE: WCAG 2.2.2 (Level A).** The carousel auto-starts, runs well over 5s and sits beside other content. It needs a pause/stop/hide mechanism, and a keyboard-focus hold is not one that mouse or touch users can find.
   - This non-conformance already exists at 4s. Going to 2.5s moves from 15 to 24 slide motions per minute, which makes it more salient but does not change its status.
   - Reduced motion, offscreen and hidden-tab holds are already correct.
   - A visible pause button is a design change for the owner. It is NOT the hover pause that fragile-area (5) forbids.
10. **LOW, CONFIRMED: the 900ms `is-leaving` cleanup is safe** while the cadence is at least 1s and the transition is .55–.8s. The invariant is: transition < cleanup < cadence. With a schema min of 2s it holds. Note it in a comment.
11. **LOW, CONFIRMED: the shirts change apparent size as they rotate.** S and M fill 74% of the frame height and XL fills 87%, because of inconsistent photo framing. No CSS crop fixes that. The real fix would be re-exporting the S, M and L fronts tighter, which is an owner decision.
12. **INFO, PLAUSIBLE: Shopify range schema.** Shopify docs (input-settings, "range") say `step` "defaults to 1", that min/max/step/default "can't be string values", and that the value "is returned as a number". There is no stated ban on decimals.
    - I ran Theme Check (shopify-dev-mcp `validate_theme`, scratch theme `review/showcase/schema-test/`) on `min 1.5/2, max 10, step 0.5, default 2.5`, `1500–6000 step 250`, and `1–20 step 0.1` (191 steps). **All passed.**
    - So Theme Check does NOT enforce Shopify's upload-time limit on the number of steps (my recollection: at most 101). Keep the step count small: 2–10 by 0.5 is 17 steps.
    - There are no decimal-step precedents in this repo. If the owner wants zero schema risk: integer `ms` (2000–10000 step 500) with the Liquid dividing by 1000. That is also safe because collection.json stores no value for this id.

## (d) Recommended deltas (proposed, NOT applied): A3 desktop trim + 8:7 safe crop + 2.5s

```diff
@@ sizes on the showcase image_tag (line ~96) @@
-  sizes: '(min-width: 750px) and (max-height: 1117px) 68vh, (min-width: 750px) 760px, (orientation: landscape) 68vh, 92vw',
+  sizes: '(min-width: 750px) and (max-height: 1142px) 48vh, (min-width: 750px) 548px, (orientation: landscape) 48vh, 92vw',

@@ data-seconds (line ~238) @@
-  data-seconds="{{ section.settings.showcase_seconds | default: 4 }}"
+  data-seconds="{{ section.settings.showcase_seconds | default: 2.5 }}"

@@ CSS .akdw-show block @@
   html.ak-drop-page #akdw-{{ section.id }} .akdw-show{
     grid-column:1/-1;
     padding-block:clamp(10px,2.4vw,40px);
   }
+  /* desktop only: the phone keeps 10px so the sold burst (top:-7%, ~12px) in the
+     next row never touches the showcase name. Grid gaps are NOT cancelled. */
+  @media screen and (min-width:750px){
+    html.ak-drop-page #akdw-{{ section.id }} .akdw-show{ padding-block:0; }
+    html.ak-drop-page #akdw-{{ section.id }} .akdw-show__slide{ gap:6px; }
+  }
 ...
   .akdw-show__slide.is-active, .akdw-show__slide.is-leaving{
     visibility:visible;
-    transition:transform .8s cubic-bezier(.65,0,.35,1);
+    transition:transform .55s cubic-bezier(.65,0,.35,1);
   }
 ...
   html.ak-drop-page #akdw-{{ section.id }} .akdw-show__shot{
-    display:block;width:min(100%,68vh,760px);aspect-ratio:1/1;
+    /* 8:7 crops only the transparent rows of the square photos: <=0.17% of any shirt
+       (4:3 cut XL-02 by 9.7%). min-height:0 is required or aspect-ratio is ignored. */
+    display:block;width:min(100%,48vh,548px);aspect-ratio:8/7;min-height:0;overflow:hidden;
   }
   html.ak-drop-page #akdw-{{ section.id }} .akdw-show__img{
-    display:block;width:100%;height:100%;object-fit:contain;
+    display:block;width:100%;height:100%;object-fit:cover;
   }

@@ JS @@
-      var showMs = Math.max(3, parseInt(show.getAttribute('data-seconds'), 10) || 4) * 1000;
+      var showMs = Math.max(2, parseFloat(show.getAttribute('data-seconds')) || 2.5) * 1000;
 ...
         var nxt = slides[showIndex];
+        /* never slide in a blank frame: on a slow link wait a tick for the image */
+        var nimg = nxt.querySelector('img');
+        if (nimg && !(nimg.complete && nimg.naturalWidth)) {
+          showIndex = (showIndex - 1 + slides.length) % slides.length;
+          warm(showIndex + 1);
+          return;
+        }
         cur.classList.remove('is-active');
 ...
-        setTimeout(function () { cur.classList.remove('is-leaving'); }, 900);
+        /* invariant: transition (.55s) < this cleanup (900ms) < min cadence (2s) */
+        setTimeout(function () { cur.classList.remove('is-leaving'); }, 900);

@@ schema @@
-      "min": 3, "max": 10, "step": 1, "unit": "s", "default": 4
+      "min": 2, "max": 10, "step": 0.5, "unit": "s", "default": 2.5
```

- If the owner wants it smaller still, use A2 (`64vh, 686px`) at 66% vh. Swap the two numbers and use `sizes` `64vh / max-height:1072px / 686px`.
- If the owner wants B anyway, take B2 as the only viable shape. Render `show_slides` before `.akdw-grid` when `showcase_after == 'TOP'`; the capture is reused, so the all_products cap is unchanged. Also show the owner the row-1 cost in `B2-top-strip_1440x900_top.png`.
- The docs to update after approval: `docs/known-fragile-areas.md` (drop-wall item 5: cadence and transition, the hold-until-loaded guard, the 8:7 crop rationale and the `min-height:0` trap) and the QA README.

**Speed recommendation: 2.5s with a .55s slide.** That leaves about 1.95s of stillness per shirt: 13 shirts cycle in 32.5s, versus 52s now.
- 2s leaves only 1.45s still, and the cut versus 2.5s is not noticeable enough to be worth it.
- 3s is a timid change for an owner who said "faster".

## (e) Questions only the owner can answer

1. Is row 1 above the fold (the 2026-09-26 goal) still the priority? If yes, B is out. If no, is B2 (row 1 fully below the fold on laptops) acceptable?
2. A3 (shirt about 330px tall on a 1440x900 laptop, block 52% of the screen) or A2 (about 425px tall, 66%)? See the contact sheet.
3. Is 2.5s per shirt "faster" enough, or do you want 2s?
4. Do you want a small visible pause/play control on the showcase (accessibility, WCAG 2.2.2)? This is not a hover pause.
5. Should the S/M/L front photos be re-exported tighter so every shirt shows at the same size in the showcase? The XL set is already tight; the S/M set has about 25% empty rows.
