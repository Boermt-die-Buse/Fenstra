#!/usr/bin/env python3
"""Fenstra: Plasma-Designs „fenstra“ (hell) und „fenstra-dark“ erzeugen.

Alle Grafiken entstehen hier aus Code (keine fremden Dateien). Sie bilden die
Windows-11-Flächen nach (docs/windows11-referenz.md 1.5, 1.8, 2.12, 4.1):

  dialogs/background      Flyouts/Popups: Radius 8, Rand 1 px, Acrylic-Ersatzfarbe, Schatten
  widgets/panel-background Taskleiste: eckig, Linie oben 1 px, Mica/Acrylic-artige Fläche
  widgets/tooltip         Tooltips: Radius 4, Rand 1 px, kleiner Schatten
  widgets/background      Desktop-Widgets: Radius 8

Plasma verwendet die Varianten translucent/ (mit Unschärfe dahinter), solid/ (ohne
Compositing) und die Grundvariante. Fehlende Teile übernimmt Plasma aus dem
Standarddesign.

Aufruf: generate.py ZIELORDNER   (legt ZIELORDNER/fenstra und ZIELORDNER/fenstra-dark an)
"""
import json
import math
import os
import sys

THEMES = {
    'fenstra': {
        'name': 'Fenstra',
        'name_de': 'Fenstra',
        'dark': False,
        # Flyout: Acrylic Standard, Ersatzfarbe #F9F9F9; Rand SurfaceStrokeFlyout #0F000000
        'flyout': ('#F9F9F9', 0.90),
        'flyout_solid': ('#F9F9F9', 1.0),
        'flyout_border': ('#000000', 0.10),
        # Taskleiste: Acrylic Basis #F3F3F3, Linie oben
        'panel': ('#F3F3F3', 0.85),
        'panel_solid': ('#F3F3F3', 1.0),
        'panel_border': ('#000000', 0.08),
        'tooltip': ('#F9F9F9', 0.96),
        'widget': ('#F3F3F3', 0.88),
        'shadow': 0.20,
    },
    'fenstra-dark': {
        'name': 'Fenstra Dark',
        'name_de': 'Fenstra Dunkel',
        'dark': True,
        'flyout': ('#2C2C2C', 0.92),
        'flyout_solid': ('#2C2C2C', 1.0),
        'flyout_border': ('#000000', 0.30),
        'panel': ('#202020', 0.85),
        'panel_solid': ('#202020', 1.0),
        'panel_border': ('#FFFFFF', 0.08),
        'tooltip': ('#2C2C2C', 0.97),
        'widget': ('#202020', 0.88),
        'shadow': 0.38,
    },
}


def fill(color):
    c, a = color
    return f'fill="{c}" fill-opacity="{a:.3f}"'


class Svg:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.defs = []
        self.body = []

    def g(self, ident, parts):
        self.body.append(f'<g id="{ident}">' + ''.join(parts) + '</g>')

    def rect(self, ident, x, y, w, h, attrs='fill="#000000" fill-opacity="0"'):
        self.body.append(f'<rect id="{ident}" x="{x}" y="{y}" width="{w}" height="{h}" {attrs}/>')

    def text(self):
        return ('<?xml version="1.0" encoding="UTF-8"?>\n'
                f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
                f'width="{self.w}" height="{self.h}" viewBox="0 0 {self.w} {self.h}" version="1.1">\n'
                '<!-- Fenstra: erzeugt von packages/fenstra-theme/src/desktoptheme/generate.py -->\n'
                '<defs>' + ''.join(self.defs) + '</defs>\n' + '\n'.join(self.body) + '\n</svg>\n')


def bbox(x, y, w, h):
    """unsichtbares Rechteck, das die Größe eines Elements festlegt"""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#000000" fill-opacity="0"/>'


def gaussian_stops(alpha, steps=12, offset_base=0.0):
    """Gradientenstopps für einen weichen Schatten (Gauß-artiger Abfall)."""
    stops = []
    for i in range(steps + 1):
        t = i / steps
        a = alpha * math.exp(-4.5 * t * t) * (1 - t)
        stops.append(f'<stop offset="{t:.4f}" stop-color="#000000" stop-opacity="{a:.4f}"/>')
    return ''.join(stops)


