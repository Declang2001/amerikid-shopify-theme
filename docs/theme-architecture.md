# Theme Architecture

## Base Framework
- The underlying structure is **Shopify Dawn** (cart drawers, snippets like `facets.liquid`, `price.liquid`, standard JSON template architecture).

## Custom Amerikid Overrides
- **Font Forcing:** "Impact" font is frequently forced via inline styles or custom CSS blocks targeting specific sections.
- **Glass Navigation:** A highly custom navigation drawer with tilt effects and a "MENU" label, combined with a starfield canvas.
- **Canvases:** Multiple HTML `<canvas>` elements used for particle effects (found in nav, product pages, and the mystery crate page).

## Page Builder Traces
The repository shows evidence of three separate page builders, which likely contributes to lag:
- **PageFly:** Contains `layout/theme.pagefly.liquid`, `assets/pagefly-main.css`, `snippets/pagefly-app-header.liquid`.
- **GemPages:** Contains `layout/theme.gempages.blank.liquid`, `snippets/gp-head.liquid`, `assets/gp-global.css`, and multiple `.gem-` backup templates.
- **EComposer:** Contains `layout/ecom.liquid`, `snippets/ecom_header.liquid`, `snippets/ecom_footer.liquid`.

## Key Directories and Files
- `layout/theme.liquid`: The main entry point. Currently includes `ecom_header`, `gameball`, `pagefly-app-header`, and large inline styling blocks.
- `templates/`: Contains massive JSON template sprawl. Over 15 `collection.[name].json` templates exist, almost all containing a duplicated `custom_liquid` block for the navigation.
- `sections/`: Contains duplicate variations of core sections (e.g., `featured-collection.liquid` vs `featured-collection2.liquid`, and various `image-banner-*.liquid` files).
- `assets/`: Contains standard Dawn assets (`base.css`, `global.js`) mixed with builder assets (`gp-global.css`, `pagefly-animation.css`) and large media (`sparkle.gif`).

## Unproven / Needs Runtime Verification
- **Active Builder:** It is Unknown which of the three page builders is actively controlling current live pages versus which are just leftover scripts.
- **Asset Usage:** It is Unknown if `assets/gp-global.css` is required globally or if it can be conditionally loaded.