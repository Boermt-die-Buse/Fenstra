#!/usr/bin/env python3
"""Fenstra-Hintergrundbilder: eigene „Blüte“ aus durchscheinenden Blättern (ähnlich der
Windows-11-Bloom, aber eigenes Motiv), hell und dunkel, als SVG 3840×2160.

Aufruf: hintergrund.py --out <verzeichnis>   -> fenstra-light.svg, fenstra-dark.svg
"""
import argparse
import math
import os

W, H = 3840, 2160
CX, CY = 1920, 1215          # Mitte der Blüte (leicht unter der Bildmitte, wie bei Windows)
SQUASH = 0.66                # Blüte leicht von vorn-oben gesehen
NEIGUNG = -8                 # Drehung der ganzen Blüte (Grad)

FARBEN = {
    'light': {
        'bg': [('0', '#CFDFF3'), ('0.5', '#E3ECF8'), ('1', '#F2F4FB')],
        'schein': '#8CC8FF', 'schein_op': 0.55,
        'hinten': ('#003E92', '#2F8BE6', 0.85, 0.55),     # Basis, Spitze, Deckkraft Basis/Spitze
        'vorn': ('#0067C0', '#7FD3FF', 0.92, 0.70),
        'falte': '#FFFFFF', 'falte_op': 0.42,
        'kern': '#E9F6FF',
    },
    'dark': {
        'bg': [('0', '#0C2148'), ('0.55', '#07122A'), ('1', '#03060F')],
        'schein': '#1F6FE0', 'schein_op': 0.65,
        'hinten': ('#001A68', '#1C74E8', 0.9, 0.6),
        'vorn': ('#0050B0', '#4CC2FF', 0.95, 0.8),
        'falte': '#B8E6FF', 'falte_op': 0.35,
        'kern': '#9EDCFF',
    },
}


def blatt(laenge, breite, schwung=0.0):
    """Blatt zeigt von (0,0) nach oben; schwung > 0 biegt die Spitze nach rechts."""
    L, B = laenge, breite
    s = schwung * L
    return (f'M0 0C{B * 0.95:.1f} {-L * 0.22:.1f} {B * 0.8 + s:.1f} {-L * 0.8:.1f} {s * 1.3:.1f} {-L:.1f}'
            f'C{-B * 0.55 + s:.1f} {-L * 0.86:.1f} {-B * 0.95:.1f} {-L * 0.26:.1f} 0 0Z')


def falte(laenge, breite, schwung=0.0):
    """helle Fläche entlang einer Blatthälfte (wirkt wie eine gefaltete, durchscheinende Kante)"""
    L, B = laenge, breite
    s = schwung * L
    return (f'M0 0C{B * 0.95:.1f} {-L * 0.22:.1f} {B * 0.8 + s:.1f} {-L * 0.8:.1f} {s * 1.3:.1f} {-L:.1f}'
            f'C{B * 0.25 + s:.1f} {-L * 0.7:.1f} {B * 0.3:.1f} {-L * 0.3:.1f} 0 0Z')


def svg(variante):
    f = FARBEN[variante]
    defs = []
    body = []
    stops = ''.join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in f['bg'])
    defs.append(f'<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">{stops}</linearGradient>')
    defs.append(f'<radialGradient id="schein" cx="0.5" cy="0.5" r="0.5">'
                f'<stop offset="0" stop-color="{f["schein"]}" stop-opacity="{f["schein_op"]}"/>'
                f'<stop offset="1" stop-color="{f["schein"]}" stop-opacity="0"/></radialGradient>')
    defs.append('<filter id="weich" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="60"/></filter>')
    defs.append('<filter id="kante" x="-10%" y="-10%" width="120%" height="120%"><feGaussianBlur stdDeviation="3"/></filter>')
    body.append(f'<rect width="{W}" height="{H}" fill="url(#bg)"/>')
    body.append(f'<ellipse cx="{CX}" cy="{CY}" rx="1750" ry="1100" fill="url(#schein)"/>')

    def ring(name, anzahl, laenge, breite, versatz, farben, schwung, zufall):
        basis, spitze, op0, op1 = farben
        teile = []
        for i in range(anzahl):
            w = versatz + i * 360 / anzahl
            # Blätter seitlich etwas länger, oben/unten kürzer (Perspektive)
            k = 1.0 + 0.12 * math.cos(math.radians(2 * w)) + zufall[i % len(zufall)]
            L, B = laenge * k, breite * (0.9 + 0.2 * zufall[(i + 3) % len(zufall)] * 5)
            gid = f'{name}{i}'
            defs.append(f'<linearGradient id="{gid}" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="0" y2="{-L:.0f}">'
                        f'<stop offset="0" stop-color="{basis}" stop-opacity="{op0}"/>'
                        f'<stop offset="0.65" stop-color="{spitze}" stop-opacity="{(op0 + op1) / 2:.2f}"/>'
                        f'<stop offset="1" stop-color="{spitze}" stop-opacity="{op1}"/></linearGradient>')
            fid = f'{name}f{i}'
            defs.append(f'<linearGradient id="{fid}" gradientUnits="userSpaceOnUse" x1="0" y1="{-L * 0.15:.0f}" x2="0" y2="{-L:.0f}">'
                        f'<stop offset="0" stop-color="{f["falte"]}" stop-opacity="0"/>'
                        f'<stop offset="0.7" stop-color="{f["falte"]}" stop-opacity="{f["falte_op"]}"/>'
                        f'<stop offset="1" stop-color="{f["falte"]}" stop-opacity="{f["falte_op"] * 0.6:.2f}"/></linearGradient>')
            teile.append(f'<g transform="rotate({w:.1f})"><path d="{blatt(L, B, schwung)}" fill="url(#{gid})"/>'
                         f'<path d="{falte(L, B, schwung)}" fill="url(#{fid})" filter="url(#kante)"/></g>')
        return ''.join(teile)

    zufall = [0.03, -0.05, 0.06, -0.02, 0.04, -0.06, 0.01, 0.05, -0.03]
    bluete = (ring('h', 9, 980, 400, 10, f['hinten'], 0.10, zufall)
              + ring('v', 7, 800, 350, 32, f['vorn'], 0.16, zufall[::-1]))
    kern = (f'<circle r="70" fill="{f["kern"]}" opacity="0.55" filter="url(#weich)"/>')
    gruppe = f'<g transform="translate({CX} {CY}) rotate({NEIGUNG}) scale(1 {SQUASH})">{bluete}{kern}</g>'
    # weicher Schein hinter der Blüte: unscharfe Kopie
    body.append(f'<g opacity="0.45" filter="url(#weich)">{gruppe}</g>')
    body.append(gruppe)
    return (f'<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<!-- Fenstra-Hintergrund ({"hell" if variante == "light" else "dunkel"}): eigene Blüte aus durchscheinenden '
            f'Blättern, erzeugt von packages/fenstra-backgrounds/src/hintergrund.py. Eigenes Werk, CC-BY-SA-4.0. -->\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
            f'preserveAspectRatio="xMidYMid slice"><defs>{"".join(defs)}</defs>{"".join(body)}</svg>\n')


