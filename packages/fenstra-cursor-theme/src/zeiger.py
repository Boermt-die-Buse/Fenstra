#!/usr/bin/env python3
"""Fenstra-Mauszeiger im Stil von Windows 11 – eigene Formen, aus Code erzeugt.

Alle Formen sind auf einem 24×24-Raster gezeichnet (Nenngröße 24 = Windows-Größe 1 bei
100 %: der Pfeil ist wie dort etwa 12×19 Pixel groß). Größere Nenngrößen werden aus
demselben SVG skaliert gerendert. Animierte Zeiger (Beschäftigt, Arbeiten im Hintergrund)
bestehen aus Einzelbildern.

Aufruf: zeiger.py --out <themenverzeichnis> [--nur-svg <verzeichnis>]
Braucht rsvg-convert und xcursorgen.
"""
import argparse
import math
import os
import shutil
import subprocess
import sys
import tempfile

GROESSEN = (24, 32, 36, 48, 64, 72, 96)
BILDER_BUSY = 24          # Einzelbilder je Umlauf
MS_BUSY = 42              # 24 × 42 ms ≈ 1 s pro Umlauf

WEISS, SCHWARZ = '#FFFFFF', '#000000'
BLAU, BLAU_HELL = '#1A73E8', '#9FD0FF'

SCHATTEN = ('<filter id="s" x="-20%" y="-20%" width="160%" height="160%">'
            '<feGaussianBlur in="SourceAlpha" stdDeviation="0.8"/>'
            '<feOffset dx="0.6" dy="1" result="b"/>'
            '<feComponentTransfer><feFuncA type="linear" slope="0.35"/></feComponentTransfer>'
            '<feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>')


def svg(body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'
            f'<defs>{SCHATTEN}</defs><g filter="url(#s)">{body}</g></svg>')


def weiss_mit_rand(d, w=1.0):
    return f'<path d="{d}" fill="{WEISS}" stroke="{SCHWARZ}" stroke-width="{w}" stroke-linejoin="round"/>'


def schwarz_mit_rand(d, w=1.0):
    return (f'<path d="{d}" fill="none" stroke="{WEISS}" stroke-width="{w + 2}" stroke-linejoin="round" stroke-linecap="round"/>'
            f'<path d="{d}" fill="{SCHWARZ}" stroke="{SCHWARZ}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"/>')


# ---------------------------------------------------------------------------
# Grundformen

PFEIL = 'M1.5 1.5V18L5.3 14.3L8 20L10.5 18.9L7.9 13.3H13Z'


def pfeil(dx=0.0, dy=0.0):
    if dx or dy:
        return f'<g transform="translate({dx} {dy})">{weiss_mit_rand(PFEIL)}</g>'
    return weiss_mit_rand(PFEIL)


def ring(cx, cy, r, w, phase):
    """Beschäftigt-Ring: blauer Ring, ein heller Bogen läuft im Uhrzeigersinn."""
    out = (f'<circle cx="{cx}" cy="{cy}" r="{r + w / 2 + 0.5}" fill="none" stroke="#0B3D91" stroke-opacity=".55" stroke-width="1"/>'
           f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{BLAU}" stroke-width="{w}"/>')
    # heller Schweif aus Segmenten mit abnehmender Deckkraft
    n = 14
    for i in range(n):
        a0 = phase - i * 12
        a1 = a0 - 12.5
        op = (1 - i / n) ** 1.6
        x0, y0 = cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0))
        x1, y1 = cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1))
        out += (f'<path d="M{x0:.3f} {y0:.3f}A{r} {r} 0 0 0 {x1:.3f} {y1:.3f}" fill="none" '
                f'stroke="{BLAU_HELL}" stroke-opacity="{op:.3f}" stroke-width="{w}"/>')
    out += f'<circle cx="{cx}" cy="{cy}" r="{r - w / 2 - 0.5}" fill="none" stroke="#0B3D91" stroke-opacity=".35" stroke-width="1"/>'
    return out


