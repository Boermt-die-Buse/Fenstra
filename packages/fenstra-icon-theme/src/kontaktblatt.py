#!/usr/bin/env python3
"""Kontaktblatt aller Fenstra-Glyphen (zur Sichtprüfung, nicht Teil des Pakets).

  kontaktblatt.py AUS.png [--groesse 32] [--filter text] [--dunkel]

Rendert jede Glyphe mit rsvg-convert und setzt sie mit Namen in ein Raster.
Meldet außerdem Motive aus mapping.json, für die es noch keine Glyphe gibt.
"""
import json
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import glyphs  # noqa: E402


def svg_doc(body, size, color):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 16 16" '
            f'style="color:{color}">{body}</svg>')


def main(argv):
    out = argv[1]
    size = 32
    flt = None
    dark = '--dunkel' in argv
    if '--groesse' in argv:
        size = int(argv[argv.index('--groesse') + 1])
    if '--filter' in argv:
        flt = argv[argv.index('--filter') + 1]
    fg = '#ffffff' if dark else '#1b1b1b'
    bg = (32, 32, 32, 255) if dark else (255, 255, 255, 255)
    if '--verzeichnis' in argv:
        # fertige SVG-Dateien eines erzeugten Themas (z. B. …/fenstra/apps/scalable)
        d = argv[argv.index('--verzeichnis') + 1]
        files = {os.path.splitext(f)[0]: os.path.join(d, f) for f in sorted(os.listdir(d))
                 if f.endswith('.svg') and not os.path.islink(os.path.join(d, f)) and (not flt or flt in f)}
        return sheet_from_files(out, files, size, bg, fg)
    names = sorted(n for n in glyphs.GLYPHS if not flt or flt in n)
    cell_w, cell_h = max(size * 3, 120), size + 30
    cols = 10
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new('RGBA', (cols * cell_w, rows * cell_h), bg)
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype('/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf', 10)
    except OSError:
        font = ImageFont.load_default()
    with tempfile.TemporaryDirectory() as tmp:
        for i, n in enumerate(names):
            svg = os.path.join(tmp, n + '.svg')
            png = os.path.join(tmp, n + '.png')
            with open(svg, 'w') as f:
                f.write(svg_doc(glyphs.GLYPHS[n], size, fg))
            r = subprocess.run(['rsvg-convert', '-o', png, svg], capture_output=True, text=True)
            x, y = (i % cols) * cell_w, (i // cols) * cell_h
            if r.returncode == 0:
                im = Image.open(png).convert('RGBA')
                sheet.alpha_composite(im, (x + (cell_w - size) // 2, y + 4))
            else:
                draw.text((x + 4, y + 4), 'FEHLER', fill=(255, 0, 0, 255), font=font)
            draw.text((x + 4, y + size + 10), n[:22], fill=(128, 128, 128, 255), font=font)
    sheet.save(out)
    print(out, len(names), 'Glyphen')
    with open(os.path.join(HERE, 'mapping.json'), encoding='utf-8') as f:
        mapping = json.load(f)
    need = set()
    for ctx in ('actions', 'status', 'devices', 'places'):
        for v in mapping.get(ctx, {}).values():
            v = v.split(':', 1)[1] if ':' in v else v
            if v:
                need.add(v)
    missing = sorted(need - set(glyphs.GLYPHS))
    print('fehlende Motive:', len(missing))
    print(' '.join(missing))


def sheet_from_files(out, files, size, bg, fg):
    cell_w, cell_h = max(size * 2, 120), size + 30
    cols = 10
    names = list(files)
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new('RGBA', (cols * cell_w, max(1, rows) * cell_h), bg)
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype('/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf', 10)
    except OSError:
        font = ImageFont.load_default()
    with tempfile.TemporaryDirectory() as tmp:
        for i, n in enumerate(names):
            png = os.path.join(tmp, f'{i}.png')
            svg = open(files[n], encoding='utf-8').read().replace('color:#1b1b1b', f'color:{fg}')
            src = os.path.join(tmp, f'{i}.svg')
            with open(src, 'w', encoding='utf-8') as f:
                f.write(svg)
            r = subprocess.run(['rsvg-convert', '-w', str(size), '-h', str(size), '-o', png, src], capture_output=True, text=True)
            x, y = (i % cols) * cell_w, (i // cols) * cell_h
            if r.returncode == 0:
                sheet.alpha_composite(Image.open(png).convert('RGBA'), (x + (cell_w - size) // 2, y + 4))
            else:
                draw.text((x + 4, y + 4), 'FEHLER', fill=(255, 0, 0, 255), font=font)
            draw.text((x + 4, y + size + 10), n[:22], fill=(128, 128, 128, 255), font=font)
    sheet.save(out)
    print(out, len(names), 'Dateien')


if __name__ == '__main__':
    main(sys.argv)
