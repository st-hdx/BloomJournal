#!/usr/bin/env python3
"""Render the gradient headline banner used across all App Store screenshots
onto an arbitrary raw screenshot. Generalized from update_hero_caption*.py so
new screenshots (not just the hero) can be captioned with the same style.

Usage:
    python3 scripts/add_caption.py <locale: ja|en> <src.png> <dst.png> <line1> [line2]
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFont

# Override via CAPTION_BAND_HEIGHT env var when a screen's own content sits
# higher up than usual (e.g. a sheet whose header is shorter than a full
# screen), so the band doesn't cut across real content below it.
BAND_HEIGHT = int(os.environ.get("CAPTION_BAND_HEIGHT", "578"))

# Sampled corners of the established diagonal gradient band (same as
# update_hero_caption.py / update_hero_caption_en.py).
TL = (232, 157, 39)
TR = (222, 114, 113)
BL = (229, 148, 56)
BR = (219, 105, 126)

FONTS = {
    "ja": {"path": "/System/Library/Fonts/ヒラギノ角ゴシック W8.ttc", "index": 0, "size": 78, "spacing": 18},
    "en": {"path": "/System/Library/Fonts/Avenir Next.ttc", "index": 8, "size": 76, "spacing": 16},
}


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make_gradient(w, h):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        ty = y / (h - 1)
        left = lerp(TL, BL, ty)
        right = lerp(TR, BR, ty)
        for x in range(w):
            tx = x / (w - 1)
            px[x, y] = lerp(left, right, tx)
    return img


def main():
    if len(sys.argv) not in (5, 6):
        print(__doc__)
        sys.exit(2)
    locale, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
    lines = sys.argv[4:]

    spec = FONTS[locale]
    img = Image.open(src).convert("RGB")
    w, h = img.size

    band = make_gradient(w, BAND_HEIGHT)
    img.paste(band, (0, 0))

    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(spec["path"], spec["size"], index=spec["index"])

    font_size, line_spacing = spec["size"], spec["spacing"]
    total_h = len(lines) * font_size + (len(lines) - 1) * line_spacing
    y = (BAND_HEIGHT - total_h) // 2 + 10
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        line_w = bbox[2] - bbox[0]
        x = (w - line_w) // 2
        draw.text((x + 2, y + 2), line, font=font, fill=(0, 0, 0, 60))
        draw.text((x, y), line, font=font, fill=(255, 255, 255))
        y += font_size + line_spacing

    img.save(dst)
    print(f"wrote {dst} ({w}x{h})")


if __name__ == "__main__":
    main()