def doppelpfeil_senkrecht():
    # Schaft 11..13, Spitzen 9 breit; Mitte bei (12, 12)
    d = 'M12 1.5L16.5 6H13.2V18H16.5L12 22.5L7.5 18H10.8V6H7.5Z'
    return f'<path d="{d}" fill="{SCHWARZ}" stroke="{WEISS}" stroke-width="1" stroke-linejoin="miter"/>'


def gedreht(body, winkel, cx=12, cy=12):
    return f'<g transform="rotate({winkel} {cx} {cy})">{body}</g>'


def vierfach():
    d = ('M12 1.5L15.5 5H13V11H19V8.5L22.5 12L19 15.5V13H13V19H15.5L12 22.5L8.5 19H11V13H5V15.5L1.5 12'
         'L5 8.5V11H11V5H8.5Z')
    return f'<path d="{d}" fill="{SCHWARZ}" stroke="{WEISS}" stroke-width="1" stroke-linejoin="miter"/>'


def textcursor(vertikal=False):
    d = ('M8.5 3.5H10.5C11.3 3.5 11.8 3.9 12 4.4C12.2 3.9 12.7 3.5 13.5 3.5H15.5M12 4.5V19.5'
         'M8.5 20.5H10.5C11.3 20.5 11.8 20.1 12 19.6C12.2 20.1 12.7 20.5 13.5 20.5H15.5')
    body = (f'<path d="{d}" fill="none" stroke="{WEISS}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>'
            f'<path d="{d}" fill="none" stroke="{SCHWARZ}" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round"/>')
    return gedreht(body, 90) if vertikal else body


def fadenkreuz():
    d = 'M12 2V9.5M12 14.5V22M2 12H9.5M14.5 12H22'
    return (f'<path d="{d}" stroke="{WEISS}" stroke-width="3" stroke-linecap="square"/>'
            f'<path d="{d}" stroke="{SCHWARZ}" stroke-width="1" stroke-linecap="square"/>'
            f'<circle cx="12" cy="12" r="0.9" fill="{SCHWARZ}" stroke="{WEISS}" stroke-width=".6"/>')


def verboten():
    return (f'<circle cx="12" cy="12" r="8.3" fill="none" stroke="{WEISS}" stroke-width="4.6"/>'
            f'<circle cx="12" cy="12" r="8.3" fill="none" stroke="{SCHWARZ}" stroke-width="2.6"/>'
            f'<path d="M6.3 17.7L17.7 6.3" stroke="{WEISS}" stroke-width="4.6"/>'
            f'<path d="M6.3 17.7L17.7 6.3" stroke="{SCHWARZ}" stroke-width="2.6"/>')


def hand(geschlossen=False, zeige=True):
    if zeige:
        # Zeigefinger hoch (Linkauswahl), Spitze bei (7.5, 1)
        d = ('M6 2.5A1.5 1.5 0 0 1 9 2.5V9.2A1.5 1.5 0 0 1 12 9.4V10.2A1.5 1.5 0 0 1 15 10.4V11.2A1.5 1.5 0 0 1 18 11.4'
             'V16.5C18 19.5 16.2 22 13 22H10.5C8.6 22 7.4 21.2 6.4 19.8L3.1 15.2A1.4 1.4 0 0 1 5.2 13.4L6 14.4Z')
        falten = (f'<path d="M9 9.2V13M12 10.2V13M15 11.2V13.4" stroke="{SCHWARZ}" stroke-width="0.9" stroke-linecap="round"/>')
        return weiss_mit_rand(d) + falten
    if geschlossen:
        d = ('M5.5 10.5A1.5 1.5 0 0 1 8.5 10V9.6A1.5 1.5 0 0 1 11.5 9.6A1.5 1.5 0 0 1 14.5 9.8A1.5 1.5 0 0 1 17.5 10.2'
             'V15.5C17.5 18.8 15.7 21 12.5 21H10.5C8.3 21 6.9 19.9 6 18.2L5.5 16.8Z')
        falten = f'<path d="M8.5 10V12.6M11.5 9.6V12.4M14.5 9.8V12.6" stroke="{SCHWARZ}" stroke-width="0.9" stroke-linecap="round"/>'
        return weiss_mit_rand(d) + falten
    # offene Hand (Greifen)
    d = ('M6.2 9.5V5.5A1.4 1.4 0 0 1 9 5.5V4A1.4 1.4 0 0 1 11.8 4V4.8A1.4 1.4 0 0 1 14.6 4.8V6.3A1.4 1.4 0 0 1 17.4 6.3'
         'V15.5C17.4 18.8 15.6 21 12.4 21H10.6C8.5 21 7.3 20.1 6.2 18.5L2.9 13.7A1.4 1.4 0 0 1 5 11.9Z')
    falten = f'<path d="M9 5.5V11M11.8 4.8V11M14.6 6.3V11" stroke="{SCHWARZ}" stroke-width="0.9" stroke-linecap="round"/>'
    return weiss_mit_rand(d) + falten


