# Drop Amendment QA - 2026-09-09

Target: unpublished theme 188605497624 only. No publication or protected-theme edits.

## Changes

- Landing uses SL Website Grid (1920x1080), proportionally covering the viewport.
  Portrait screens crop the sides. Existing print effects and entry interaction remain.
- Three 1500x500 covers cycle in order every 10 seconds with a one-second dissolve.
  AK Drop Wall > Cycle all three covers every 10 seconds defaults on and overrides
  static artwork choices. Disable it to use Cover artwork option or the image picker.
- Banner is full-width at its natural 3:1 ratio, with no height cap or side gaps.
  The owner approved increasing its height: this supersedes the old desktop
  first-row-above-fold target. Do not reinstate containment within a short box.
- Lower AMERIKID availability strip removed. Large Korean headline remains and
  continues on hover/focus. Explicit pause button pauses banner/headline; reduced
  motion disables autoplay. Background tabs suspend the cover timer.
- Drop-only individual product gallery enlarged; quantity selector hidden with its
  existing value of one retained. Normal inventory enforcement remains Shopify's job.
- Previous/next links follow S01 through XL05, wrapping at either end; All shirts
  returns to the collection. Native product pages, media gallery and checkout remain.
- Mobile collection retains independent horizontal rows with two larger tiles across.
  Cloned tiles retain clickable product URLs while staying out of keyboard tab order.

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
- Real timer advanced through Covers 1, 2, 3 on desktop and mobile. Hover animation
  state is running. Explicit pause held the slide for >10 seconds. Reduced-motion
  mode held the initial slide and disabled the Korean headline animation.

## Screenshots

Landing and each banner are captured at 390x844 and 1440x900. Final cover captures
show the actual timed slideshow, not substituted browser image sources.
The Shopify draft preview bar is visible. Product screenshots show enlarged media
and navigation. These are review images, not evidence of a completed checkout.

## Remaining

- Owner final visual QA and manual publication decision.
- Existing mobile drift pause/resize behavior was not comprehensively reworked here.
- No agent publication. Owner publishes in Admin after approval.
