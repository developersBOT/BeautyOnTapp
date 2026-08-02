# BeautyOnTApp — heart-B monogram

A rebuild of the heart-shaped `B` monogram as a single, production-quality vector.
The letterform, proportions, counters, stroke-weight relationships and colours are
taken from the supplied reference bitmap (2250 × 2251 px); only the *construction*
has been redrawn.

## Files

| File | Use |
|---|---|
| `heart-b-mark.svg` | The mark alone, transparent background, viewBox trimmed to the glyph. Primary reusable asset. |
| `heart-b-mark-on-white.svg` | 1024 × 1024, mark centred on solid white with even padding. |
| `heart-b-mark-on-black.svg` | 1024 × 1024, the reference's own colour pairing. |
| `heart-b-mark-construction.svg` | Editable stroke-based master: 4 Bézier segments + 2 lines describe the whole heart. |
| `heart-b-mark-on-white-4096.png` | 4096 × 4096 raster of the white-background lockup. |
| `heart-b-mark-on-black-4096.png` | 4096 × 4096 raster of the black-background lockup. |

`heart-b-mark.svg` / `-on-white` / `-on-black` carry the mark as one compound path
(`fill-rule="evenodd"`, outer contour + one counter). No strokes, no gradients, no
filters, no embedded raster — it scales and rasterises cleanly at any size.

## Colours

Sampled directly from the reference; nothing else is used anywhere in these files.

| Role | Hex | RGB |
|---|---|---|
| Mark | `#EFE7DD` | 239, 231, 221 |
| Reference ground | `#000000` | 0, 0, 0 |

Note that `#EFE7DD` on white is a deliberately low-contrast pairing. The
`-on-black` lockup is the combination the reference itself uses.

## Construction

All figures in artboard units (1024 × 1024 artboard; mark 599.272 × 680.000,
centred; horizontal symmetry axis at y = 512).

The heart is a single centreline path stroked at a uniform **41.207** weight —
identical to the stem weight and the crossbar weight, so optical weight is even
throughout.

* **Flanks** — two straight edges at exactly 45°, meeting at the tip vertex
  (232.967, 512). The outer corner is a round join of radius 20.604 (half the
  stroke); the inner corner is the natural miter at (262.105, 512).
* **Lobes** — each flank runs straight to its tangent point (469.962, 275.006)
  and then eases into the lobe through a chain of four cubic Béziers.
  The chain is **G2 (curvature-continuous)** end to end: curvature leaves the
  straight flank at exactly zero and runs ∞ → 233 → 183 → 283 → 951 without a
  single inflection, so there are no flat spots, lumps or facets.
* **Cleft** — the two lobes meet at the centreline vertex (683.189, 512); the
  outer edges intersect to form the notch apex at (722.037, 512).
* **Lower half** — an exact mirror of the upper half about y = 512.
* **Stem** — a perfectly vertical bar at x = 487.454, spanning y = 512 ± 116.665
  between its round cap centres.
* **Crossbar** — horizontal, centred on the axis, running from the stem into the
  cleft; it terminates flush on the ring's inner contour, giving a clean
  T-junction with no overlap seam.

The stem and crossbar in the reference sat ≈ 2.9 px (≈ 0.35 % of mark height)
above the heart's axis, and the two halves of the heart differed by up to 4.0 px.
Both were corrected — this rebuild is symmetric to within rasteriser precision.

## Fidelity to the reference

Measured by extracting the sub-pixel 0.5-luminance contour of a 4096 px render
and comparing it with the reference contour, in reference-image pixels
(mark height 841 px):

| Check | Result |
|---|---|
| Model fit to the reference's outer boundary | max 0.13 px, rms 0.03 px (0.016 % of height) |
| Rendered outer contour vs reference | max 2.0 px, rms 1.0 px |
| Rendered counter vs reference | max 2.9 px, rms 1.3 px |
| Mark bounding box | 741.7 × 841.7 vs reference 742 × 841 |
| Self-symmetry of the render | mean 0.009/255 mirror difference |

The residual 1–3 px is the reference's own asymmetry being corrected, not drift:
the reference's two halves disagree with each other by up to 4.0 px, and its stem
and crossbar were off-axis.

The outlined path and the stroke construction rasterise identically — every
differing pixel between the two lies on an anti-aliased edge.