def stift():
    d = 'M18.6 2.6A1.9 1.9 0 0 1 21.4 5.4L8.4 18.4L3 21L5.6 15.6Z'
    return (weiss_mit_rand(d) + f'<path d="M5.6 15.6L8.4 18.4M16.6 4.6L19.4 7.4" stroke="{SCHWARZ}" stroke-width="1"/>'
            f'<path d="M3 21L4.1 18.7L5.3 19.9Z" fill="{SCHWARZ}"/>')


def pipette():
    d = 'M17 2.8A2 2 0 0 1 21.2 7L19 9.2L19.8 10L18.4 11.4L12.6 5.6L14 4.2L14.8 5Z'
    return (weiss_mit_rand(d) + weiss_mit_rand('M13.3 6.3L4.4 15.2L3.6 18.4L2.6 19.4L4.6 21.4L5.6 20.4L8.8 19.6L17.7 10.7')
            + f'<path d="M3 21L4.6 21.4L2.6 19.4Z" fill="{SCHWARZ}"/>')


def lupe(plus=True):
    out = (f'<circle cx="9.5" cy="9.5" r="6.5" fill="{WEISS}" fill-opacity=".85" stroke="{SCHWARZ}" stroke-width="1.6"/>'
           f'<path d="M14.3 14.3L21 21" stroke="{WEISS}" stroke-width="4.4" stroke-linecap="round"/>'
           f'<path d="M14.3 14.3L21 21" stroke="{SCHWARZ}" stroke-width="2.6" stroke-linecap="round"/>'
           f'<path d="M6.5 9.5H12.5" stroke="{SCHWARZ}" stroke-width="1.4"/>')
    if plus:
        out += f'<path d="M9.5 6.5V12.5" stroke="{SCHWARZ}" stroke-width="1.4"/>'
    return out


def zelle():
    d = 'M9.5 3.5H14.5V9.5H20.5V14.5H14.5V20.5H9.5V14.5H3.5V9.5H9.5Z'
    return weiss_mit_rand(d)


def hoch():
    d = 'M12 1.5L19 8.5H14.5V21.5H9.5V8.5H5Z'
    return weiss_mit_rand(d)


def zusatz_kasten(inhalt):
    """kleines Kästchen unten rechts am Pfeil (Ziehen: Kopieren/Verknüpfen/Menü)"""
    return (f'<rect x="12.5" y="13.5" width="9" height="9" rx="1" fill="{WEISS}" stroke="{SCHWARZ}" stroke-width="1"/>' + inhalt)


def fragezeichen():
    d = 'M13.6 11.2A2.6 2.6 0 1 1 17.3 13.6C16.6 14 16.2 14.6 16.2 15.4V16.2'
    return (f'<path d="{d}" fill="none" stroke="{WEISS}" stroke-width="3.6" stroke-linecap="round"/>'
            f'<path d="{d}" fill="none" stroke="{SCHWARZ}" stroke-width="1.6" stroke-linecap="round"/>'
            f'<circle cx="16.2" cy="19.4" r="1.6" fill="{WEISS}"/><circle cx="16.2" cy="19.4" r="1" fill="{SCHWARZ}"/>')


# ---------------------------------------------------------------------------
# Formen: Name -> (SVG oder Liste von SVGs, Hotspot im 24er-Raster, Verweise)

