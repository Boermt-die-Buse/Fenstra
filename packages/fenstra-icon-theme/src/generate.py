#!/usr/bin/env python3
"""Fenstra-Symbolthema erzeugen – nur aus eigenen Motiven (keine fremden Dateien).

Quellen:  glyphs.py   einfarbige Strichsymbole (16er-Raster, folgen dem Farbschema)
          farbig.py   farbige Symbole (Ordner, Laufwerke, Dateitypen, Programme, Hinweise)
          mapping.json  KDE-/freedesktop-Name -> Motiv

Aufbau des Themas:
  <kontext>/{16,22,24,32,48}   einfarbig; 16 und 32/48 skaliert (1:1, 2:1, 3:1), 22/24 als
                                16er-Motiv mit Rand (pixelgenau wie Segoe-Fluent-Glyphen)
  <kontext>/scalable            farbig (viewBox 64)
  places/16                     zusätzlich eigene 16er-Motive für die Bibliotheken
                                (Dokumente, Downloads, Bilder, … wie im Explorer-Navigationsbereich)
  preferences/*                 Glyphen in Akzentfarbe (ColorScheme-Highlight)

Aufruf: generate.py --out <ziel> [--bedarf symbolbedarf.txt]
"""
import argparse
import json
import os
import re
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import farbig  # noqa: E402
import glyphs  # noqa: E402

MONO_SIZES = (16, 22, 24, 32, 48)
MONO_CTX = ('actions', 'status', 'devices', 'places', 'categories')
FARB_CTX = ('places', 'devices', 'status', 'emblems', 'mimetypes', 'apps')
CTX_NAME = {'actions': 'Actions', 'status': 'Status', 'devices': 'Devices', 'places': 'Places',
            'categories': 'Categories', 'preferences': 'Applications', 'apps': 'Applications',
            'mimetypes': 'MimeTypes', 'emblems': 'Emblems'}
# Reihenfolge der Kontexte im index.theme
CTX_ORDER = ('actions', 'status', 'devices', 'places', 'categories', 'preferences', 'apps', 'mimetypes', 'emblems')

STYLE = ('<style id="current-color-scheme" type="text/css">'
         '.ColorScheme-Text { color:#1b1b1b; } .ColorScheme-Background { color:#f3f3f3; } '
         '.ColorScheme-Highlight { color:#0078d4; } .ColorScheme-NegativeText { color:#c42b1c; } '
         '.ColorScheme-PositiveText { color:#0f7b0f; } .ColorScheme-NeutralText { color:#9d5d00; }'
         '</style>')

# Bibliotheken: eigenes 16er-Motiv statt Ordner (Explorer-Navigationsbereich)
SONDER16 = {'dokument', 'download', 'bilder', 'musik', 'videos', 'desktop'}
SONDER16_ORT = {'desktop': 'desktop', 'zuhause': 'haus'}

_draw = re.compile(r'<(path|circle|rect|ellipse|line|polyline|polygon)\b(?=[^>]*currentColor)')


def mono_svg(glyph, size, klasse='ColorScheme-Text'):
    body = _draw.sub(lambda m: f'<{m.group(1)} class="{klasse}"', glyph)
    if size in (22, 24):
        r = (size - 16) / 2
        vb = f'{-r:g} {-r:g} {size} {size}'
    else:
        vb = '0 0 16 16'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="{vb}">'
            f'<defs>{STYLE}</defs>{body}</svg>')


