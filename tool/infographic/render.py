#!/usr/bin/env python3
"""Render a square (2048 x 2048) product-page infographic from a packshot and a text spec.

Usage
-----
    python3 tool/infographic/render.py tool/infographic/specs/niacinamide-body-mist.json
    python3 tool/infographic/render.py SPEC.json --image ./packshot.png --out ./final.png
    python3 tool/infographic/render.py SPEC.json --image ./standin.png --proof

The spec names the packshot (URL or local path), the layout and the exact strings.
Every string is drawn character for character; the script never adds copy of its own.
The background is a soft single-hue gradient sampled from the packaging's dominant colour.
"""
from __future__ import annotations

import argparse
import colorsys
import io
import json
import os
import sys
import urllib.request
import zipfile

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

HERE = os.path.dirname(os.path.abspath(__file__))
FONT_DIR = os.path.join(HERE, "fonts")
OUT_DIR = os.path.join(HERE, "out")
CANVAS = 2048
MARGIN = 128
CHARCOAL = (43, 43, 43, 255)
FLOOR_Y = CANVAS - 212  # the wet surface the product stands on

INTER_ZIP = "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
INTER_FILES = {"bold": "Inter-Bold.ttf", "medium": "Inter-Medium.ttf", "regular": "Inter-Regular.ttf"}
FALLBACK_FONTS = {
    "bold": "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "medium": "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    "regular": "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
}

# --------------------------------------------------------------------------- helpers


def fetch(url: str, timeout: int = 120) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (infographic-renderer)"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def ensure_fonts(allow_download: bool = True) -> dict:
    paths = {k: os.path.join(FONT_DIR, v) for k, v in INTER_FILES.items()}
    if all(os.path.exists(p) for p in paths.values()):
        return paths
    if allow_download:
        try:
            os.makedirs(FONT_DIR, exist_ok=True)
            print(f"fonts: downloading Inter from {INTER_ZIP}", file=sys.stderr)
            with zipfile.ZipFile(io.BytesIO(fetch(INTER_ZIP))) as zf:
                for name in zf.namelist():
                    base = os.path.basename(name)
                    if name.startswith("extras/ttf/") and base in INTER_FILES.values():
                        with open(os.path.join(FONT_DIR, base), "wb") as fh:
                            fh.write(zf.read(name))
            if all(os.path.exists(p) for p in paths.values()):
                return paths
        except Exception as exc:  # noqa: BLE001
            print(f"fonts: could not fetch Inter ({exc}); falling back to Liberation Sans", file=sys.stderr)
    missing = [p for p in FALLBACK_FONTS.values() if not os.path.exists(p)]
    if missing:
        sys.exit(f"fonts: no usable font found (missing {missing}); run with network or place Inter TTFs in {FONT_DIR}")
    return FALLBACK_FONTS


def load_packshot(src: str) -> Image.Image:
    if src.lower().startswith(("http://", "https://")):
        print(f"packshot: downloading {src}", file=sys.stderr)
        im = Image.open(io.BytesIO(fetch(src)))
    else:
        im = Image.open(src)
    return im.convert("RGBA")


def auto_tolerance(rgb: Image.Image) -> int:
    """Flood-fill tolerance from the noise in a 4 px border ring (sum of RGB deltas)."""
    arr = np.asarray(rgb, dtype=np.int16)
    ring = np.concatenate([arr[:4].reshape(-1, 3), arr[-4:].reshape(-1, 3), arr[:, :4].reshape(-1, 3), arr[:, -4:].reshape(-1, 3)])
    bg = np.median(ring, axis=0)
    noise = np.percentile(np.abs(ring - bg).sum(1), 99)
    return int(np.clip(noise + 6, 12, 60))


