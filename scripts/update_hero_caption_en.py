#!/usr/bin/env python3
"""Same treatment as update_hero_caption.py, for the English hero screenshot."""
from PIL import Image, ImageDraw, ImageFont

SRC = "/Users/takayanagi/Develop/BloomJournal/BloomJournal_Screenshots/en/captioned/01_welcome_en.png"
DST = SRC

BAND_HEIGHT = 578
FONT_PATH = "/System/Library/Fonts/Avenir Next.ttc"
FONT_INDEX = 8  # Heavy
FONT_SIZE = 76
LINE_SPACING = 16

TL = (232, 157, 39)
TR = (222, 114, 113)
BL = (229, 148, 56)
BR = (219, 105, 126)

LINES = ["Practice the Law of", "Attraction by writing"]


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


def load_font():
    return ImageFont.truetype(FONT_PATH, FONT_SIZE, index=FONT_INDEX)


def main():
    img = Image.open(SRC).convert("RGB")
    w, h = img.size

    band = make_gradient(w, BAND_HEIGHT)
    img.paste(band, (0, 0))

    draw = ImageDraw.Draw(img)
    font = load_font()
    print("using font:", font.getname())

    total_h = len(LINES) * FONT_SIZE + (len(LINES) - 1) * LINE_SPACING
    y = (BAND_HEIGHT - total_h) // 2 + 10
    for line in LINES:
        bbox = draw.textbbox((0, 0), line, font=font)
        line_w = bbox[2] - bbox[0]
        x = (w - line_w) // 2
        draw.text((x + 2, y + 2), line, font=font, fill=(0, 0, 0, 60))
        draw.text((x, y), line, font=font, fill=(255, 255, 255))
        y += FONT_SIZE + LINE_SPACING

    img.save(DST)
    print(f"wrote {DST} ({w}x{h})")


if __name__ == "__main__":
    main()
