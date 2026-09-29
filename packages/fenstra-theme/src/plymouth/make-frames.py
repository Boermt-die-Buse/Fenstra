#!/usr/bin/env python3
"""Bilder für das Plymouth-Thema "fenstra" als SVG erzeugen (PNG-Rendering macht rsvg-convert im Spec).

  animation-0001..0036.svg  Ladering (kurzer Bogen, dreht sich; wie der Windows-Ladering)
  entry.svg, lock.svg, bullet.svg, capslock.svg  Passwortdialog (verschlüsselte Platte)
"""
import math
import os
import sys

out = sys.argv[1] if len(sys.argv) > 1 else '.'
os.makedirs(out, exist_ok=True)
N = 36
SIZE = 64
R = 24
for i in range(N):
    a0 = 2 * math.pi * i / N
    a1 = a0 + math.pi * 0.6
    x0, y0 = SIZE / 2 + R * math.cos(a0), SIZE / 2 + R * math.sin(a0)
    x1, y1 = SIZE / 2 + R * math.cos(a1), SIZE / 2 + R * math.sin(a1)
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}">'
           f'<path d="M {x0:.2f} {y0:.2f} A {R} {R} 0 0 1 {x1:.2f} {y1:.2f}" fill="none" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>'
           f'</svg>')
    with open(os.path.join(out, f'animation-{i + 1:04d}.svg'), 'w') as f:
        f.write(svg)

files = {
    'entry.svg': '<svg xmlns="http://www.w3.org/2000/svg" width="280" height="36" viewBox="0 0 280 36">'
                 '<rect x="1" y="1" width="278" height="34" rx="6" fill="#1F1F1F" stroke="#7A7A7A" stroke-width="1.5"/></svg>',
    'bullet.svg': '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12">'
                  '<circle cx="6" cy="6" r="3.5" fill="#FFFFFF"/></svg>',
    'lock.svg': '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 36 36">'
                '<rect x="7" y="15" width="22" height="17" rx="3" fill="#FFFFFF"/>'
                '<path d="M12 15 V11 a6 6 0 0 1 12 0 V15" fill="none" stroke="#FFFFFF" stroke-width="3"/></svg>',
    'capslock.svg': '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 36 36">'
                    '<path d="M18 5 L30 18 H23 V26 H13 V18 H6 Z" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round"/>'
                    '<rect x="13" y="29" width="10" height="3" fill="#FFFFFF"/></svg>',
}
for name, svg in files.items():
    with open(os.path.join(out, name), 'w') as f:
        f.write(svg)
print(f'{N + len(files)} SVG-Dateien nach {out}')
