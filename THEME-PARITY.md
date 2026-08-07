# BeautyOnTApp native theme parity

## Authoritative source

Every native visual or navigation change must be checked against this export
before implementation:

`/Users/tn/Library/Mobile Documents/com~apple~CloudDocs/Downloads/theme_export__beautyontapp-com-bot-v8-1-9-homepage-2mb-fix-29jul2026__30JUL2026-0643am.zip`

SHA-256:
`c5ff25b1d4e03733228adc2fb9a63d99c6a0aaaf9e8505bf4a01cdbcc900d8de`

The bundled snapshots are byte-identical to that export:

- `Resources/ThemeSnapshot/index.json`
  — `88062f7d355c1c2371b7a8c65645cd79b21be62f98d5da70d7528e71b413109d`
- `Resources/ThemeSnapshot/header-group.json`
  — `ef9ac7ba217cf64d8cbb2bfb1c4e72e49a35047f70f6796844e420ff407d3b62`
- `Resources/ThemeSnapshot/footer-group.json`
  — `e46fc35d241f325401e71d1ead324bf5a9a5cd6312a079bf2fd2c4e012b7171f`

## Native source map

| Native surface | Theme source |
| --- | --- |
| Home order, greeting, hero, rails and copy | `templates/index.json` |
| Primary header and tabs | `sections/header-group.json`, `sections/header-bottom-bar.liquid` |
| Signed-out Home account bar | `sections/sign-in-header.liquid` |
| Profile signed-in/signed-out states | `sections/bottom-bar.liquid`, `sections/footer-group.json` |
| Shop root | `navabr` menu handle configured in `sections/footer-group.json`; menu items are read from Shopify at runtime |
| Product-specific rails | `sections/catagories.liquid` |
| Product gallery, purchase panel and density | `templates/product.json`, `sections/main-product.liquid` |
| Home hero sizing | `sections/custom-collection-slider.liquid` |
| Exclusive benefits footer | `sections/footer-bar.liquid`, `sections/footer-group.json` |
| Physical appearance checks | `../qa/physical-reference-20260730/` and the supplied 30 July screenshots |

## Edit gate

1. Read the mapped theme source.
2. Preserve its wording, destinations, ordering and visibility conditions.
3. Use native SwiftUI interaction and accessibility without changing the
   source-defined customer experience.
4. If neither the export nor a supplied screenshot defines a value, mark it
   `NOT VERIFIED`; do not invent it.
5. Run exact iPhone 17 Pro Max visual and interaction tests before device
   installation or release upload.
