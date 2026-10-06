#!/usr/bin/env python3
"""Fenstra-GTK-Design: Breeze-GTK als Grundlage, Titelleistenknöpfe wie Windows 11.

Hintergrund (Befund M3): KDE erzeugt für das GTK-Design „Breeze“ die Knopfbilder der
Titelleiste aus der KWin-Dekoration. Mit der Fenstra-Dekoration entstanden dabei winzige
Glyphen ohne Flächen (Firefox: Schließen praktisch unsichtbar). Für jedes andere GTK-Design
schaltet KDE diese Bilder ab; dieses Design zeichnet die Knöpfe deshalb selbst:
46×32 px, Glyphen 10 px, Hover hell #09000000 / dunkel #0FFFFFFF, Schließen #C42B1C.

Aufruf: erzeuge.py --out <verzeichnis>   (legt <verzeichnis>/Fenstra an)
"""
import argparse
import os

GLYPHEN = {
    'minimieren': '<rect x="0" y="4.5" width="10" height="1" fill="{c}"/>',
    'maximieren': '<rect x="0.5" y="0.5" width="9" height="9" rx="1" fill="none" stroke="{c}" stroke-width="1"/>',
    'wiederherstellen': ('<rect x="0.5" y="2.5" width="7" height="7" rx="1" fill="none" stroke="{c}" stroke-width="1"/>'
                         '<path d="M2.5 2.5V1.5a1 1 0 0 1 1-1h5a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1h-1" fill="none" stroke="{c}" stroke-width="1"/>'),
    'schliessen': '<path d="M0.35 0.35 9.65 9.65M9.65 0.35 0.35 9.65" fill="none" stroke="{c}" stroke-width="1"/>',
}
# Glyphenfarben (WinUI: TextFillColorPrimary, inaktiv TextFillColorDisabled)
FARBEN = {
    'hell': '#1B1B1B', 'hell-inaktiv': '#5C5C5C" opacity="0.6',
    'dunkel': '#FFFFFF', 'dunkel-inaktiv': '#FFFFFF" opacity="0.45',
    'weiss': '#FFFFFF', 'weiss70': '#FFFFFF" opacity="0.7',
}


def svg(glyphe, farbe):
    inhalt = GLYPHEN[glyphe].replace('{c}', FARBEN[farbe])
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 10 10">'
            f'<!-- Fenstra: Titelleisten-Glyphe, erzeugt von gtk/erzeuge.py -->{inhalt}</svg>\n')


def css(gtk4, dunkel):
    basis = 'gtk-dark.css' if dunkel else 'gtk.css'
    g = 'dunkel' if dunkel else 'hell'
    hover = 'rgba(255, 255, 255, 0.06)' if dunkel else 'rgba(0, 0, 0, 0.035)'
    druck = 'rgba(255, 255, 255, 0.04)' if dunkel else 'rgba(0, 0, 0, 0.024)'
    if gtk4:
        knopf = ['windowcontrols > button']
        bild = ['windowcontrols > button > image']
        maximiert = ['window.maximized windowcontrols > button.maximize']
    else:
        knopf = ['headerbar button.titlebutton', '.titlebar button.titlebutton']
        bild = ['headerbar button.titlebutton image', '.titlebar button.titlebutton image']
        maximiert = ['.maximized headerbar button.titlebutton.maximize', '.maximized .titlebar button.titlebutton.maximize']

    def sel(suffix, liste=None):
        return ',\n'.join(s + suffix for s in (liste or knopf))

    v = '../gtk-4.0' if gtk4 else '../gtk-3.0'
    zeilen = [
        f'/* Fenstra-GTK-Design ({"GTK 4" if gtk4 else "GTK 3"}, {"dunkel" if dunkel else "hell"}), erzeugt von gtk/erzeuge.py.',
        '   Grundlage Breeze-GTK; Titelleistenknöpfe wie Windows 11 (46×32, Glyphen 10 px). */',
        f'@import url("/usr/share/themes/Breeze/{"gtk-4.0" if gtk4 else "gtk-3.0"}/{basis}");',
        '',
        sel('') + ' {',
        '  min-width: 46px;',
        '  min-height: 32px;',
        '  margin: 0;',
        '  padding: 0;',
        '  border: none;',
        '  border-radius: 0;',
        '  box-shadow: none;',
        '  background-color: transparent;',
        '  background-repeat: no-repeat;',
        '  background-position: center;',
        '  background-size: 10px 10px;',
        '}',
        sel('', bild) + ' {',
        '  opacity: 0;',
        '}',
    ]
    for name, glyphe in (('minimize', 'minimieren'), ('maximize', 'maximieren'), ('close', 'schliessen')):
        zeilen += [
            sel(f'.{name}') + f' {{ background-image: url("{v}/assets/{glyphe}-{g}.svg"); }}',
            sel(f'.{name}:backdrop') + f' {{ background-image: url("{v}/assets/{glyphe}-{g}-inaktiv.svg"); }}',
        ]
    zeilen += [
        sel(':hover') + f' {{ background-color: {hover}; }}',
        sel(':active') + f' {{ background-color: {druck}; }}',
        sel('.close:hover') + f' {{ background-color: #C42B1C; background-image: url("{v}/assets/schliessen-weiss.svg"); }}',
        sel('.close:active') + f' {{ background-color: rgba(196, 43, 28, 0.9); background-image: url("{v}/assets/schliessen-weiss70.svg"); }}',
        ',\n'.join(maximiert) + f' {{ background-image: url("{v}/assets/wiederherstellen-{g}.svg"); }}',
    ]
    if not gtk4:
        # Knöpfe bündig in die obere rechte Ecke (Windows hat keinen Rand neben den Knöpfen)
        zeilen += ['headerbar { padding-right: 0; }']
    return '\n'.join(zeilen) + '\n'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    wurzel = os.path.join(a.out, 'Fenstra')
    for gtk in ('gtk-3.0', 'gtk-4.0'):
        d = os.path.join(wurzel, gtk)
        os.makedirs(os.path.join(d, 'assets'), exist_ok=True)
        for glyphe in GLYPHEN:
            for farbe in FARBEN:
                with open(os.path.join(d, 'assets', f'{glyphe}-{farbe}.svg'), 'w', encoding='utf-8') as f:
                    f.write(svg(glyphe, farbe))
        for dunkel in (False, True):
            with open(os.path.join(d, 'gtk-dark.css' if dunkel else 'gtk.css'), 'w', encoding='utf-8') as f:
                f.write(css(gtk == 'gtk-4.0', dunkel))
    with open(os.path.join(wurzel, 'index.theme'), 'w', encoding='utf-8') as f:
        f.write('[Desktop Entry]\nType=X-GNOME-Metatheme\nName=Fenstra\n'
                'Comment=Fenstra GTK theme (Breeze base, Windows 11 caption buttons)\n'
                'Comment[de]=Fenstra-GTK-Design (Breeze-Grundlage, Fensterknöpfe wie Windows 11)\n'
                'Encoding=UTF-8\n\n[X-GNOME-Metatheme]\nGtkTheme=Fenstra\n')
    print(wurzel)


if __name__ == '__main__':
    main()
