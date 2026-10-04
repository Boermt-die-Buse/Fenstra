#!/usr/bin/env python3
"""Fenstra-Symbolthema erzeugen.

Quelle: Fluent UI System Icons (Microsoft, MIT) aus dem npm-Paket @fluentui/svg-icons.
Ziel:   ein KDE-/freedesktop-Symbolthema "fenstra", das von Breeze erbt und die
        häufigsten Aktions-, Status-, Geräte- und Ordnersymbole ersetzt.

  - einfarbige Symbole (actions, status, devices, categories) folgen dem
    Farbschema (Stylesheet-Mechanismus wie bei Breeze: <style id="current-color-scheme">)
  - Ordnersymbole (places): eigener gelber Ordner + Fluent-Glyphe
  - unbekannte Symbole kommen aus Breeze (Inherits)

Aufruf: generate-icons.py --fluent <npm-package/icons> --src <dieses Verzeichnis> --out <Zielverzeichnis>
"""
import argparse
import json
import os
import re
import sys

# KDE-Größe -> bevorzugte Fluent-Größen (erste vorhandene gewinnt)
MONO_SIZES = {
    16: (16, 20, 24),
    22: (20, 24, 16),
    24: (24, 20, 28),
    32: (32, 28, 24),
    48: (48, 32, 24),
}
PLACE_SIZES = (16, 22, 32, 48, 64, 96, 128)
STYLE = ('<style id="current-color-scheme" type="text/css">'
         '.ColorScheme-Text { color:#232629; } .ColorScheme-Background { color:#eff0f1; } '
         '.ColorScheme-Highlight { color:#3daee9; } .ColorScheme-NegativeText { color:#da4453; } '
         '.ColorScheme-PositiveText { color:#27ae60; } .ColorScheme-NeutralText { color:#f67400; }'
         '</style>')

_svg_open = re.compile(r'<svg\b[^>]*>', re.S)
_wh = re.compile(r'\s(width|height)="[^"]*"')
_path_no_fill = re.compile(r'<(path|circle|rect|ellipse|polygon)\b(?![^>]*\bfill=)([^>]*)/?>', re.S)


def read(p):
    with open(p, encoding='utf-8') as f:
        return f.read()


def find_fluent(fluent_dir, base, sizes, styles=('regular', 'filled', 'color')):
    for style in styles:
        for s in sizes:
            p = os.path.join(fluent_dir, f'{base}_{s}_{style}.svg')
            if os.path.exists(p):
                return p, s, style
    # Rückfall: irgendeine vorhandene Größe (SVG skaliert)
    for style in styles:
        for s in (16, 20, 24, 28, 32, 48, 12, 10):
            p = os.path.join(fluent_dir, f'{base}_{s}_{style}.svg')
            if os.path.exists(p):
                return p, s, style
    return None, None, None


def mono_svg(src_svg, out_size, viewbox_size):
    """Fluent-SVG in ein farbschemafolgendes Symbol umwandeln."""
    svg = src_svg
    m = _svg_open.search(svg)
    if not m:
        raise ValueError('kein <svg>')
    head = m.group(0)
    head = _wh.sub('', head)
    if 'viewBox' not in head:
        head = head[:-1] + f' viewBox="0 0 {viewbox_size} {viewbox_size}">'
    head = head[:-1] + f' width="{out_size}" height="{out_size}">'
    body = svg[m.end():]
    # Formen ohne fill bekommen die Schemafarbe; feste Fülls (#212121 usw.) ebenfalls
    body = _path_no_fill.sub(lambda mm: mm.group(0).replace('<' + mm.group(1), '<' + mm.group(1) + ' class="ColorScheme-Text" style="fill:currentColor"', 1), body)
    body = re.sub(r'fill="#(212121|242424|1f1f1f|000000)"', 'class="ColorScheme-Text" style="fill:currentColor"', body)
    return head + '<defs>' + STYLE + '</defs>' + body


def inner_of(svg):
    """Inhalt zwischen <svg ...> und </svg> sowie die viewBox-Größe."""
    m = _svg_open.search(svg)
    head = m.group(0)
    vb = re.search(r'viewBox="0 0 (\d+) (\d+)"', head)
    size = int(vb.group(1)) if vb else 24
    body = svg[m.end():]
    body = re.sub(r'</svg>\s*$', '', body.strip())
    return body, size


