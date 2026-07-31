#!/usr/bin/env python3
"""Copy exported XCUITest screenshot attachments into BloomJournal_Screenshots/en/.

Usage:
    python3 scripts/collect_screenshots.py <exported_dir> <dest_dir>

<exported_dir> is the --output-path passed to
    xcrun xcresulttool export attachments
and must contain a manifest.json. Each attachment's
suggestedHumanReadableName (the XCTAttachment.name we set, e.g. "02_home_en")
becomes the destination filename "<name>.png". Existing files are overwritten.
"""
import json
import os
import re
import shutil
import sys

# XCTest appends "_<index>_<UUID>" to the attachment name we set, e.g.
# "01_welcome_en_0_8C487591-....png". Strip that back to our base name.
_SUFFIX = re.compile(r"_\d+_[0-9A-Fa-f-]{36}(?=\.png$)")


def normalize(name):
    base = name if name.lower().endswith(".png") else name + ".png"
    return _SUFFIX.sub("", base)


def walk(node, out):
    """Collect every dict that pairs exportedFileName with a human-readable name."""
    if isinstance(node, dict):
        exported = node.get("exportedFileName")
        human = node.get("suggestedHumanReadableName")
        if exported and human:
            out.append((human, exported))
        for v in node.values():
            walk(v, out)
    elif isinstance(node, list):
        for v in node:
            walk(v, out)


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    exported_dir, dest_dir = sys.argv[1], sys.argv[2]

    manifest_path = os.path.join(exported_dir, "manifest.json")
    with open(manifest_path) as f:
        manifest = json.load(f)

    pairs = []
    walk(manifest, pairs)
    if not pairs:
        print("No attachments found in manifest.json")
        sys.exit(1)

    os.makedirs(dest_dir, exist_ok=True)

    # Keep only our numbered screenshots; dedupe on the human name (last wins).
    chosen = {}
    for human, exported in pairs:
        base = normalize(human)
        chosen[base] = exported

    count = 0
    for base, exported in sorted(chosen.items()):
        src = os.path.join(exported_dir, exported)
        if not os.path.exists(src):
            print(f"  MISSING source for {base}: {exported}")
            continue
        dst = os.path.join(dest_dir, base)
        shutil.copyfile(src, dst)
        print(f"  {base}  <-  {exported}")
        count += 1

    print(f"Copied {count} screenshot(s) to {dest_dir}")


if __name__ == "__main__":
    main()