def frame(svg, ox, oy, radius, fill_color, border_color, prefix=''):
    """Neun Elemente (topleft … bottomright) eines gerundeten Rahmens mit 1-px-Rand.
    Ecken R×R, Kanten 1 px lang, Mitte 1×1. ox/oy: Lage im SVG."""
    R = max(radius, 1)
    f = fill(fill_color)
    b = fill(border_color)
    p = prefix
    if radius > 0:
        r1 = R - 1
        # Ecken: Füllung innerhalb des Rands + Randring
        corners = {
            'topleft': (ox, oy, f'M {ox+1} {oy+R} A {r1} {r1} 0 0 1 {ox+R} {oy+1} L {ox+R} {oy+R} Z',
                        f'M {ox} {oy+R} A {R} {R} 0 0 1 {ox+R} {oy} L {ox+R} {oy+1} A {r1} {r1} 0 0 0 {ox+1} {oy+R} Z'),
        }
        x2 = ox + R + 1  # rechte Spalte
        y2 = oy + R + 1  # untere Zeile
        corners['topright'] = (x2, oy,
                               f'M {x2} {oy+1} A {r1} {r1} 0 0 1 {x2+r1} {oy+R} L {x2} {oy+R} Z',
                               f'M {x2} {oy} A {R} {R} 0 0 1 {x2+R} {oy+R} L {x2+r1} {oy+R} A {r1} {r1} 0 0 0 {x2} {oy+1} Z')
        corners['bottomleft'] = (ox, y2,
                                 f'M {ox+1} {y2} A {r1} {r1} 0 0 0 {ox+R} {y2+r1} L {ox+R} {y2} Z',
                                 f'M {ox} {y2} A {R} {R} 0 0 0 {ox+R} {y2+R} L {ox+R} {y2+r1} A {r1} {r1} 0 0 1 {ox+1} {y2} Z')
        corners['bottomright'] = (x2, y2,
                                  f'M {x2} {y2+r1} A {r1} {r1} 0 0 0 {x2+r1} {y2} L {x2} {y2} Z',
                                  f'M {x2} {y2+R} A {R} {R} 0 0 0 {x2+R} {y2} L {x2+r1} {y2} A {r1} {r1} 0 0 1 {x2} {y2+r1} Z')
        for name, (cx, cy, fp, bp) in corners.items():
            svg.g(p + name, [bbox(cx, cy, R, R), f'<path d="{fp}" {f}/>', f'<path d="{bp}" {b}/>'])
        cx = ox + R
        cy = oy + R
        svg.g(p + 'top', [bbox(cx, oy, 1, R), f'<rect x="{cx}" y="{oy}" width="1" height="1" {b}/>',
                          f'<rect x="{cx}" y="{oy+1}" width="1" height="{R-1}" {f}/>'])
        svg.g(p + 'bottom', [bbox(cx, y2, 1, R), f'<rect x="{cx}" y="{y2+R-1}" width="1" height="1" {b}/>',
                             f'<rect x="{cx}" y="{y2}" width="1" height="{R-1}" {f}/>'])
        svg.g(p + 'left', [bbox(ox, cy, R, 1), f'<rect x="{ox}" y="{cy}" width="1" height="1" {b}/>',
                           f'<rect x="{ox+1}" y="{cy}" width="{R-1}" height="1" {f}/>'])
        svg.g(p + 'right', [bbox(x2, cy, R, 1), f'<rect x="{x2+R-1}" y="{cy}" width="1" height="1" {b}/>',
                            f'<rect x="{x2}" y="{cy}" width="{R-1}" height="1" {f}/>'])
        svg.g(p + 'center', [f'<rect x="{cx}" y="{cy}" width="1" height="1" {f}/>'])
        return 2 * R + 1, 2 * R + 1
    return 0, 0