def folder_svg(base_svg, glyph_svg, out_size, glyph_fill='#8A5A00'):
    """Ordner (64er-Koordinaten) + Glyphe mittig auf der Vorderseite."""
    body, _ = inner_of(base_svg)
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{out_size}" height="{out_size}" viewBox="0 0 64 64">']
    out.append(body)
    if glyph_svg and out_size >= 32:
        gbody, gsize = inner_of(glyph_svg)
        gbody = re.sub(r'<(path|circle|rect|ellipse|polygon)\b(?![^>]*\bfill=)', lambda mm: mm.group(0) + f' fill="{glyph_fill}"', gbody)
        gbody = re.sub(r'fill="#(212121|242424|1f1f1f|000000)"', f'fill="{glyph_fill}"', gbody)
        # Glyphe: 26 Einheiten breit, mittig auf der Vorderseite (y 20..56)
        target = 26.0
        scale = target / gsize
        tx = 32 - target / 2
        ty = 38 - target / 2
        out.append(f'<g transform="translate({tx:.2f} {ty:.2f}) scale({scale:.4f})" opacity="0.85">{gbody}</g>')
    out.append('</svg>')
    return ''.join(out)


ACCENT = '#0067C0'


def accent_svg(src_svg, out_size, viewbox_size):
    """Fluent-SVG fest in der Akzentfarbe (für Orte ohne Fluent-Farbvariante)."""
    m = _svg_open.search(src_svg)
    head = _wh.sub('', m.group(0))
    if 'viewBox' not in head:
        head = head[:-1] + f' viewBox="0 0 {viewbox_size} {viewbox_size}">'
    head = head[:-1] + f' width="{out_size}" height="{out_size}">'
    body = src_svg[m.end():]
    body = _path_no_fill.sub(lambda mm: mm.group(0).replace('<' + mm.group(1), '<' + mm.group(1) + f' fill="{ACCENT}"', 1), body)
    body = re.sub(r'fill="#(212121|242424|1f1f1f|000000)"', f'fill="{ACCENT}"', body)
    return head + body


