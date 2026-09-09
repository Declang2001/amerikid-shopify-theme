# Drop Amendment QA - 2026-09-09

Target: unpublished theme 188605497624 only. No publication or protected-theme edits.

## Changes

- Landing uses SL Website Grid (1920x1080), proportionally covering the viewport.
  Portrait screens crop the sides. Existing print effects and entry interaction remain.
- Three 1500x500 covers plus the original Supreme Leader postcard cycle in order
  every 10 seconds with a one-second dissolve. The postcard is center-cropped to
  the stable 3:1 banner shape. AK Drop Wall > Cycle all four images every 10 seconds
  defaults on and overrides
  static artwork choices. Disable it to use Cover artwork option or the image picker.
- Banner is full-width at its natural 3:1 ratio, with no height cap or side gaps.
  The owner approved increasing its height: this supersedes the old desktop
  first-row-above-fold target. Do not reinstate containment within a short box.
- Lower AMERIKID availability strip removed. Large Korean headline remains and
  continues on hover/focus. No visible pause/play control, per owner request;
  reduced motion disables autoplay. Background tabs suspend the cover timer.
- Drop-only individual product gallery enlarged; quantity selector hidden with its
  existing value of one retained. Normal inventory enforcement remains Shopify's job.
- Previous/next links follow S01 through XL05, wrapping at either end; All shirts
  returns to the collection. Native product pages, media gallery and checkout remain.
- Mobile is a stationary two-column, ten-row grid, following the owner's clarified
  Palace reference. Desktop stays five columns. Horizontal drift code and clones
  removed; all 20 tiles are originals. Front/back dissolve behavior retained.

## Verification

- Before changes: quantity selector visible and previous/next navigation absent.
- After upload: verified Shopify.theme.id = 188605497624 in browser.
- Quantity selector hidden; input remains 1; next link S01 -> S02 works.
- Added SL-S-02 through the visible add-to-cart button, verified one unit in cart,
  then removed that test item. No checkout or purchase performed.
- 20 original collection tiles; no horizontal page overflow at tested widths.
- Changed Liquid files pass Theme Check with no errors; one RemoteAsset warning
  remains on the custom-URL-capable banner. Repository-wide lint has unrelated errors.
- Owner screenshot clarified the lower strip meant the collection availability line;
  confirmed it is now absent from the rendered DOM.
- Confirmed 3:1 desktop banner ratio; mobile spans x=0 to x=390 at 390px viewport.
- Initially verified real 10-second timer for Covers 1, 2, 3 and reduced-motion
  behavior. Final four-slide cycle verified with Playwright's controlled browser
  clock at 390, 1440 and 1920px widths, without substituting image sources.
- Final state: no pause button, exactly 20 cells, two mobile columns / five desktop
  columns, mobile positions unchanged over 1.5 seconds, no horizontal overflow.

## Screenshots

Landing and each banner are captured at 390x844 and 1440x900. Final cover captures
show the actual timed slideshow, not substituted browser image sources. The
final captures fast-forward CSS transitions to show each slide cleanly; timing
was checked separately with the browser clock.
The Shopify draft preview bar is visible. Product screenshots show enlarged media
and navigation. These are review images, not evidence of a completed checkout.

## Remaining

- Owner final visual QA and manual publication decision.
- Accessibility limitation: owner requested removing the visible motion control;
  reduced-motion support remains but is not a replacement for a general pause UI.
- No agent publication. Owner publishes in Admin after approval.