# ---------------------------------------------------------------------------
# Benutzerbilder (256er-Raster, runde Darstellung übernimmt Plasma)

def _bild(inhalt, bg0, bg1):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'
            f'<defs><linearGradient id="g" x1="0" y1="0" x2="0.4" y2="1"><stop offset="0" stop-color="{bg0}"/>'
            f'<stop offset="1" stop-color="{bg1}"/></linearGradient></defs>'
            f'<rect width="256" height="256" fill="url(#g)"/>{inhalt}</svg>\n')


BENUTZERBILDER = {
    # Windows-Standard: graue Person auf hellgrauem Grund
    'person': lambda: _bild('<circle cx="128" cy="100" r="44" fill="#7A7A7A"/>'
                            '<path d="M44 236c6-50 40-80 84-80s78 30 84 80z" fill="#7A7A7A"/>', '#E6E6E6', '#D2D2D2'),
    'bluete': lambda: _bild(''.join(
        f'<path d="M0 0C30 -20 28 -70 0 -92C-28 -70 -30 -20 0 0Z" transform="translate(128 132) rotate({a})" '
        f'fill="{c}" fill-opacity=".75"/>' for a, c in zip(range(0, 360, 45), ['#0067C0', '#4CC2FF'] * 4)),
        '#DCE9F9', '#B8D3F2'),
    'berge': lambda: _bild('<circle cx="182" cy="74" r="22" fill="#FFF1A8"/>'
                           '<path d="M0 200L70 110L118 170L160 120L256 220V256H0Z" fill="#3E7CB1"/>'
                           '<path d="M0 230L90 160L150 210L210 170L256 200V256H0Z" fill="#2B5D8C"/>', '#9ED3FF', '#E7F4FF'),
    'welle': lambda: _bild('<path d="M0 150C60 110 110 190 170 150S240 120 256 130V256H0Z" fill="#0F9D8E" fill-opacity=".85"/>'
                           '<path d="M0 190C70 160 120 230 190 190S240 170 256 175V256H0Z" fill="#0B7A6E"/>', '#BFF3EC', '#7FDCCF'),
    'blatt': lambda: _bild('<path d="M70 196C60 120 110 64 196 56C200 140 150 196 70 196Z" fill="#43A047"/>'
                           '<path d="M74 192C110 150 140 116 186 70" stroke="#C8F2C9" stroke-width="5" fill="none" stroke-linecap="round"/>',
                           '#E9F7E1', '#C4E8B4'),
    'planet': lambda: _bild('<circle cx="128" cy="128" r="62" fill="#A97DFF"/>'
                            '<ellipse cx="128" cy="128" rx="104" ry="26" fill="none" stroke="#FFD45E" stroke-width="8" transform="rotate(-18 128 128)"/>'
                            '<circle cx="60" cy="56" r="4" fill="#FFFFFF"/><circle cx="206" cy="200" r="3" fill="#FFFFFF"/>',
                            '#1B1F4A', '#3A2D7A'),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--benutzerbilder', help='Verzeichnis für die Benutzerbilder (SVG)')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for v in ('light', 'dark'):
        with open(os.path.join(a.out, f'fenstra-{v}.svg'), 'w', encoding='utf-8') as fh:
            fh.write(svg(v))
    print('fenstra-light.svg, fenstra-dark.svg')
    if a.benutzerbilder:
        os.makedirs(a.benutzerbilder, exist_ok=True)
        for n, fn in BENUTZERBILDER.items():
            with open(os.path.join(a.benutzerbilder, f'fenstra-{n}.svg'), 'w', encoding='utf-8') as fh:
                fh.write(fn())
        print(len(BENUTZERBILDER), 'Benutzerbilder')


if __name__ == '__main__':
    main()