def matte(im: Image.Image, tol: int | None = None, feather: float = 1.2) -> Image.Image:
    """Make the background transparent without touching white areas inside the product.

    Flood-fills from the border, so only background connected to the edge is removed.
    Images that already carry real transparency are returned untouched.
    """
    alpha = np.asarray(im.getchannel("A"))
    border = np.concatenate([alpha[0], alpha[-1], alpha[:, 0], alpha[:, -1]])
    if (border < 250).mean() > 0.5:
        print("matte: packshot already has a transparent background; using it as-is", file=sys.stderr)
        return im
    rgb = im.convert("RGB")
    if tol is None:
        tol = auto_tolerance(rgb)
    print(f"matte: flood-fill tolerance {tol}", file=sys.stderr)
    w, h = rgb.size
    sentinel = (1, 254, 2)
    work = rgb.copy()
    seeds = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]
    for seed in seeds:
        if work.getpixel(seed) != sentinel:
            ImageDraw.floodfill(work, seed, sentinel, thresh=tol)
    bg = np.all(np.asarray(work) == np.array(sentinel, dtype=np.uint8), axis=2)
    mask = Image.fromarray(((~bg) * 255).astype(np.uint8), "L")
    mask = mask.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(feather))
    out = im.copy()
    out.putalpha(mask)
    return out


def cut_floor_shadow(im: Image.Image, chroma_max: int = 16, lum_min: int = 170) -> Image.Image:
    """Opt-in: drop neutral, light pixels (a photographed floor shadow) that sit below or beside the product.

    'Strong' pixels are coloured or clearly darker than the background; anything neutral and light
    outside their per-row extent, or below their last row, is treated as shadow and made transparent.
    Check the matte preview (--debug) after using this on white packaging.
    """
    arr = np.asarray(im).astype(np.int16)
    rgb, a = arr[:, :, :3], arr[:, :, 3]
    lum, chroma = rgb.mean(2), rgb.max(2) - rgb.min(2)
    kept = a > 8
    strong = kept & ((chroma > chroma_max) | (lum < lum_min))
    rows = np.where(strong.any(1))[0]
    if rows.size == 0:
        return im
    neutral_light = kept & ~strong
    cut = np.zeros_like(kept)
    last = int(rows.max())
    cut[last + 1:, :] = neutral_light[last + 1:, :]
    for y in rows:
        xs = np.where(strong[y])[0]
        left, right = int(xs.min()), int(xs.max())
        cut[y, :left] |= neutral_light[y, :left]
        cut[y, right + 1:] |= neutral_light[y, right + 1:]
    new_a = a.copy()
    new_a[cut] = 0
    mask = Image.fromarray(new_a.astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(0.8))
    out = im.copy()
    out.putalpha(mask)
    print(f"matte: floor-shadow cut removed {int(cut.sum())} px", file=sys.stderr)
    return out


def trim(im: Image.Image, pad: int = 4) -> Image.Image:
    bbox = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    if not bbox:
        sys.exit("packshot: nothing left after matting; lower --tol")
    l, t, r, b = bbox
    return im.crop((max(0, l - pad), max(0, t - pad), min(im.width, r + pad), min(im.height, b + pad)))


def matte_preview(im: Image.Image) -> Image.Image:
    """The cutout over magenta so leaks and leftovers are obvious."""
    bg = Image.new("RGBA", im.size, (255, 0, 255, 255))
    bg.alpha_composite(im)
    return bg.convert("RGB")


def resize_rgba(im: Image.Image, size: tuple[int, int]) -> Image.Image:
    # premultiplied resize avoids fringes along the soft mask edge
    return im.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA")


