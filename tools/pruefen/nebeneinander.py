#!/usr/bin/env python3
"""Bilder nebeneinander zu einem Vergleichsbild zusammensetzen (optional vergrößert).

  nebeneinander.py AUS.png [--zoom N] BILD1.png BILD2.png …

Für Berichte und Prüflisten (z. B. Zustand Ruhe/Hover, Fenstra/Windows-Referenz).
"""
import sys
from PIL import Image


def main(argv):
    args = argv[1:]
    zoom = 1
    if '--zoom' in args:
        i = args.index('--zoom')
        zoom = int(args[i + 1])
        del args[i:i + 2]
    out, files = args[0], args[1:]
    imgs = [Image.open(f).convert('RGBA') for f in files]
    gap = 10
    w = sum(i.width for i in imgs) + gap * (len(imgs) - 1)
    h = max(i.height for i in imgs)
    canvas = Image.new('RGBA', (w, h), (255, 255, 255, 255))
    x = 0
    for i in imgs:
        canvas.paste(i, (x, 0))
        x += i.width + gap
    if zoom > 1:
        canvas = canvas.resize((canvas.width * zoom, canvas.height * zoom), Image.NEAREST)
    canvas.save(out)
    print(out)


if __name__ == '__main__':
    main(sys.argv)