def shadow(svg, ox, oy, size, alpha, offset_y):
    """Schattenelemente shadow-* (Kacheln um den Rahmen), unten stärker (Lichteinfall von oben)."""
    S = size
    defs = svg.defs
    # Kanten: lineare Verläufe von innen (alpha) nach außen (0)
    for name, (x1, y1, x2, y2), a in [
        ('st', (0, 1, 0, 0), alpha * 0.55),
        ('sb', (0, 0, 0, 1), alpha * 1.0),
        ('sl', (1, 0, 0, 0), alpha * 0.75),
        ('sr', (0, 0, 1, 0), alpha * 0.75),
    ]:
        defs.append(f'<linearGradient id="{name}-g" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">{gaussian_stops(a)}</linearGradient>')
    for name, (cx, cy), a in [
        ('stl', (1, 1), alpha * 0.6), ('str', (0, 1), alpha * 0.6),
        ('sbl', (1, 0), alpha * 0.85), ('sbr', (0, 0), alpha * 0.85),
    ]:
        defs.append(f'<radialGradient id="{name}-g" cx="{cx}" cy="{cy}" r="1" fx="{cx}" fy="{cy}">{gaussian_stops(a)}</radialGradient>')
    c = S  # Kachelgröße
    x0, y0 = ox, oy
    svg.g('shadow-topleft', [f'<rect x="{x0}" y="{y0}" width="{c}" height="{c}" fill="url(#stl-g)"/>'])
    svg.g('shadow-top', [f'<rect x="{x0+c}" y="{y0}" width="1" height="{c}" fill="url(#st-g)"/>'])
    svg.g('shadow-topright', [f'<rect x="{x0+c+1}" y="{y0}" width="{c}" height="{c}" fill="url(#str-g)"/>'])
    svg.g('shadow-left', [f'<rect x="{x0}" y="{y0+c}" width="{c}" height="1" fill="url(#sl-g)"/>'])
    svg.g('shadow-center', [bbox(x0 + c, y0 + c, 1, 1)])
    svg.g('shadow-right', [f'<rect x="{x0+c+1}" y="{y0+c}" width="{c}" height="1" fill="url(#sr-g)"/>'])
    svg.g('shadow-bottomleft', [f'<rect x="{x0}" y="{y0+c+1}" width="{c}" height="{c}" fill="url(#sbl-g)"/>'])
    svg.g('shadow-bottom', [f'<rect x="{x0+c}" y="{y0+c+1}" width="1" height="{c}" fill="url(#sb-g)"/>'])
    svg.g('shadow-bottomright', [f'<rect x="{x0+c+1}" y="{y0+c+1}" width="{c}" height="{c}" fill="url(#sbr-g)"/>'])
    # Überlappung des Schattens mit dem Fenster: oben weniger, unten mehr (Versatz nach unten)
    top_in = max(0, offset_y)
    svg.rect('shadow-hint-top-margin', x0 + c, y0 - (c - top_in), 1, c - top_in)
    svg.rect('shadow-hint-bottom-margin', x0 + c, y0 + 2 * c + 2, 1, c)
    svg.rect('shadow-hint-left-margin', x0 - (c - 2), y0 + c, c - 2, 1)
    svg.rect('shadow-hint-right-margin', x0 + 2 * c + 2, y0 + c, c - 2, 1)


def margins(svg, ox, oy, top, bottom, left, right, prefix=''):
    """hint-*-margin: Innenabstand für den Inhalt"""
    svg.rect(prefix + 'hint-top-margin', ox, oy - 20 - top, 1, top) if top else None
    svg.rect(prefix + 'hint-bottom-margin', ox + 2, oy - 20 - bottom, 1, bottom) if bottom else None
    svg.rect(prefix + 'hint-left-margin', ox + 4, oy - 20 - 1, left, 1) if left else None
    svg.rect(prefix + 'hint-right-margin', ox + 4 + left + 2, oy - 20 - 1, right, 1) if right else None


def dialog_svg(t, variant):
    color = t['flyout_solid'] if variant == 'solid' else t['flyout']
    svg = Svg(140, 120)
    frame(svg, 10, 40, 8, color, t['flyout_border'])
    margins(svg, 10, 40, 4, 4, 4, 4)
    if variant != 'solid':
        shadow(svg, 60, 40, 24, t['shadow'], 4)
    return svg.text()


def tooltip_svg(t, variant):
    color = (t['tooltip'][0], 1.0) if variant == 'solid' else t['tooltip']
    svg = Svg(140, 120)
    frame(svg, 10, 40, 4, color, t['flyout_border'])
    margins(svg, 10, 40, 6, 7, 8, 8)
    if variant != 'solid':
        shadow(svg, 60, 40, 12, t['shadow'] * 0.8, 2)
    return svg.text()