def color_or_mono_place(fluent_dir, kind, base, out_size):
    if kind == 'accent':
        p, s, st = find_fluent(fluent_dir, base, (48, 32, 28, 24, 20, 16), styles=('regular', 'filled'))
        return accent_svg(read(p), out_size, s) if p else None
    if kind == 'color':
        p, s, st = find_fluent(fluent_dir, base, (32, 48, 24, 28, 20, 16), styles=('color',))
        if p:
            svg = read(p)
            m = _svg_open.search(svg)
            head = _wh.sub('', m.group(0))
            head = head[:-1] + f' width="{out_size}" height="{out_size}">'
            return head + svg[m.end():]
        # keine Farbvariante: einfarbig
    p, s, st = find_fluent(fluent_dir, base, (48, 32, 28, 24, 20, 16), styles=('regular', 'filled'))
    if not p:
        return None
    return mono_svg(read(p), out_size, s)


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(data)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fluent', required=True, help='Verzeichnis mit den Fluent-SVGs (npm: package/icons)')
    ap.add_argument('--src', required=True, help='Verzeichnis mit mapping.json und folder-base.svg')
    ap.add_argument('--out', required=True, help='Zielverzeichnis des Themas (…/icons/fenstra)')
    ap.add_argument('--strict', action='store_true', help='Abbruch bei fehlenden Fluent-Symbolen')
    a = ap.parse_args()

    mapping = json.load(open(os.path.join(a.src, 'mapping.json'), encoding='utf-8'))
    folder_base = read(os.path.join(a.src, 'folder-base.svg'))
    missing = []
    made = 0
    dirs = []

    # 1) einfarbige Kontexte
    for ctx in ('actions', 'status', 'devices'):
        for kde_name, fluent in mapping.get(ctx, {}).items():
            for size, prefs in MONO_SIZES.items():
                p, s, st = find_fluent(a.fluent, fluent, prefs, styles=('regular', 'filled'))
                if not p:
                    missing.append((ctx, kde_name, fluent))
                    break
                svg = mono_svg(read(p), size, s)
                write(os.path.join(a.out, ctx, str(size), kde_name + '.svg'), svg)
                made += 1
        dirs += [f'{ctx}/{s}' for s in MONO_SIZES]
    # "categories" = dieselben Symbole wie applications-* in actions
    for kde_name, fluent in mapping.get('actions', {}).items():
        if not kde_name.startswith(('applications-', 'preferences-')):
            continue
        for size in (22, 32, 48):
            p, s, st = find_fluent(a.fluent, fluent, MONO_SIZES[size], styles=('regular', 'filled'))
            if p:
                write(os.path.join(a.out, 'categories', str(size), kde_name + '.svg'), mono_svg(read(p), size, s))
                made += 1
    dirs += ['categories/22', 'categories/32', 'categories/48']

    # 2) Orte (Ordner mit Glyphe, farbige oder einfarbige Einzelsymbole)
    for kde_name, spec in mapping.get('places', {}).items():
        kind, _, base = spec.partition(':')
        for size in PLACE_SIZES:
            if kind == 'folder':
                glyph = None
                if base:
                    gp, gs, gst = find_fluent(a.fluent, base, (24, 20, 28, 32, 16), styles=('regular',))
                    if gp:
                        glyph = read(gp)
                    else:
                        missing.append(('places', kde_name, base))
                svg = folder_svg(folder_base, glyph, size)
            else:
                svg = color_or_mono_place(a.fluent, kind, base, size)
                if svg is None:
                    missing.append(('places', kde_name, base))
                    break
            write(os.path.join(a.out, 'places', str(size), kde_name + '.svg'), svg)
            made += 1
    dirs += [f'places/{s}' for s in PLACE_SIZES]

    # 2b) Programmsymbole, die auf vorhandene Dateien anderer Pakete verweisen
    #     (z. B. Installer -> Fenstra-Logo aus fenstra-logos). Wert: "link:<absoluter Pfad>"
    apps = mapping.get('apps', {})
    for kde_name, spec in apps.items():
        kind, _, target = spec.partition(':')
        if kind != 'link' or not target.startswith('/'):
            raise SystemExit(f'apps/{kde_name}: nur "link:/absoluter/pfad" erlaubt, nicht {spec!r}')
        lpath = os.path.join(a.out, 'apps', 'scalable', kde_name + os.path.splitext(target)[1])
        os.makedirs(os.path.dirname(lpath), exist_ok=True)
        if os.path.lexists(lpath):
            os.remove(lpath)
        os.symlink(target, lpath)
        made += 1
    if apps:
        dirs.append('apps/scalable')

    # 3) Aliasse als Symlinks
    for target, names in mapping.get('aliases', {}).items():
        ctx, _, tname = target.partition('/')
        sizes = PLACE_SIZES if ctx == 'places' else tuple(MONO_SIZES)
        for size in sizes:
            tpath = os.path.join(a.out, ctx, str(size), tname + '.svg')
            if not os.path.exists(tpath):
                continue
            for n in names:
                lpath = os.path.join(a.out, ctx, str(size), n + '.svg')
                if os.path.lexists(lpath):
                    os.remove(lpath)
                os.symlink(tname + '.svg', lpath)

    # 4) index.theme
    ctx_name = {'actions': 'Actions', 'status': 'Status', 'devices': 'Devices', 'places': 'Places', 'categories': 'Categories', 'apps': 'Applications'}
    lines = ['[Icon Theme]', 'Name=Fenstra', 'Name[de]=Fenstra',
             'Comment=Fenstra icon theme based on Fluent UI System Icons (MIT), falls back to Breeze',
             'Comment[de]=Fenstra-Symbole auf Basis der Fluent UI System Icons (MIT), Rest aus Breeze',
             'Inherits=breeze,hicolor', 'Example=folder', 'FollowsColorScheme=true',
             'Directories=' + ','.join(dirs), '']
    for d in dirs:
        ctx, size = d.split('/')
        if size == 'scalable':
            lines += [f'[{d}]', 'Size=48', 'MinSize=16', 'MaxSize=512', f'Context={ctx_name[ctx]}', 'Type=Scalable', '']
        else:
            lines += [f'[{d}]', f'Size={size}', f'Context={ctx_name[ctx]}', 'Type=Fixed', '']
    write(os.path.join(a.out, 'index.theme'), '\n'.join(lines))

    print(f'{made} Symbole erzeugt, {len(dirs)} Verzeichnisse')
    if missing:
        print(f'{len(missing)} Zuordnungen ohne passendes Fluent-Symbol (kommen aus Breeze):', file=sys.stderr)
        for m in sorted(set(missing)):
            print('  ', *m, file=sys.stderr)
        if a.strict:
            sys.exit(1)


if __name__ == '__main__':
    main()
