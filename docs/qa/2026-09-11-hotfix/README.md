# Landing takeover and mobile image hotfix

Theme 188605497624 is LIVE. Only `sections/ak-drop-landing.liquid` and
`sections/ak-drop-wall.liquid` were uploaded with explicit live permission and
`--nodelete`. Protected Notebook and Dark themes were not touched.

## Cause and changes

- A delayed PageFly homepage layer covered the drop landing and linked to
  `/collections/master-collection`. This reproduced with fresh browser contexts,
  not just cached owner sessions. The previous opaque-exit fix was insufficient.
- CSS in the drop landing now hides `#__pf` and `.ak-landing` only while the
  drop landing exists in the document. PageFly on other pages is unchanged.
- Removed mobile staggered image timers. Front/back cross-dissolve is now
  limited to genuine hover/fine-pointer devices. Touch opens the product directly.
- Tile artwork, bouncing logo, static Cover 1, banners, grid, PDP and cart unchanged.

## Live checks

Fresh Chrome contexts: touch mobile 390x844 and desktop 1440x900.
Landing held for 31 seconds on each: live theme ID confirmed; drop landing
remained topmost and legacy landing had no visible bounds. Background click
opened `/collections/supreme-leader`. Separate logo handler check also opened
that collection.

Mobile collection held for 10 seconds: 20 items, zero flipped classes, every
front opacity 1 and back opacity 0. Single tap opened `/products/sl-s-01`.
Desktop collection also had 20 front-facing items at rest; hovering the first
available item revealed the back at opacity 1 after the dissolve.

Theme Check: no errors in either changed section; one existing RemoteAsset
warning in the wall. Whole-repository legacy lint errors remain outside scope.

Screenshots: `landing-mobile.png`, `landing-desktop.png`, `grid-mobile.png`,
`grid-desktop.png`.
