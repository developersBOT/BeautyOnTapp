# Product infographic renderer

Square 2048 x 2048 product-page infographics for the Shopify store, built from a
packshot plus a JSON spec of verified strings. Text is rendered character for
character from the spec; the packshot is placed as-is (matted, never redrawn);
the background gradient is sampled from the packaging's dominant colour.

```
pip install pillow numpy
python3 tool/infographic/render.py tool/infographic/specs/niacinamide-body-mist.json
```

The packshot URL in the spec is the product's featured image on the Shopify CDN.
If the CDN is not reachable from where you run this, download the file and pass it in:

```
python3 tool/infographic/render.py tool/infographic/specs/niacinamide-body-mist.json --image ~/Downloads/packshot.png
```

Output lands in `tool/infographic/out/` (git-ignored). Inter is fetched into
`tool/infographic/fonts/` on first run (git-ignored); Liberation Sans is the fallback.

Layouts implemented: `ref5` (mist / toner / cleanser / moisturiser). Others are
registered in `LAYOUTS` in `render.py` as they are needed.

Test the pipeline without the real packshot:

```
python3 tool/infographic/make_standin.py /tmp/standin.png
python3 tool/infographic/render.py tool/infographic/specs/niacinamide-body-mist.json --image /tmp/standin.png --proof --cut-floor-shadow --debug
```

Options worth knowing:

- `--tol N` overrides the background tolerance (estimated from the border by default).
- `--cut-floor-shadow` removes a photographed floor shadow the matte left behind. Check
  the magenta matte preview from `--debug` before trusting it on white packaging.
- The renderer refuses specs that break the text rules (4 words per headline line,
  8 words per benefit, three benefits for REF5, four text blocks, all-caps REF5 headline).
