# Runtime Test Checklist

Use this checklist to verify the storefront after any approved change is implemented.

## Core Pages
- [ ] **Homepage:** Verify load speed, layout, and that PageFly elements render correctly.
- [ ] **Collection Pages:** Check grid layout, image loading, and that the Impact font is still applied where expected.
- [ ] **Product Pages:** Check `main-product` layout. Ensure the background starfield canvas (`ak-product-field`) renders and animates. Verify Add to Cart functionality. **Count canvases: should not increase.**
- [ ] **Custom Landing Pages:** Spot check pages like "The Collective" or specific collection drops for missing assets.
- [ ] **Mystery Crate Page:** Verify the iframe loads the Vercel app. Verify the "Unlocking Soon" overlay remains visible and intact. **Check console for crate.glb status.**

## Navigation and Interactivity
- [ ] **Mobile Menu / Drawer:** Click the "MENU" label. Ensure the drawer opens and closes properly. Check that the close "X" is positioned correctly.
- [ ] **Header/Footer:** Check for missing elements or misaligned global navigation.
- [ ] **Cart Drawer / Cart Page:** Add an item to the cart. Verify the AJAX cart drawer slides out without breaking the layout.
- [ ] **Animations:** Ensure hover effects (glows, neon borders) on buttons and the continuous wrapper glow in the nav still function.

## Technical Checks
- [ ] **Console Errors:** Open browser developer tools. Ensure no **new** 404 errors or Javascript errors are present. Monitor `video-player` registry error.
- [ ] **Builder Regressions:** Verify that PageFly pages still function. Check that removing EComposer/GemPages remnants didn't break global styles (if applicable).
- [ ] **Asset Loading:** Check Network tab for `cdn.ecomposer.app` or `gp-global.css` calls.
- [ ] **Responsive Design:** Resize the viewport down to 320px. Ensure neon borders, canvases, and text do not break the horizontal bounds.