def dominant_hsv(im: Image.Image):
    """Median hue/sat/val of the packaging's most common saturated colour, or None if it is neutral."""
    arr = np.asarray(im, dtype=np.float32) / 255.0
    solid = arr[:, :, 3] > 0.9
    rgb = arr[:, :, :3][solid]
    if rgb.shape[0] < 200:
        return None
    mx, mn = rgb.max(1), rgb.min(1)
    delta = mx - mn
    val = mx
    sat = np.where(mx > 0, delta / np.maximum(mx, 1e-6), 0.0)
    keep = (sat > 0.22) & (val > 0.25) & (val < 0.985)
    if keep.sum() < 200:
        return None
    m, d, s, v = rgb[keep], delta[keep] + 1e-6, sat[keep], val[keep]
    r, g, b = m[:, 0], m[:, 1], m[:, 2]
    mx_k = m.max(1)
    hue = np.where(mx_k == r, ((g - b) / d) % 6.0, np.where(mx_k == g, (b - r) / d + 2.0, (r - g) / d + 4.0)) * 60.0
    hist, edges = np.histogram(hue, bins=36, range=(0.0, 360.0))
    smooth = np.roll(hist, 1) + 2 * hist + np.roll(hist, -1)
    bi = int(smooth.argmax())
    centre = (edges[bi] + edges[bi + 1]) / 2.0
    sel = np.abs(((hue - centre + 180.0) % 360.0) - 180.0) <= 15.0
    return float(np.median(hue[sel])), float(np.median(s[sel])), float(np.median(v[sel]))


def palette_from(hsv):
    """Soft single-hue gradient (top, bottom, floor) in the packaging's hue."""
    if hsv is None:
        print("palette: packaging reads as neutral; using a warm neutral gradient", file=sys.stderr)
        return (250, 247, 243), (236, 231, 225), (228, 222, 215)
    hue, sat, _ = hsv
    h = hue / 360.0
    s_top, s_bot, s_floor = min(0.10, sat * 0.35), min(0.22, sat * 0.7), min(0.28, sat * 0.85)

    def rgb(s, v):
        return tuple(int(round(c * 255)) for c in colorsys.hsv_to_rgb(h, s, v))

    return rgb(s_top, 0.99), rgb(s_bot, 0.955), rgb(s_floor, 0.915)


def gradient_canvas(palette) -> Image.Image:
    top, bottom, floor = (np.array(c, dtype=np.float32) for c in palette)
    t = np.linspace(0.0, 1.0, CANVAS, dtype=np.float32)[:, None]
    rows = top * (1 - t) + bottom * t  # (H, 3)
    # wet-surface floor: smooth transition around FLOOR_Y
    y = np.arange(CANVAS, dtype=np.float32)[:, None]
    k = np.clip((y - (FLOOR_Y - 36)) / 72.0, 0.0, 1.0)
    k = k * k * (3 - 2 * k)
    rows = rows * (1 - k) + floor * k
    img = np.repeat(rows[:, None, :], CANVAS, axis=1)
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def font_at(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size)


def text_width(font, text: str, tracking: float = 0.0) -> float:
    if tracking == 0:
        return font.getlength(text)
    return sum(font.getlength(ch) for ch in text) + tracking * (len(text) - 1)


def fit_font(path: str, size: int, lines: list[str], max_w: float, min_size: int, tracking_em: float = 0.0):
    while size > min_size:
        f = font_at(path, size)
        if all(text_width(f, ln, tracking_em * size) <= max_w for ln in lines):
            return f, tracking_em * size
        size -= 2
    f = font_at(path, min_size)
    for ln in lines:
        if text_width(f, ln, tracking_em * min_size) > max_w:
            sys.exit(f"text: '{ln}' does not fit on one line even at the minimum size; shorten it")
    return f, tracking_em * min_size


def draw_centred(draw: ImageDraw.ImageDraw, y: float, text: str, font, fill, tracking: float = 0.0) -> None:
    x = (CANVAS - text_width(font, text, tracking)) / 2.0
    if tracking == 0:
        draw.text((x, y), text, font=font, fill=fill)
        return
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += font.getlength(ch) + tracking


