#!/usr/bin/env python3
"""Draw a clearly-labelled stand-in packshot so the renderer can be tested without the real product image."""
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

out = sys.argv[1] if len(sys.argv) > 1 else "standin.png"
W = H = 1080
im = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(im)
# soft floor shadow so the matting has to cope with one
sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(sh).ellipse((330, 905, 750, 965), fill=(0, 0, 0, 70))
im.paste(Image.alpha_composite(im.convert("RGBA"), sh.filter(ImageFilter.GaussianBlur(12))).convert("RGB"))
d = ImageDraw.Draw(im)
# bottle body, neck, spray head
d.rounded_rectangle((385, 300, 695, 935), radius=48, fill=(158, 196, 214))
d.rectangle((500, 205, 580, 305), fill=(120, 120, 124))
d.rounded_rectangle((470, 150, 610, 215), radius=18, fill=(70, 70, 74))
d.rectangle((596, 160, 650, 182), fill=(70, 70, 74))
# label with white areas inside the product (must survive matting)
d.rounded_rectangle((420, 470, 660, 840), radius=16, fill="white")
f1 = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
f2 = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 26)
for y, s, f in ((520, "STAND-IN", f1), (575, "NOT THE", f2), (610, "PRODUCT", f2), (700, "for layout", f2), (735, "testing only", f2)):
    w = d.textlength(s, font=f)
    d.text(((W - w) / 2, y), s, font=f, fill=(60, 60, 60))
im.save(out)
print("wrote", out)
