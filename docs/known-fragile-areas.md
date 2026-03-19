# Known Fragile Areas

## "Do Not Break" Principles
- Do not remove canvas tags (`<canvas>`) or their associated Javascript. The ambient particles and starfield effects are core to the brand.
- Do not normalize typography if it removes the "Impact" font. Hardcoded font declarations exist for a reason.

## Major Fragile Files
- `sections/main-product.liquid`: This file is exceptionally large (2800+ lines). It contains custom canvas implementation (`ak-product-field`), deeply nested CSS overrides for transparency, and layout hacks.
- `layout/theme.liquid`: Contains heavy inline CSS defining color schemes and CSS variables, as well as multiple app embeds. Changing script load order here is risky.
- `templates/page.mystery-box.json`: Contains the Vercel iframe embed wrapped in a highly specific locked layout (`ak-mb-wrap`, `ak-mb-canvas`).

## Fragile Systems
- **Starfield Navigation:** The entire `amerikid-button-wrapper` block (glass menu, canvas background, hover glows) is duplicated across many JSON files. Modifying it requires updating it everywhere or successfully consolidating it first.
- **Brand Overrides:** Many custom sections like `featured-collection2.liquid` use `#collection-{{ section.id }} * { font-family: Impact !important; }`. Refactoring CSS may accidentally break these targeted brand styles.

## DO NOT TOUCH FIRST list
- Do not refactor `sections/main-product.liquid` yet.
- Do not edit or attempt to clean up `templates/page.mystery-box.json` yet.
- Do not reorder JavaScript tags in `theme.liquid` without live browser testing.