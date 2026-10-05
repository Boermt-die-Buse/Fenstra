#!/usr/bin/env python3
"""Pixelgenaue Prüfung von Bildschirmfotos (für docs/checkliste-*.md).

  pixel.py BILD at X Y                     Farbe an einem Punkt (#RRGGBB)
  pixel.py BILD row Y X0 X1                Farbläufe einer Zeile: "x0-x1 (Länge) #farbe"
  pixel.py BILD col X Y0 Y1                Farbläufe einer Spalte
  pixel.py BILD crop X Y B H [ZOOM] AUS    Ausschnitt vergrößert (Nächster Nachbar) speichern
  pixel.py BILD box X Y B H                häufigste Farben in einem Rechteck

Toleranz für Läufe: --tol N (Standard 2 je Kanal), damit Kantenglättung nicht zerfasert.
Läuft in WSL oder der VM (python3-pillow).
"""
import sys
from collections import Counter
from PIL import Image


def hexc(p):
    return '#%02X%02X%02X' % p[:3]


def runs(pixels, tol):
    out = []
    start, cur = 0, pixels[0]
    for i, p in enumerate(pixels[1:], 1):
        if max(abs(a - b) for a, b in zip(p[:3], cur[:3])) > tol:
            out.append((start, i - 1, cur))
            start, cur = i, p
    out.append((start, len(pixels) - 1, cur))
    return out


def main(argv):
    tol = 2
    if '--tol' in argv:
        i = argv.index('--tol')
        tol = int(argv[i + 1])
        del argv[i:i + 2]
    img = Image.open(argv[1]).convert('RGBA')
    cmd, a = argv[2], [int(x) if x.lstrip('-').isdigit() else x for x in argv[3:]]
    if cmd == 'at':
        print(hexc(img.getpixel((a[0], a[1]))))
    elif cmd in ('row', 'col'):
        if cmd == 'row':
            y, x0, x1 = a
            px = [img.getpixel((x, y)) for x in range(x0, x1 + 1)]
            off = x0
        else:
            x, y0, y1 = a
            px = [img.getpixel((x, y)) for y in range(y0, y1 + 1)]
            off = y0
        for s, e, c in runs(px, tol):
            print('%5d-%-5d (%3d) %s' % (s + off, e + off, e - s + 1, hexc(c)))
    elif cmd == 'crop':
        x, y, w, h = a[:4]
        zoom = a[4] if len(a) > 5 else 4
        out = a[-1]
        img.crop((x, y, x + w, y + h)).resize((w * zoom, h * zoom), Image.NEAREST).save(out)
        print(out)
    elif cmd == 'box':
        x, y, w, h = a
        c = Counter(hexc(img.getpixel((i, j))) for i in range(x, x + w) for j in range(y, y + h))
        for col, n in c.most_common(8):
            print('%s %5d' % (col, n))
    else:
        print(__doc__)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