def widget_svg(t):
    svg = Svg(140, 120)
    frame(svg, 10, 40, 8, t['widget'], t['flyout_border'])
    margins(svg, 10, 40, 8, 8, 8, 8)
    shadow(svg, 60, 40, 16, t['shadow'] * 0.7, 2)
    return svg.text()


def panel_svg(t, variant):
    """Taskleiste: keine Rundung; Linie 1 px oben (nur die Seite zum Bildschirminneren)."""
    color = t['panel_solid'] if variant == 'solid' else t['panel']
    f = fill(color)
    b = fill(t['panel_border'])
    svg = Svg(60, 60)
    ox, oy = 10, 30
    # 3×3 Raster mit 1-px-Rändern: oben Linie, sonst Fläche
    svg.g('topleft', [f'<rect x="{ox}" y="{oy}" width="1" height="1" {b}/>'])
    svg.g('top', [f'<rect x="{ox+1}" y="{oy}" width="1" height="1" {b}/>'])
    svg.g('topright', [f'<rect x="{ox+2}" y="{oy}" width="1" height="1" {b}/>'])
    svg.g('left', [f'<rect x="{ox}" y="{oy+1}" width="1" height="1" {f}/>'])
    svg.g('center', [f'<rect x="{ox+1}" y="{oy+1}" width="1" height="1" {f}/>'])
    svg.g('right', [f'<rect x="{ox+2}" y="{oy+1}" width="1" height="1" {f}/>'])
    svg.g('bottomleft', [f'<rect x="{ox}" y="{oy+2}" width="1" height="1" {f}/>'])
    svg.g('bottom', [f'<rect x="{ox+1}" y="{oy+2}" width="1" height="1" {f}/>'])
    svg.g('bottomright', [f'<rect x="{ox+2}" y="{oy+2}" width="1" height="1" {f}/>'])
    # kein Innenabstand: die Applets regeln ihre Abstände selbst (Windows: Knöpfe bündig)
    svg.rect('hint-top-margin', ox + 20, oy, 1, 1)
    svg.rect('hint-bottom-margin', ox + 22, oy, 1, 0.01)
    svg.rect('hint-left-margin', ox + 24, oy, 0.01, 1)
    svg.rect('hint-right-margin', ox + 26, oy, 0.01, 1)
    return svg.text()


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(text)


def main(argv):
    out = argv[1] if len(argv) > 1 else 'build'
    for ident, t in THEMES.items():
        base = os.path.join(out, ident)
        meta = {
            'KPlugin': {
                'Authors': [{'Name': 'Fenstra-Projekt'}],
                'Category': '',
                'Description': 'Windows 11 style surfaces for Fenstra',
                'Description[de]': 'Flächen im Stil von Windows 11 für Fenstra',
                'EnabledByDefault': True,
                'Id': ident,
                'License': 'CC-BY-SA-4.0',
                'Name': t['name'],
                'Name[de]': t['name_de'],
                'Version': '44.0',
                'Website': 'https://github.com/Boermt-die-Buse/Fenstra',
            },
            'X-Plasma-API': '5.0',
        }
        write(os.path.join(base, 'metadata.json'), json.dumps(meta, indent=4, ensure_ascii=False) + '\n')
        # Unschärfe hinter Taskleiste und Flyouts (Acrylic), Kontrast leicht angehoben
        write(os.path.join(base, 'plasmarc'),
              '[ContrastEffect]\nenabled=true\ncontrast=0.25\nintensity=1.6\nsaturation=1.8\n\n'
              '[BlurBehindEffect]\nenabled=true\n\n'
              '[AdaptiveTransparency]\nenabled=false\n')
        for variant, sub in [('base', ''), ('translucent', 'translucent'), ('solid', 'solid')]:
            write(os.path.join(base, sub, 'dialogs', 'background.svg'), dialog_svg(t, variant))
            write(os.path.join(base, sub, 'widgets', 'panel-background.svg'), panel_svg(t, variant))
            write(os.path.join(base, sub, 'widgets', 'tooltip.svg'), tooltip_svg(t, variant))
        write(os.path.join(base, 'widgets', 'background.svg'), widget_svg(t))
        print('erzeugt:', base)


if __name__ == '__main__':
    main(sys.argv)