def svg16(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">{body}</svg>'


def farb_svg(spec):
    """Farbiges Symbol nach Spezifikation (siehe mapping.json/_comment). Liefert SVG-Text."""
    kind, _, rest = spec.partition(':')
    if kind == 'ordner':
        if rest in farbig.MOTIVE or not rest:
            return farbig.svg64(farbig.ordner(rest))
        # beliebige Glyphe in Ordnerbraun auf der Vorderseite
        gl = farbig.weiss(glyphs.GLYPHS[rest], '#8A5A00')
        return farbig.svg64(farbig.ordner('') + f'<g transform="translate(19 25) scale(1.625)" opacity=".85">{gl}</g>')
    if kind == 'ort':
        return farbig.svg64(farbig.ORTE[rest]())
    if kind == 'laufwerk':
        return farbig.svg64(farbig.laufwerk(rest))
    if kind == 'datei':
        return farbig.svg64(farbig.datei(rest))
    if kind == 'app':
        return farbig.svg64(farbig.app(rest))
    if kind == 'kachel':
        gl, _, farbe = rest.partition(':')
        return farbig.svg64(farbig.kachel_glyph(gl, farbe or 'blau'))
    if kind == 'hinweis':
        return farbig.svg64(farbig.hinweis(rest))
    if kind == 'abzeichen':
        return farbig.svg64(farbig.abzeichen(rest))
    if kind == 'wetter':
        return farbig.svg64(farbig.wetter(rest))
    if kind == 'tint':
        return mono_svg(glyphs.GLYPHS[rest], 16, 'ColorScheme-Highlight')
    raise ValueError(f'unbekannte Art {spec!r}')


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(data)


def link(path, target):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if os.path.lexists(path):
        os.remove(path)
    os.symlink(target, path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True, help='Zielverzeichnis des Themas (…/icons/fenstra)')
    ap.add_argument('--bedarf', help='Liste "kontext name" benutzter Namen (tools/vm/symbolbedarf.sh) für den Abdeckungsbericht')
    ap.add_argument('--fehlend', help='fehlende Namen des Berichts in diese Datei schreiben')
    a = ap.parse_args()

    mapping = json.load(open(os.path.join(HERE, 'mapping.json'), encoding='utf-8'))
    if os.path.exists(a.out):
        shutil.rmtree(a.out)
    dirs = set()
    names = set()
    files = 0

    # 1) einfarbige Kontexte
    for ctx in MONO_CTX:
        for name, gname in mapping.get(ctx, {}).items():
            for size in MONO_SIZES:
                write(os.path.join(a.out, ctx, str(size), name + '.svg'), mono_svg(glyphs.GLYPHS[gname], size))
                files += 1
            names.add(name)
        if mapping.get(ctx):
            dirs |= {(ctx, s) for s in MONO_SIZES}

    # 2) Einstellungen-Kategorien in Akzentfarbe
    for name, gname in mapping.get('preferences', {}).items():
        for size in MONO_SIZES:
            write(os.path.join(a.out, 'preferences', str(size), name + '.svg'),
                  mono_svg(glyphs.GLYPHS[gname], size, 'ColorScheme-Highlight'))
            files += 1
        names.add(name)
    dirs |= {('preferences', s) for s in MONO_SIZES}

    # 3) farbige Kontexte
    for ctx in FARB_CTX:
        for name, spec in mapping.get('farbig', {}).get(ctx, {}).items():
            kind, _, rest = spec.partition(':')
            path = os.path.join(a.out, ctx, 'scalable', name + '.svg')
            if kind == 'link':
                if not rest.startswith('/'):
                    raise SystemExit(f'{ctx}/{name}: link braucht einen absoluten Pfad')
                link(path, rest)
            else:
                write(path, farb_svg(spec))
            files += 1
            names.add(name)
            dirs.add((ctx, 'scalable'))
            # Bibliotheken: eigenes 16er-Motiv
            motiv = None
            if kind == 'ordner' and rest in SONDER16:
                motiv = rest
            elif kind == 'ort' and rest in SONDER16_ORT:
                motiv = SONDER16_ORT[rest]
            if motiv:
                write(os.path.join(a.out, ctx, '16', name + '.svg'), svg16(farbig.MOTIVE[motiv]()))
                dirs.add((ctx, 16))

    # 4) Aliasse als Symlinks
    mono_names = {ctx: mapping.get(ctx, {}) for ctx in MONO_CTX}
    for target, aliases in mapping.get('aliases', {}).items():
        parts = target.split('/')
        if parts[0] == 'farbig':
            ctx, tname = parts[1], parts[2]
            for n in aliases:
                if n == tname + '-symbolic' and n in mono_names.get(ctx, {}):
                    continue  # gibt es schon als eigenes einfarbiges Symbol
                if n.endswith('-symbolic') and (tname + '-symbolic') in mono_names.get(ctx, {}):
                    for size in MONO_SIZES:
                        link(os.path.join(a.out, ctx, str(size), n + '.svg'), tname + '-symbolic.svg')
                else:
                    if not os.path.lexists(os.path.join(a.out, ctx, 'scalable', tname + '.svg')):
                        continue
                    link(os.path.join(a.out, ctx, 'scalable', n + '.svg'), tname + '.svg')
                names.add(n)
        else:
            ctx, tname = parts
            for size in MONO_SIZES:
                if not os.path.exists(os.path.join(a.out, ctx, str(size), tname + '.svg')):
                    continue
                for n in aliases:
                    link(os.path.join(a.out, ctx, str(size), n + '.svg'), tname + '.svg')
            names.update(aliases)

    # 5) index.theme (feste Größen vor scalable, damit 16er-Sondermotive Vorrang haben)
    ordered = []
    for ctx in CTX_ORDER:
        for s in (16, 22, 24, 32, 48, 'scalable'):
            if (ctx, s) in dirs:
                ordered.append(f'{ctx}/{s}')
    lines = ['[Icon Theme]', 'Name=Fenstra', 'Name[de]=Fenstra',
             'Comment=Fenstra icons in the style of Windows 11, drawn from code',
             'Comment[de]=Fenstra-Symbole im Stil von Windows 11, aus Code erzeugt',
             'Inherits=hicolor', 'Example=folder', 'FollowsColorScheme=true', 'DisplayDepth=32',
             'Directories=' + ','.join(ordered), '']
    for d in ordered:
        ctx, size = d.split('/')
        if size == 'scalable':
            lines += [f'[{d}]', 'Size=64', 'MinSize=8', 'MaxSize=512', f'Context={CTX_NAME[ctx]}', 'Type=Scalable', '']
        else:
            lines += [f'[{d}]', f'Size={size}', f'Context={CTX_NAME[ctx]}', 'Type=Fixed', '']
    write(os.path.join(a.out, 'index.theme'), '\n'.join(lines))
    print(f'{files} Dateien, {len(names)} Namen, {len(ordered)} Verzeichnisse')

    # 6) Abdeckungsbericht: wie viele benutzte Namen findet die Symbolsuche (mit dem
    #    üblichen Rückfall „-symbolic“ weglassen bzw. letzten Namensteil abschneiden)?
    if a.bedarf:
        def finden(n):
            x = n
            while x:
                if x in names:
                    return x
                if x.endswith('-symbolic'):
                    x = x[:-len('-symbolic')]
                    continue
                if '-' not in x:
                    return None
                x = x.rsplit('-', 1)[0]
            return None
        rows = [ln.split() for ln in open(a.bedarf, encoding='utf-8') if ln.strip()]
        fehlend = [(c, n) for c, n in rows if not finden(n)]
        direkt = sum(1 for c, n in rows if n in names)
        print(f'Abdeckung: {len(rows) - len(fehlend)}/{len(rows)} '
              f'({100 * (len(rows) - len(fehlend)) / max(1, len(rows)):.1f} %), davon direkt {direkt}')
        if a.fehlend:
            with open(a.fehlend, 'w', encoding='utf-8') as f:
                for c, n in fehlend:
                    f.write(f'{c} {n}\n')


if __name__ == '__main__':
    main()