def formen():
    f = {}
    f['default'] = (svg(pfeil()), (1, 1), 'left_ptr arrow top_left_arrow left_arrow X_cursor wayland-cursor pirate draft right_ptr dnd-move dnd_move')
    f['help'] = (svg(pfeil() + fragezeichen()), (1, 1),
                 'question_arrow whats_this left_ptr_help dnd-ask d9ce0ab605698f320427677b458ad60b 5c6cd98b3f3ebcb1f9c7f1c204630408')
    f['progress'] = ([svg(pfeil() + ring(16.5, 16.5, 4.3, 2.4, p * 360 / BILDER_BUSY)) for p in range(BILDER_BUSY)], (1, 1),
                     'left_ptr_watch half-busy 3ecb610c1bf2410f44200f48c40d3599 00000000000000020006000e7e9ffc3f 08e8e1c95fe2fc01f976f1e063a24ccd')
    f['wait'] = ([svg(ring(12, 12, 8, 4, p * 360 / BILDER_BUSY)) for p in range(BILDER_BUSY)], (12, 12), 'watch')
    f['crosshair'] = (svg(fadenkreuz()), (12, 12), 'cross tcross cross_reverse diamond_cross target')
    f['text'] = (svg(textcursor()), (12, 12), 'xterm ibeam')
    f['vertical-text'] = (svg(textcursor(True)), (12, 12), '')
    f['pencil'] = (svg(stift()), (3, 21), 'draft-pencil')
    f['not-allowed'] = (svg(verboten()), (12, 12),
                        'no-drop forbidden circle crossed_circle dnd-none dnd-no-drop 03b6e0fcb3499374a867c041f52298f0')
    f['ns-resize'] = (svg(doppelpfeil_senkrecht()), (12, 12),
                      'size_ver n-resize s-resize sb_v_double_arrow v_double_arrow top_side bottom_side row-resize split_v '
                      'size-ver 00008160000006810000408080010102 2870a09082c103050810ffdffffe0204')
    f['ew-resize'] = (svg(gedreht(doppelpfeil_senkrecht(), 90)), (12, 12),
                      'size_hor e-resize w-resize sb_h_double_arrow h_double_arrow left_side right_side col-resize split_h '
                      'size-hor 028006030e0e7ebffc7f7070c0600140 14fef782d02440884392942c11205230')
    f['nwse-resize'] = (svg(gedreht(doppelpfeil_senkrecht(), -45)), (12, 12),
                        'size_fdiag nw-resize se-resize top_left_corner bottom_right_corner bd_double_arrow size-fdiag '
                        'c7088f0f3e6c8088236ef8e1e3e70000 38c5dff7c7b8962045400281044508d2')
    f['nesw-resize'] = (svg(gedreht(doppelpfeil_senkrecht(), 45)), (12, 12),
                        'size_bdiag ne-resize sw-resize top_right_corner bottom_left_corner fd_double_arrow size-bdiag '
                        'fcf1c3c7cd4491d801f1e1c78f100000 50585d75b494802d0151028115016902')
    f['move'] = (svg(vierfach()), (12, 12),
                 'fleur all-scroll size_all size-all 4498f0e0c1937ffe01fd06f973665830 9081237383d90e509aa00f00170e968f')
    f['up-arrow'] = (svg(hoch()), (12, 1), 'center_ptr up_arrow sb_up_arrow')
    f['pointer'] = (svg(hand()), (7, 1),
                    'hand2 hand1 hand pointing_hand e29285e634086352946a0e7090d73106 9d800788f1b08800ae810202380a0822')
    f['grab'] = (svg(hand(zeige=False)), (12, 12), 'openhand fleur-open 5aca4d189052212118709018842178c0')
    f['grabbing'] = (svg(hand(geschlossen=True, zeige=False)), (12, 12),
                     'closedhand 208530c400c041818281048008011002 fcf21c00b30f7e3f83fe0dfd12e71cff')
    f['copy'] = (svg(pfeil() + zusatz_kasten(f'<path d="M17 15.5V20.5M14.5 18H19.5" stroke="{SCHWARZ}" stroke-width="1.2"/>')),
                 (1, 1), 'dnd-copy 1081e37283d90000800003c07f3ef6bf 6407b0e94181790501fd1e167b474872 08ffe1cb5fe6fc01f906f1c063814ccf')
    f['alias'] = (svg(pfeil() + zusatz_kasten(f'<path d="M15 20.5C15 17.8 16.3 16.5 19 16.5M17.5 15L19.3 16.5L17.5 18" fill="none" stroke="{SCHWARZ}" stroke-width="1.1"/>')),
                  (1, 1), 'link dnd-link 3085a0e285430894940527032f8b26df 640fb0e74195791501fd1ed57b41487f')
    f['context-menu'] = (svg(pfeil() + zusatz_kasten(f'<path d="M14.5 16H19.5M14.5 18H19.5M14.5 20H19.5" stroke="{SCHWARZ}" stroke-width="1"/>')),
                         (1, 1), '')
    f['cell'] = (svg(zelle()), (12, 12), 'plus')
    f['zoom-in'] = (svg(lupe(True)), (9, 9), 'zoom_in')
    f['zoom-out'] = (svg(lupe(False)), (9, 9), 'zoom_out')
    f['color-picker'] = (svg(pipette()), (3, 21), '')
    return f


