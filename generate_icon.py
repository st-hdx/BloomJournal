#!/usr/bin/env python3
"""
BloomJournal App Icon
Same family as DailyPieChart:
  - Orange→Rose diagonal gradient background
  - Bold flat white bloom symbol (6 petals, center cutout)
"""

import math, json, os
from PIL import Image, ImageDraw

GRAD_TL = (242, 128,  68)
GRAD_BR = (198,  78, 112)
WHITE   = (255, 255, 255)


def make_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    pixels = []
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            pixels.append(tuple(int(GRAD_TL[i] + (GRAD_BR[i] - GRAD_TL[i]) * t) for i in range(3)))
    img.putdata(pixels)
    return img


def make_icon(size: int) -> Image.Image:
    s = size
    cx, cy = s / 2.0, s / 2.0

    bg = make_gradient(s)

    # ── 花びらマスクを L モードで作成 ──────────────────
    petal_mask = Image.new("L", (s, s), 0)

    n_petals   = 6
    petal_rx   = s * 0.118
    petal_ry   = s * 0.210
    petal_dist = s * 0.175

    for i in range(n_petals):
        angle = math.radians(i * 60)
        tmp = Image.new("L", (s, s), 0)
        td = ImageDraw.Draw(tmp)
        td.ellipse(
            [cx - petal_rx, cy - petal_dist - petal_ry,
             cx + petal_rx, cy - petal_dist + petal_ry],
            fill=255
        )
        tmp = tmp.rotate(-math.degrees(angle), center=(cx, cy), resample=Image.BICUBIC)
        # マスクを OR 合成
        from PIL import ImageChops
        petal_mask = ImageChops.lighter(petal_mask, tmp)

    # 中央円をくり抜く（0 で上書き）
    cut_r = s * 0.155
    md = ImageDraw.Draw(petal_mask)
    md.ellipse([cx - cut_r, cy - cut_r, cx + cut_r, cy + cut_r], fill=0)

    # ── 白い花びらをグラデーション背景に貼る ──────────
    white = Image.new("RGB", (s, s), WHITE)
    result = bg.copy()
    result.paste(white, mask=petal_mask)

    return result


def main():
    out = "BloomJournal/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(out, exist_ok=True)
    make_icon(1024).save(os.path.join(out, "AppIcon-1024.png"))
    print("Saved.")
    contents = {
        "images": [{"filename": "AppIcon-1024.png", "idiom": "universal",
                    "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(out, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)


if __name__ == "__main__":
    main()