def pack_lines(text: str, max_words: int) -> list[str]:
    words = text.split()
    n_lines = max(1, -(-len(words) // max_words))
    per = -(-len(words) // n_lines)
    return [" ".join(words[i:i + per]) for i in range(0, len(words), per)]


def soft_ellipse(size: tuple[int, int], colour, alpha: float, blur: float) -> Image.Image:
    w, h = size
    pad = int(blur * 3)
    layer = Image.new("RGBA", (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse((pad, pad, pad + w, pad + h), fill=(*colour, int(255 * alpha)))
    return layer.filter(ImageFilter.GaussianBlur(blur))


def reflection(prod: Image.Image, max_h: int, frac: float = 0.42, strength: float = 0.32, blur: float = 3.0) -> Image.Image:
    h = max(1, min(int(prod.height * frac), max_h))
    refl = ImageOps.flip(prod).crop((0, 0, prod.width, h))
    a = np.asarray(refl.getchannel("A"), dtype=np.float32)
    ramp = strength * (1.0 - np.linspace(0.0, 1.0, h, dtype=np.float32)) ** 1.7
    refl.putalpha(Image.fromarray(np.clip(a * ramp[:, None], 0, 255).astype(np.uint8), "L"))
    return refl.filter(ImageFilter.GaussianBlur(blur))


# --------------------------------------------------------------------------- rules


def check_text_rules(text: dict, layout: str) -> list[str]:
    problems = []
    blocks = 0
    headline = text.get("headline", "")
    if headline:
        blocks += 1
        for ln in pack_lines(headline, 4):
            if len(ln.split()) > 4:
                problems.append(f"headline line over 4 words: '{ln}'")
        if layout == "ref5" and headline != headline.upper():
            problems.append("REF5 needs an all-caps headline; put the caps in the spec, the renderer never rewrites text")
    if text.get("subheader"):
        blocks += 1
    benefits = text.get("benefits", [])
    if benefits:
        blocks += 1
        for b in benefits:
            if len(b.split()) > 8:
                problems.append(f"benefit over 8 words: '{b}'")
        if layout == "ref5" and len(benefits) != 3:
            problems.append(f"REF5 stacks exactly three benefits; spec has {len(benefits)}")
    if text.get("footer"):
        blocks += 1
    if blocks > 4:
        problems.append(f"{blocks} text blocks; maximum is 4")
    return problems


# --------------------------------------------------------------------------- layouts


def layout_ref5(text: dict, product: Image.Image, fonts: dict, palette) -> Image.Image:
    """REF5: all-caps centred headline, subheader, three stacked benefits, product on a wet surface."""
    canvas = gradient_canvas(palette)
    draw = ImageDraw.Draw(canvas)
    max_w = CANVAS - 2 * MARGIN
    y = 150.0

    head_lines = pack_lines(text["headline"], 4)
    head_font, tr = fit_font(fonts["bold"], 142, head_lines, max_w, 88, tracking_em=0.035)
    for ln in head_lines:
        draw_centred(draw, y, ln, head_font, CHARCOAL, tr)
        y += head_font.size * 1.06
    y += 26

    if text.get("subheader"):
        sub_font, _ = fit_font(fonts["medium"], 60, [text["subheader"]], max_w, 40)
        draw_centred(draw, y, text["subheader"], sub_font, CHARCOAL)
        y += sub_font.size * 1.3 + 40

    benefits = text.get("benefits", [])
    if benefits:
        ben_font, _ = fit_font(fonts["regular"], 54, benefits, max_w, 36)
        for b in benefits:
            draw_centred(draw, y, b, ben_font, CHARCOAL)
            y += ben_font.size * 1.45

    # product zone: everything left between the copy and the floor
    top = y + 48
    zone_h = FLOOR_Y - top
    zone_w = CANVAS - 2 * MARGIN
    scale = min(zone_h / product.height, zone_w / product.width)
    pw, ph = int(product.width * scale), int(product.height * scale)
    prod = resize_rgba(product, (pw, ph))
    px, py = (CANVAS - pw) // 2, FLOOR_Y - ph

    shadow = soft_ellipse((int(pw * 0.86), 54), (40, 36, 34), 0.22, 22)
    canvas.alpha_composite(shadow, (CANVAS // 2 - shadow.width // 2, FLOOR_Y - shadow.height // 2 - 6))
    canvas.alpha_composite(reflection(prod, CANVAS - FLOOR_Y), (px, FLOOR_Y))
    sheen = soft_ellipse((int(pw * 1.7), 96), (255, 255, 255), 0.32, 34)
    canvas.alpha_composite(sheen, (CANVAS // 2 - sheen.width // 2, FLOOR_Y + 8 - sheen.height // 2))
    canvas.alpha_composite(prod, (px, py))

    if text.get("footer"):
        foot_font, _ = fit_font(fonts["regular"], 34, [text["footer"]], max_w, 24)
        draw_centred(draw, CANVAS - 92, text["footer"], foot_font, CHARCOAL)
    return canvas


LAYOUTS = {"ref5": layout_ref5}


def stamp_proof(canvas: Image.Image, fonts: dict) -> None:
    band = Image.new("RGBA", (CANVAS, 72), (43, 43, 43, 200))
    canvas.alpha_composite(band, (0, 0))
    draw = ImageDraw.Draw(canvas)
    f = font_at(fonts["bold"], 34)
    draw_centred(draw, 16, "LAYOUT PREVIEW  ·  STAND-IN PRODUCT  ·  NOT FOR PUBLICATION", f, (255, 255, 255, 255))


# --------------------------------------------------------------------------- main


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("spec", help="JSON spec (see specs/)")
    ap.add_argument("--image", help="packshot path or URL; overrides the spec")
    ap.add_argument("--out", help="output PNG path")
    ap.add_argument("--tol", type=int, help="background flood-fill tolerance (sum of RGB deltas); default: estimated from the border")
    ap.add_argument("--cut-floor-shadow", action="store_true", help="remove a photographed floor shadow left behind by the matte")
    ap.add_argument("--debug", action="store_true", help="also write the cutout over magenta next to the output")
    ap.add_argument("--proof", action="store_true", help="stamp the image as a stand-in layout preview")
    ap.add_argument("--no-font-download", action="store_true")
    args = ap.parse_args()

    with open(args.spec, encoding="utf-8") as fh:
        spec = json.load(fh)
    text = spec["text"]
    layout_name = spec.get("layout", "ref5")
    problems = check_text_rules(text, layout_name)
    if problems:
        sys.exit("text rules violated:\n  " + "\n  ".join(problems))
    layout = LAYOUTS.get(layout_name)
    if layout is None:
        sys.exit(f"layout '{layout_name}' is not implemented; available: {sorted(LAYOUTS)}")

    fonts = ensure_fonts(not args.no_font_download)
    src = args.image or spec["image"]
    product = matte(load_packshot(src), tol=args.tol)
    if args.cut_floor_shadow:
        product = cut_floor_shadow(product)
    product = trim(product)
    hsv = dominant_hsv(product)
    palette = palette_from(hsv)

    canvas = layout(text, product, fonts, palette)
    if args.proof:
        stamp_proof(canvas, fonts)

    out = args.out or os.path.join(OUT_DIR, f"{spec.get('handle', 'product')}-infographic-2048{'-proof' if args.proof else ''}.png")
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    canvas.convert("RGB").save(out, "PNG", optimize=True)
    if args.debug:
        matte_preview(product).save(os.path.splitext(out)[0] + "-matte.png", "PNG")

    placed = [text.get("headline"), text.get("subheader"), *text.get("benefits", []), text.get("footer")]
    print("layout:", layout_name)
    print("strings placed, in order:", " | ".join(f'"{s}"' for s in placed if s))
    print("packaging hue:", None if hsv is None else f"{hsv[0]:.0f}deg sat={hsv[1]:.2f}", "palette:", palette)
    print("product pixels (trimmed):", product.size)
    print("wrote:", out)


if __name__ == "__main__":
    main()