def render(svg_text, groesse, ziel, tmp):
    src = os.path.join(tmp, 'x.svg')
    with open(src, 'w', encoding='utf-8') as fh:
        fh.write(svg_text)
    subprocess.run(['rsvg-convert', '-w', str(groesse), '-h', str(groesse), '-o', ziel, src], check=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--nur-svg', help='nur die SVGs (erstes Bild) in dieses Verzeichnis schreiben (Sichtprüfung)')
    a = ap.parse_args()
    f = formen()
    if a.nur_svg:
        os.makedirs(a.nur_svg, exist_ok=True)
        for name, (bild, hot, _) in f.items():
            erstes = bild[0] if isinstance(bild, list) else bild
            with open(os.path.join(a.nur_svg, name + '.svg'), 'w', encoding='utf-8') as fh:
                fh.write(erstes)
        print(len(f), 'SVGs')
        return
    for tool in ('rsvg-convert', 'xcursorgen'):
        if not shutil.which(tool):
            sys.exit(f'{tool} fehlt')
    if os.path.exists(a.out):
        shutil.rmtree(a.out)
    cdir = os.path.join(a.out, 'cursors')
    os.makedirs(cdir)
    verweise = 0
    with tempfile.TemporaryDirectory() as tmp:
        for name, (bild, (hx, hy), aliase) in f.items():
            bilder = bild if isinstance(bild, list) else [bild]
            cfg = []
            for g in GROESSEN:
                s = g / 24
                for i, b in enumerate(bilder):
                    png = os.path.join(tmp, f'{name}-{g}-{i}.png')
                    render(b, g, png, tmp)
                    zeile = f'{g} {round(hx * s)} {round(hy * s)} {png}'
                    if len(bilder) > 1:
                        zeile += f' {MS_BUSY}'
                    cfg.append(zeile)
            cfgp = os.path.join(tmp, name + '.cfg')
            with open(cfgp, 'w') as fh:
                fh.write('\n'.join(cfg) + '\n')
            subprocess.run(['xcursorgen', cfgp, os.path.join(cdir, name)], check=True)
            for al in aliase.split():
                p = os.path.join(cdir, al)
                if not os.path.lexists(p):
                    os.symlink(name, p)
                    verweise += 1
    with open(os.path.join(a.out, 'index.theme'), 'w') as fh:
        fh.write('[Icon Theme]\nName=Fenstra\nName[de]=Fenstra\n'
                 'Comment=Fenstra cursors in the style of Windows 11, drawn from code\n'
                 'Comment[de]=Fenstra-Mauszeiger im Stil von Windows 11, aus Code erzeugt\n')
    print(f'{len(f)} Zeiger, {verweise} Verweise, Größen {GROESSEN}')


if __name__ == '__main__':
    main()
