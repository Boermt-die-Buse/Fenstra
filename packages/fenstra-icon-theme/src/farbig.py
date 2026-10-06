#!/usr/bin/env python3
"""Fenstra: farbige Symbole im Stil von Windows 11 (Fluent-Farbstil), aus Code erzeugt.

Koordinaten 0..64 (viewBox), Verläufe von oben hell nach unten dunkler, weiche Formen,
keine Konturlinien außer feinen Kanten. Jede Funktion liefert den SVG-Inhalt (ohne
<svg>-Rahmen); svg64() setzt den Rahmen.

Inhalt:
  ordner(motiv)      gelber Ordner, optional mit farbigem Motiv auf der Vorderseite
  laufwerk(art)      Festplatte, USB-Stick, CD/DVD, Netzlaufwerk, Speicherkarte
  computer(), netzwerk(), papierkorb(voll), zuhause(), desktop()
  datei(art)         Dateitypen (Blatt mit Eselsohr + Motiv)
  app(name)          Programmsymbole der Fenstra-Apps (Explorer, Einstellungen, …)
"""
import itertools

_ids = itertools.count()


def uid(p):
    return f'{p}{next(_ids)}'


def lin(stops, x1=0, y1=0, x2=0, y2=1):
    i = uid('l')
    s = ''.join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in stops)
    return i, f'<linearGradient id="{i}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">{s}</linearGradient>'


def rad(stops, cx=0.5, cy=0.5, r=0.5):
    i = uid('r')
    s = ''.join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in stops)
    return i, f'<radialGradient id="{i}" cx="{cx}" cy="{cy}" r="{r}">{s}</radialGradient>'


def svg64(body, size=64):
    # Ausschnitt 3…61 statt 0…64: die Motive füllen ihr Feld wie Windows-Symbole (in der
    # Taskleiste z. B. 23 von 24 px statt 21); alle Motive liegen innerhalb von 3…61.
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="3 3 58 58">'
            f'<!-- Fenstra: erzeugt von packages/fenstra-icon-theme/src/farbig.py -->{body}</svg>')


# ---------------------------------------------------------------------------
# Ordner

FOLDER_BACK = 'M6 13a4 4 0 0 1 4-4h13.2a4 4 0 0 1 2.8 1.2l3.6 3.6a4 4 0 0 0 2.8 1.2H54a4 4 0 0 1 4 4V50a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z'
FOLDER_FRONT = 'M6 25a4 4 0 0 1 4-4h44a4 4 0 0 1 4 4v25a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z'


def ordner(motiv=''):
    gb, db = lin([(0, '#E8A31B'), (1, '#D18A0F')])
    gf, df = lin([(0, '#FFD45E'), (0.6, '#FCC33D'), (1, '#F4AF26')])
    gl, dl = lin([(0, '#FFFFFF')], 0, 0, 0, 1)
    body = (f'<defs>{db}{df}</defs>'
            f'<path d="{FOLDER_BACK}" fill="url(#{gb})"/>'
            f'<path d="{FOLDER_FRONT}" fill="url(#{gf})"/>'
            # feine helle Kante oben an der Vorderseite
            f'<path d="M10 21.6h44a3.4 3.4 0 0 1 3.4 3.4" fill="none" stroke="#FFF2C4" stroke-opacity=".7" stroke-width="1"/>')
    if motiv:
        body += f'<g transform="translate(20 27) scale(1.5)">{MOTIVE[motiv]()}</g>'
    return body


# Motive auf der Vorderseite (16×16-Raster, farbig)
def m_dokument():
    g, d = lin([(0, '#4E9BFF'), (1, '#2F6FD6')])
    return (f'<defs>{d}</defs><path d="M3.5 1.5h6l3.5 3.5v9a1 1 0 0 1-1 1h-8.5a1 1 0 0 1-1-1V2.5a1 1 0 0 1 1-1z" fill="url(#{g})"/>'
            '<path d="M9.5 1.5V4a1 1 0 0 0 1 1h2.5" fill="#BFD9FF"/>'
            '<path d="M5 8h6M5 10.5h6M5 13h4" stroke="#FFFFFF" stroke-width="1.1" stroke-linecap="round"/>')


def m_download():
    g, d = lin([(0, '#39C46B'), (1, '#1C9A4C')])
    return (f'<defs>{d}</defs><circle cx="8" cy="8" r="7" fill="url(#{g})"/>'
            '<path d="M8 4v7M5 8.2l3 3 3-3" fill="none" stroke="#FFFFFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>')


def m_bilder():
    g, d = lin([(0, '#62C4FF'), (1, '#2C8FE6')])
    g2, d2 = lin([(0, '#7DD86B'), (1, '#3EA33A')])
    return (f'<defs>{d}{d2}</defs><rect x="1" y="2.5" width="14" height="11" rx="2" fill="url(#{g})"/>'
            '<circle cx="5.2" cy="6.2" r="1.5" fill="#FFF1A8"/>'
            f'<path d="M1 11.5l4-3.6 3 2.6 2.7-2.2L15 12v-.5 0 1.5a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 1 12z" fill="url(#{g2})"/>')


def m_musik():
    g, d = lin([(0, '#FF8A4C'), (1, '#E5532A')])
    return (f'<defs>{d}</defs><path d="M6 12V3.8l7.5-1.8v8.6" fill="none" stroke="url(#{g})" stroke-width="1.6" stroke-linejoin="round"/>'
            f'<circle cx="4.3" cy="12" r="2.3" fill="url(#{g})"/><circle cx="11.8" cy="10.6" r="2.3" fill="url(#{g})"/>')


def m_videos():
    g, d = lin([(0, '#A97DFF'), (1, '#7A4BE0')])
    return (f'<defs>{d}</defs><rect x="1" y="2.5" width="14" height="11" rx="2" fill="url(#{g})"/>'
            '<path d="M6.5 5.5v5l4.2-2.5z" fill="#FFFFFF"/>')


def m_vorlagen():
    return ('<rect x="2.5" y="2" width="11" height="12" rx="1.5" fill="#FFFFFF" stroke="#9A6A12" stroke-width=".8"/>'
            '<path d="M5 5.5h6M5 8h6M5 10.5h3.5" stroke="#9A6A12" stroke-width="1" stroke-linecap="round" stroke-dasharray="1.2 1"/>')


def m_oeffentlich():
    return ('<circle cx="5.6" cy="5.4" r="2.1" fill="#3B82D8"/><path d="M1.6 13c.3-2.2 1.8-3.6 4-3.6s3.7 1.4 4 3.6z" fill="#3B82D8"/>'
            '<circle cx="11" cy="5.8" r="1.8" fill="#5FA4F0"/><path d="M8.7 9.9c.7-.5 1.4-.7 2.3-.7 1.9 0 3.1 1.3 3.4 3.4h-4.5" fill="#5FA4F0"/>')


def m_zip():
    return ('<rect x="6.8" y="0" width="2.4" height="15" fill="#6B4A10" opacity=".25"/>'
            '<path d="M7 1h2v2H7zM9 3h-2v2h2zM7 5h2v2H7zM9 7H7v2h2z" fill="#6B4A10"/>'
            '<rect x="6.2" y="9.2" width="3.6" height="4.2" rx=".8" fill="#E9E9E9" stroke="#6B4A10" stroke-width=".7"/>')


def m_cloud():
    return '<path d="M4.6 12.5a3 3 0 0 1-.3-6 4 4 0 0 1 7.6.6 2.7 2.7 0 0 1 0 5.4z" fill="#2F8FE8"/>'


def m_netz():
    return ('<circle cx="8" cy="8" r="6.5" fill="#3B8CE8"/>'
            '<path d="M1.5 8h13M8 1.5c-1.8 1.8-2.6 4-2.6 6.5s.8 4.7 2.6 6.5M8 1.5c1.8 1.8 2.6 4 2.6 6.5s-.8 4.7-2.6 6.5" fill="none" stroke="#DDEEFF" stroke-width=".9"/>')


def m_spiele():
    return ('<path d="M4.5 4.5h7a3.5 3.5 0 0 1 3.4 4.3l-.8 3.2a1.6 1.6 0 0 1-2.8.6L9.6 10.5H6.4l-1.7 2.1a1.6 1.6 0 0 1-2.8-.6l-.8-3.2A3.5 3.5 0 0 1 4.5 4.5z" fill="#5A5A66"/>'
            '<path d="M5 6.5V9M3.8 7.75h2.4" stroke="#FFFFFF" stroke-width="1" stroke-linecap="round"/><circle cx="10.5" cy="7" r=".8" fill="#FF6B6B"/><circle cx="12" cy="8.5" r=".8" fill="#4EC3FF"/>')


def m_code():
    return '<path d="M5 4.5L1.5 8 5 11.5M11 4.5L14.5 8 11 11.5M9.2 2.5L6.8 13.5" fill="none" stroke="#2F6FD6" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>'


def m_stern():
    return '<path d="M8 1.6l1.9 4.1 4.4.5-3.3 3 .9 4.4L8 11.4 4.1 13.6 5 9.2 1.7 6.2l4.4-.5z" fill="#F7B500"/>'


def m_haus():
    return '<path d="M2 7.5L8 2.3l6 5.2v6.2a1 1 0 0 1-1 1H9.5v-4h-3v4H3a1 1 0 0 1-1-1z" fill="#3B82D8"/>'


def m_schloss():
    return '<rect x="3" y="7" width="10" height="7.5" rx="1.5" fill="#6A6A72"/><path d="M5.5 7V5a2.5 2.5 0 0 1 5 0v2" fill="none" stroke="#6A6A72" stroke-width="1.4"/>'


def m_papierkorb():
    return ('<path d="M3.5 4.5l.8 9.1a1 1 0 0 0 1 .9h5.4a1 1 0 0 0 1-.9l.8-9.1z" fill="#7C8A99"/>'
            '<path d="M2 4.5h12" stroke="#5B6875" stroke-width="1.2" stroke-linecap="round"/>')


def m_desktop():
    g, d = lin([(0, '#4FB2FF'), (1, '#2275D6')])
    return (f'<defs>{d}</defs><rect x="1" y="2" width="14" height="9.5" rx="1.5" fill="url(#{g})"/>'
            '<path d="M8 11.5v2M5 14h6" stroke="#5B6875" stroke-width="1.3" stroke-linecap="round"/>')


MOTIVE = {
    'dokument': m_dokument, 'download': m_download, 'bilder': m_bilder, 'musik': m_musik,
    'videos': m_videos, 'vorlagen': m_vorlagen, 'oeffentlich': m_oeffentlich, 'zip': m_zip,
    'cloud': m_cloud, 'netz': m_netz, 'spiele': m_spiele, 'code': m_code, 'stern': m_stern,
    'haus': m_haus, 'schloss': m_schloss, 'papierkorb': m_papierkorb, 'desktop': m_desktop,
}


# ---------------------------------------------------------------------------
# Laufwerke, Computer, Netzwerk, Papierkorb

def laufwerk(art='festplatte'):
    if art == 'usb':
        gb, db = lin([(0, '#F2F2F4'), (1, '#C9CBD1')])
        gc, dc = lin([(0, '#4EA2FF'), (1, '#2369C9')])
        return (f'<defs>{db}{dc}</defs><rect x="22" y="6" width="20" height="14" rx="2" fill="#BFC3CA"/>'
                '<rect x="26" y="9" width="4" height="4" fill="#7B828C"/><rect x="34" y="9" width="4" height="4" fill="#7B828C"/>'
                f'<rect x="17" y="18" width="30" height="40" rx="6" fill="url(#{gb})"/>'
                f'<rect x="17" y="40" width="30" height="18" rx="6" fill="url(#{gc})"/><rect x="17" y="40" width="30" height="6" fill="url(#{gc})"/>')
    if art == 'optisch':
        g, d = rad([(0, '#FFFFFF'), (0.35, '#E6E8EF'), (0.7, '#C8D4F2'), (0.85, '#E8D7F5'), (1, '#BFC6D6')])
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="26" fill="url(#{g})"/>'
                '<circle cx="32" cy="32" r="26" fill="none" stroke="#9AA3B3" stroke-width="1"/>'
                '<circle cx="32" cy="32" r="7" fill="#E9ECF2" stroke="#9AA3B3" stroke-width="1"/><circle cx="32" cy="32" r="3" fill="#FFFFFF"/>')
    if art == 'karte':
        g, d = lin([(0, '#5D6672'), (1, '#3B424C')])
        return (f'<defs>{d}</defs><path d="M18 8h20l10 10v36a3 3 0 0 1-3 3H18a3 3 0 0 1-3-3V11a3 3 0 0 1 3-3z" fill="url(#{g})"/>'
                '<path d="M22 8v8M27 8v8M32 8v8M37 8v8" stroke="#E8B64C" stroke-width="2.4"/>')
    # Festplatte (Windows 11: hellgraue Platte mit dunklem Streifen und Leuchte)
    gb, db = lin([(0, '#F4F5F7'), (1, '#D3D6DC')])
    gs, ds = lin([(0, '#6E7682'), (1, '#4C535D')])
    body = (f'<defs>{db}{ds}</defs>'
            f'<rect x="6" y="18" width="52" height="30" rx="5" fill="url(#{gb})"/>'
            '<rect x="6" y="18" width="52" height="30" rx="5" fill="none" stroke="#A8AEB8" stroke-width="1"/>'
            f'<rect x="11" y="36" width="42" height="6" rx="2" fill="url(#{gs})"/>'
            '<circle cx="48" cy="27" r="2.2" fill="#3FC96B"/>')
    if art == 'system':
        # Systemlaufwerk C: mit kleinem Fenstra-Fenster (wie das Windows-Logo auf C:)
        body += ('<rect x="10" y="22" width="11" height="9" rx="1.2" fill="#1E78D6"/>'
                 '<path d="M10.5 25h10M15.5 22.5v8" stroke="#BFE0FF" stroke-width=".9"/>')
    if art == 'netz':
        body += '<g transform="translate(36 30) scale(1.4)">' + m_netz() + '</g>'
    return body


def computer():
    gs, ds = lin([(0, '#4FC1FF'), (0.5, '#2A8FEA'), (1, '#1C6BD0')])
    gf, df = lin([(0, '#E9EBEF'), (1, '#BDC2CA')])
    return (f'<defs>{ds}{df}</defs>'
            f'<rect x="5" y="9" width="54" height="36" rx="4" fill="url(#{gf})"/>'
            f'<rect x="8" y="12" width="48" height="30" rx="2" fill="url(#{gs})"/>'
            '<path d="M8 33c14-8 30-9 48-4v11a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2z" fill="#FFFFFF" opacity=".12"/>'
            '<path d="M28 45h8l2 8H26z" fill="#AEB4BD"/><rect x="20" y="52" width="24" height="4" rx="2" fill="#8E95A0"/>')


def netzwerk():
    return computer() + '<g transform="translate(34 26) scale(1.6)">' + m_netz() + '</g>'


def papierkorb(voll=False):
    """Windows-11-Papierkorb: durchscheinender Eimer, bei Inhalt mit Papieren."""
    gb, db = lin([(0, '#EEF4FB'), (1, '#C5D3E3')])
    body = f'<defs>{db}</defs>'
    if voll:
        body += ('<path d="M20 22l6-14 12 5-5 11z" fill="#FFFFFF" stroke="#9FB0C3" stroke-width="1"/>'
                 '<path d="M30 21l8-11 9 8-7 6z" fill="#FFF6D6" stroke="#C9B26A" stroke-width="1"/>'
                 '<path d="M23 17h7M24 20h6" stroke="#9FB0C3" stroke-width="1"/>')
    body += (f'<path d="M13 20h38l-3.6 33a4 4 0 0 1-4 3.6H20.6a4 4 0 0 1-4-3.6z" fill="url(#{gb})" opacity=".92"/>'
             '<path d="M13 20h38l-3.6 33a4 4 0 0 1-4 3.6H20.6a4 4 0 0 1-4-3.6z" fill="none" stroke="#8EA2B8" stroke-width="1.2"/>'
             '<path d="M24 26l1.4 24M32 26v24M40 26l-1.4 24" stroke="#8EA2B8" stroke-width="1.6" stroke-linecap="round" opacity=".7"/>'
             '<rect x="10" y="16" width="44" height="5" rx="2.5" fill="#A9B8C9"/>')
    return body


def zuhause():
    g, d = lin([(0, '#55B5FF'), (1, '#2272D6')])
    return (f'<defs>{d}</defs><path d="M10 28L32 9l22 19v24a4 4 0 0 1-4 4H39V40H25v16H14a4 4 0 0 1-4-4z" fill="url(#{g})"/>'
            '<path d="M6 30L32 7l26 23" fill="none" stroke="#1659B5" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>')


def desktop_ort():
    return ('<g transform="scale(4)">' + m_desktop() + '</g>')


# ---------------------------------------------------------------------------
# Dateitypen: weißes Blatt mit Eselsohr, farbiges Motiv

PAGE = 'M14 5h24l14 14v36a4 4 0 0 1-4 4H14a4 4 0 0 1-4-4V9a4 4 0 0 1 4-4z'
FOLD = 'M38 5v10a4 4 0 0 0 4 4h10z'


def blatt(inhalt='', fold_color='#D6DCE5'):
    g, d = lin([(0, '#FFFFFF'), (1, '#F1F3F6')])
    return (f'<defs>{d}</defs><path d="{PAGE}" fill="url(#{g})"/>'
            f'<path d="{PAGE}" fill="none" stroke="#B9C1CC" stroke-width="1.2"/>'
            f'<path d="{FOLD}" fill="{fold_color}"/>' + inhalt)


def band(color, text, y=36):
    return (f'<rect x="6" y="{y}" width="34" height="15" rx="2.5" fill="{color}"/>'
            f'<text x="23" y="{y + 11.2}" font-family="Selawik, sans-serif" font-size="10.5" font-weight="700" '
            f'text-anchor="middle" fill="#FFFFFF">{text}</text>')


def datei(art):
    lines = '<path d="M18 26h22M18 32h22M18 38h22M18 44h14" stroke="#A7B1BE" stroke-width="2" stroke-linecap="round"/>'
    if art == 'text':
        return blatt(lines)
    if art == 'pdf':
        return blatt(lines + band('#D7262E', 'PDF'))
    if art == 'bild':
        return blatt('<g transform="translate(14 22) scale(2.2)">' + m_bilder() + '</g>')
    if art == 'audio':
        return blatt('<g transform="translate(15 22) scale(2.1)">' + m_musik() + '</g>')
    if art == 'video':
        return blatt('<g transform="translate(14 22) scale(2.2)">' + m_videos() + '</g>')
    if art == 'archiv':
        return svg_ordner_zip()
    if art == 'html':
        return blatt('<g transform="translate(15 22) scale(2.1)">' + m_netz() + '</g>')
    if art == 'code':
        return blatt('<g transform="translate(14 22) scale(2.2)">' + m_code() + '</g>')
    if art == 'skript':
        return blatt('<path d="M18 28l6 5-6 5M27 40h10" fill="none" stroke="#3A4452" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>')
    if art == 'dokument':
        return blatt(lines + band('#2B6CD4', 'DOC'))
    if art == 'tabelle':
        return blatt('<rect x="17" y="25" width="26" height="22" rx="2" fill="#E5F4EA" stroke="#1E8A47" stroke-width="1.6"/>'
                     '<path d="M17 32.3h26M17 39.6h26M26 25v22M34.5 25v22" stroke="#1E8A47" stroke-width="1.4"/>')
    if art == 'praesentation':
        return blatt('<rect x="16" y="25" width="28" height="19" rx="2" fill="#FFE9DE" stroke="#D9531E" stroke-width="1.6"/>'
                     '<path d="M21 40V34M27 40v-9M33 40v-5M39 40V30" stroke="#D9531E" stroke-width="2.6" stroke-linecap="round"/>')
    if art == 'schrift':
        return blatt('<text x="30" y="47" font-family="Selawik, serif" font-size="22" font-weight="700" text-anchor="middle" fill="#3A4452">Aa</text>')
    if art == 'programm':
        g, d = lin([(0, '#4EA2FF'), (1, '#2266CC')])
        return (f'<defs>{d}</defs><rect x="8" y="12" width="48" height="40" rx="5" fill="#F4F6F9" stroke="#A9B2BF" stroke-width="1.2"/>'
                f'<path d="M8 17a5 5 0 0 1 5-5h38a5 5 0 0 1 5 5v5H8z" fill="url(#{g})"/>'
                '<circle cx="14" cy="17" r="1.6" fill="#FFFFFF"/><circle cx="19" cy="17" r="1.6" fill="#FFFFFF"/>'
                '<path d="M16 32h32M16 38h24M16 44h28" stroke="#C3CAD4" stroke-width="2.2" stroke-linecap="round"/>')
    if art == 'paket':
        g, d = lin([(0, '#D9A66B'), (1, '#B07A3E')])
        return (f'<defs>{d}</defs><path d="M32 6l24 11v30L32 58 8 47V17z" fill="url(#{g})"/>'
                '<path d="M8 17l24 11 24-11M32 28v30" fill="none" stroke="#8A5B28" stroke-width="1.4"/>'
                '<path d="M20 11.5l24 11v8" fill="none" stroke="#F2D9B4" stroke-width="3"/>')
    if art == 'abbild':
        return laufwerk('optisch')
    if art == 'zertifikat':
        return blatt(lines + '<circle cx="40" cy="44" r="7" fill="#F2B21B"/><path d="M36 49l-2 8 6-3 6 3-2-8" fill="#E08D00"/>')
    if art == 'kalender':
        return blatt('<rect x="16" y="24" width="28" height="24" rx="2.5" fill="#FFFFFF" stroke="#D13438" stroke-width="1.6"/>'
                     '<path d="M16 26.5a2.5 2.5 0 0 1 2.5-2.5h23a2.5 2.5 0 0 1 2.5 2.5V31H16z" fill="#D13438"/>'
                     '<text x="30" y="45" font-family="Selawik, sans-serif" font-size="12" font-weight="700" text-anchor="middle" fill="#3A4452">31</text>')
    if art == 'kontakt':
        return blatt('<circle cx="30" cy="31" r="6" fill="#3B82D8"/><path d="M19 48c1-6 5.4-9 11-9s10 3 11 9z" fill="#3B82D8"/>')
    if art == 'email':
        return blatt('<rect x="15" y="26" width="30" height="20" rx="2.5" fill="#E8F1FC" stroke="#2B6CD4" stroke-width="1.6"/>'
                     '<path d="M16 27.5l14 10 14-10" fill="none" stroke="#2B6CD4" stroke-width="1.6"/>')
    if art == 'leer':
        return blatt('')
    if art == 'torrent':
        return blatt('<path d="M24 26v10a6 6 0 0 0 12 0V26" fill="none" stroke="#2BA24C" stroke-width="5"/>'
                     '<path d="M21 26h6M33 26h6" stroke="#2BA24C" stroke-width="5"/>')
    if art == 'datenbank':
        return blatt('<g transform="translate(16 24) scale(1.75)"><path d="M2.5 4c0-1.4 2.5-2.5 5.5-2.5s5.5 1.1 5.5 2.5v8c0 1.4-2.5 2.5-5.5 2.5S2.5 13.4 2.5 12z" fill="#8F6CD9"/>'
                     '<path d="M2.5 4c0 1.4 2.5 2.5 5.5 2.5s5.5-1.1 5.5-2.5" fill="none" stroke="#E3D8FA" stroke-width=".9"/></g>')
    if art == 'diskimage':
        return laufwerk('festplatte')
    if art == 'verknuepfung':
        return blatt('<path d="M24 42l14-14M30 27h9v9" fill="none" stroke="#2B6CD4" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>')
    return blatt('')


def svg_ordner_zip():
    """Komprimierter Ordner (Windows: Ordner mit Reißverschluss)"""
    return ordner('') + ('<path d="M30 21v33h4V21z" fill="#8A5A10" opacity=".25"/>'
                         '<path d="M30 21h4v3h-4zM30 27h4v3h-4zM30 33h4v3h-4z" fill="#7A4E0A"/>'
                         '<rect x="28" y="38" width="8" height="10" rx="2" fill="#F1F1F1" stroke="#7A4E0A" stroke-width="1.2"/>')


# ---------------------------------------------------------------------------
# Programmsymbole (eigene Fenstra-Apps; ersetzen auch die Symbole der KDE-Apps)

def kachel(g0, g1, inhalt, radius=12):
    g, d = lin([(0, g0), (1, g1)], 0, 0, 0.3, 1)
    return (f'<defs>{d}</defs><rect x="4" y="4" width="56" height="56" rx="{radius}" fill="url(#{g})"/>'
            f'<rect x="4.5" y="4.5" width="55" height="55" rx="{radius - .5}" fill="none" stroke="#000000" stroke-opacity=".08"/>' + inhalt)


def app(name):
    if name == 'explorer':
        # Windows-11-Explorer: gelber Ordner mit blauem Band
        gb, db = lin([(0, '#3FA8FF'), (1, '#1E6FD9')])
        return ordner('') + (f'<defs>{db}</defs><rect x="6" y="38" width="52" height="10" fill="url(#{gb})"/>'
                             '<path d="M6 48h52v2a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z" fill="#F4AF26"/>')
    if name == 'einstellungen':
        import glyphs
        gear = glyphs.gear_path(32, 32, 24, 18, teeth=8, tooth=0.46)
        g, d = lin([(0, '#8C96A6'), (1, '#5A6372')])
        return (f'<defs>{d}</defs><path d="{gear}" fill="url(#{g})"/>'
                '<circle cx="32" cy="32" r="9" fill="#F4F6F9"/><circle cx="32" cy="32" r="9" fill="none" stroke="#4A5260" stroke-width="1.2"/>')
    if name == 'terminal':
        return kachel('#3A3F48', '#1F2329',
                      '<rect x="4" y="4" width="56" height="10" rx="0" fill="#000000" opacity=".18"/>'
                      '<path d="M15 26l10 8-10 8" fill="none" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>'
                      '<path d="M30 44h18" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>')
    if name == 'editor':
        g, d = lin([(0, '#57A7FF'), (1, '#2C6FD1')])
        return (f'<defs>{d}</defs><rect x="10" y="6" width="44" height="52" rx="5" fill="#FFFFFF" stroke="#AEB8C5" stroke-width="1.2"/>'
                f'<path d="M10 11a5 5 0 0 1 5-5h34a5 5 0 0 1 5 5v6H10z" fill="url(#{g})"/>'
                '<path d="M18 27h28M18 34h28M18 41h28M18 48h18" stroke="#A9B4C2" stroke-width="2.4" stroke-linecap="round"/>'
                '<path d="M44 35l9-9 4 4-9 9-5 1z" fill="#F2B21B" stroke="#9C6A00" stroke-width="1"/>')
    if name == 'rechner':
        tasten = ''
        for r in range(4):
            for c in range(4):
                col = '#2B7BE0' if (r == 3 and c == 3) else '#4A505B'
                tasten += f'<rect x="{13 + c * 10}" y="{27 + r * 7.5}" width="8" height="5.5" rx="1.5" fill="{col}"/>'
        return kachel('#2C3038', '#1B1E23', '<rect x="13" y="12" width="38" height="10" rx="2" fill="#E9F1FB"/>' + tasten)
    if name == 'fotos':
        g, d = lin([(0, '#55C8FF'), (1, '#2E7FE0')])
        g2, d2 = lin([(0, '#8EDB6A'), (1, '#3E9F3A')])
        return (f'<defs>{d}{d2}</defs><rect x="6" y="10" width="52" height="44" rx="8" fill="url(#{g})"/>'
                '<circle cx="21" cy="24" r="5" fill="#FFF1A8"/>'
                f'<path d="M6 46l15-13 11 9 10-8 16 14v-2 4a8 8 0 0 1-8 8H14a8 8 0 0 1-8-8z" fill="url(#{g2})"/>')
    if name == 'medien':
        g, d = lin([(0, '#FF9A3D'), (1, '#E5542A')])
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
                '<path d="M26 20v24l19-12z" fill="#FFFFFF"/>')
    if name == 'taskmanager':
        return kachel('#2A86E8', '#175FC0',
                      '<path d="M12 42h8l5-14 7 22 6-16 4 8h10" fill="none" stroke="#FFFFFF" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/>')
    if name == 'ausschneiden':
        return kachel('#FF6B8B', '#D93A64',
                      '<circle cx="22" cy="44" r="6" fill="none" stroke="#FFFFFF" stroke-width="3.5"/>'
                      '<circle cx="42" cy="44" r="6" fill="none" stroke="#FFFFFF" stroke-width="3.5"/>'
                      '<path d="M25 39L43 13M39 39L21 13" stroke="#FFFFFF" stroke-width="3.5" stroke-linecap="round"/>')
    if name == 'store':
        g, d = lin([(0, '#F4F6F9'), (1, '#D5DAE2')])
        # Einkaufstasche, groß im Feld (vorher wirkte sie in der Taskleiste winzig)
        return (f'<defs>{d}</defs><path d="M6 21h52l-3.4 34.6a4 4 0 0 1-4 3.4H13.4a4 4 0 0 1-4-3.4z" fill="url(#{g})"/>'
                '<path d="M6 21h52l-3.4 34.6a4 4 0 0 1-4 3.4H13.4a4 4 0 0 1-4-3.4z" fill="none" stroke="#A9B2BF" stroke-width="1"/>'
                '<path d="M22 21v-5a10 10 0 0 1 20 0v5" fill="none" stroke="#6B7584" stroke-width="3.6" stroke-linecap="round"/>'
                '<rect x="17" y="27" width="14" height="13" rx="2" fill="#F25022"/><rect x="33" y="27" width="14" height="13" rx="2" fill="#7FBA00"/>'
                '<rect x="17" y="42" width="14" height="13" rx="2" fill="#00A4EF"/><rect x="33" y="42" width="14" height="13" rx="2" fill="#FFB900"/>')
    if name == 'hilfe':
        g, d = lin([(0, '#4EA8FF'), (1, '#1F6ED6')])
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
                '<path d="M25 25a7 7 0 1 1 10 6.3c-1.8.9-3 2.4-3 4.3V38" fill="none" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round"/>'
                '<circle cx="32" cy="46" r="2.8" fill="#FFFFFF"/>')
    if name == 'browser':
        g, d = rad([(0, '#6CD2FF'), (1, '#1E6ED6')], 0.35, 0.3, 0.8)
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
                '<path d="M5 32h54M32 5c-7 7-10 16-10 27s3 20 10 27M32 5c7 7 10 16 10 27s-3 20-10 27M9 18h46M9 46h46" fill="none" stroke="#DDF1FF" stroke-width="2" opacity=".85"/>')
    if name == 'archivprogramm':
        return svg_ordner_zip()
    if name == 'pdfleser':
        return datei('pdf')
    if name == 'konsole_alt':
        return app('terminal')
    if name == 'systemmonitor':
        return app('taskmanager')
    if name == 'installer':
        return laufwerk('optisch')
    raise KeyError(name)


# Symbole für "Dieser PC" in der Navigationsleiste usw.
ORTE = {
    'computer': computer,
    'netzwerk': netzwerk,
    'papierkorb-leer': lambda: papierkorb(False),
    'papierkorb-voll': lambda: papierkorb(True),
    'zuhause': zuhause,
    'desktop': desktop_ort,
}


# ---------------------------------------------------------------------------
# Ergänzungen: Hinweise (Meldungsfenster), Abzeichen, Kacheln mit Glyphe, weitere Geräte

def hinweis(art):
    """Symbole der Meldungsfenster (Windows: blaues i, gelbes Dreieck, rotes X, blaues ?)."""
    if art == 'warnung':
        g, d = lin([(0, '#FFD75E'), (1, '#F2A900')])
        return (f'<defs>{d}</defs><path d="M28.5 8.1a4 4 0 0 1 7 0l23.7 42a4 4 0 0 1-3.5 6H8.3a4 4 0 0 1-3.5-6z" fill="url(#{g})"/>'
                '<path d="M32 22v17" stroke="#3B2A00" stroke-width="5" stroke-linecap="round"/><circle cx="32" cy="47" r="3.2" fill="#3B2A00"/>')
    farben = {'info': ('#4AA3FF', '#0063C6'), 'frage': ('#4AA3FF', '#0063C6'),
              'fehler': ('#F0646E', '#C42B1C'), 'erfolg': ('#3CC157', '#0F7B0F')}
    c0, c1 = farben[art]
    g, d = lin([(0, c0), (1, c1)])
    body = f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
    if art == 'info':
        body += '<path d="M32 29v16" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/><circle cx="32" cy="20.5" r="3.3" fill="#FFFFFF"/>'
    elif art == 'frage':
        body += ('<path d="M25 25a7 7 0 1 1 10 6.3c-1.8.9-3 2.4-3 4.3V37" fill="none" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>'
                 '<circle cx="32" cy="45.5" r="3.2" fill="#FFFFFF"/>')
    elif art == 'fehler':
        body += '<path d="M23 23l18 18M41 23L23 41" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>'
    else:
        body += '<path d="M21 33l7.5 7.5L43.5 25" fill="none" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'
    return body


def abzeichen(art):
    """Überlagerungen (Dolphin zeichnet sie klein in eine Ecke)."""
    if art == 'verknuepfung':
        # Windows: weißes Kästchen mit blauem, gebogenem Pfeil
        return ('<rect x="6" y="6" width="52" height="52" rx="8" fill="#FFFFFF" stroke="#8A97A6" stroke-width="3"/>'
                '<path d="M20 46c0-12 7-18 20-18" fill="none" stroke="#1E6FD6" stroke-width="7" stroke-linecap="round"/>'
                '<path d="M33 18l12 10-12 10z" fill="#1E6FD6"/>')
    if art == 'schloss':
        g, d = lin([(0, '#FFD45E'), (1, '#E5A000')])
        return (f'<defs>{d}</defs><path d="M20 28v-7a12 12 0 0 1 24 0v7" fill="none" stroke="#6E7682" stroke-width="6"/>'
                f'<rect x="12" y="27" width="40" height="31" rx="6" fill="url(#{g})"/><circle cx="32" cy="41" r="4" fill="#7A5200"/>')
    if art == 'offen':
        g, d = lin([(0, '#FFD45E'), (1, '#E5A000')])
        return (f'<defs>{d}</defs><path d="M20 28v-7a12 12 0 0 1 23-4.5" fill="none" stroke="#6E7682" stroke-width="6"/>'
                f'<rect x="12" y="27" width="40" height="31" rx="6" fill="url(#{g})"/><circle cx="32" cy="41" r="4" fill="#7A5200"/>')
    if art == 'stern':
        return '<g transform="scale(4)">' + m_stern() + '</g>'
    if art == 'sync':
        g, d = lin([(0, '#4AA3FF'), (1, '#0063C6')])
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
                '<path d="M20 30a12 12 0 0 1 21-7M44 34a12 12 0 0 1-21 7" fill="none" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round"/>'
                '<path d="M43 15v9h-9M21 49v-9h9" fill="none" stroke="#FFFFFF" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>')
    if art == 'geteilt':
        g, d = lin([(0, '#4AA3FF'), (1, '#0063C6')])
        return (f'<defs>{d}</defs><circle cx="32" cy="32" r="27" fill="url(#{g})"/>'
                '<g transform="translate(14 14) scale(2.25)">' + weiss(_glyph('people')) + '</g>')
    if art == 'pause':
        return ('<circle cx="32" cy="32" r="27" fill="#6E7682"/>'
                '<path d="M26 22v20M38 22v20" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>')
    if art == 'minus':
        return '<circle cx="32" cy="32" r="27" fill="#C42B1C"/><path d="M21 32h22" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>'
    if art == 'plus':
        return ('<circle cx="32" cy="32" r="27" fill="#0F7B0F"/>'
                '<path d="M21 32h22M32 21v22" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>')
    if art == 'geaendert':
        return ('<circle cx="32" cy="32" r="27" fill="#9D5D00"/>'
                '<g transform="translate(14 14) scale(2.25)">' + weiss(_glyph('edit')) + '</g>')
    return hinweis(art)


def _glyph(name):
    import glyphs
    return glyphs.GLYPHS[name]


def weiss(svg, farbe='#FFFFFF'):
    return svg.replace('currentColor', farbe)


KACHELFARBEN = {
    'blau': ('#3A9BFF', '#1A5FC4'), 'hellblau': ('#4CC2FF', '#0A84D8'), 'gruen': ('#3CC157', '#107C10'),
    'rot': ('#F0646E', '#C42B1C'), 'orange': ('#FF9A3D', '#D9531E'), 'lila': ('#A97DFF', '#6B3FD0'),
    'grau': ('#8C96A6', '#5A6372'), 'dunkel': ('#3A3F48', '#1F2329'), 'gelb': ('#FFD45E', '#E5A000'),
    'tuerkis': ('#2FD3C6', '#0A8F8A'), 'pink': ('#FF6B8B', '#D93A64'),
}


def kachel_glyph(glyph, farbe='blau'):
    """Kachel mit weißer Glyphe – für Programme ohne eigenes Motiv."""
    c0, c1 = KACHELFARBEN[farbe]
    fg = '#3B2A00' if farbe == 'gelb' else '#FFFFFF'
    return kachel(c0, c1, '<g transform="translate(14 14) scale(2.25)">' + weiss(_glyph(glyph), fg) + '</g>')


def laptop():
    gs, ds = lin([(0, '#4FC1FF'), (0.5, '#2A8FEA'), (1, '#1C6BD0')])
    return (f'<defs>{ds}</defs><rect x="10" y="12" width="44" height="30" rx="3" fill="#C9CED6"/>'
            f'<rect x="13" y="15" width="38" height="24" rx="1.5" fill="url(#{gs})"/>'
            '<path d="M4 46h56l-3 5a3 3 0 0 1-2.6 1.5H9.6A3 3 0 0 1 7 51z" fill="#AEB4BD"/>'
            '<rect x="26" y="46" width="12" height="2" rx="1" fill="#8E95A0"/>')


def server():
    g, d = lin([(0, '#5D6672'), (1, '#3B424C')])
    body = f'<defs>{d}</defs>'
    for y in (8, 25, 42):
        body += (f'<rect x="10" y="{y}" width="44" height="14" rx="3" fill="url(#{g})"/>'
                 f'<circle cx="17" cy="{y + 7}" r="2" fill="#3FC96B"/>'
                 f'<path d="M30 {y + 7}h18" stroke="#9AA3B3" stroke-width="2" stroke-linecap="round"/>')
    return body


def tint(glyph):
    """Glyphe in Akzentfarbe (folgt dem Farbschema über ColorScheme-Highlight)."""
    return _glyph(glyph)


ORTE.update({'laptop': laptop, 'server': server})


# ---------------------------------------------------------------------------
# Wetter (M4): farbige Wettersymbole wie im Widgets-Knopf und Widgets-Board von Windows 11
# (Sonne gelb-orange, Wolken weiß mit blaugrauer Schattierung, Regen blau, Blitz gelb).

WOLKE = 'M10 26A9 9 0 0 1 8.6 8.1 13 13 0 0 1 33 8.6 8.7 8.7 0 0 1 32 26z'   # Feld 0…41 × 0…26


def _sonne(cx, cy, r, strahlen=True):
    g, d = rad([(0, '#FFE88A'), (0.7, '#FFC72C'), (1, '#FFAA00')], 0.4, 0.35, 0.7)
    s = f'<defs>{d}</defs>'
    if strahlen:
        for k in range(8):
            import math
            a = k * math.pi / 4
            x1, y1 = cx + math.cos(a) * (r + 3.5), cy + math.sin(a) * (r + 3.5)
            x2, y2 = cx + math.cos(a) * (r + 7.5), cy + math.sin(a) * (r + 7.5)
            s += (f'<path d="M{x1:.2f} {y1:.2f}L{x2:.2f} {y2:.2f}" stroke="#FFB400" stroke-width="{max(2, r / 4):.1f}" '
                  'stroke-linecap="round"/>')
    s += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{g})"/>'
    return s


def _mond(cx, cy, r):
    g, d = lin([(0, '#FFE58A'), (1, '#F2B630')], 0, 0, 1, 1)
    # Sichel: Kreis minus versetzter Kreis
    return (f'<defs>{d}</defs><path d="M{cx + r * 0.25:.2f} {cy - r:.2f}A{r} {r} 0 1 0 {cx + r:.2f} {cy + r * 0.3:.2f}'
            f'A{r * 0.82:.2f} {r * 0.82:.2f} 0 0 1 {cx + r * 0.25:.2f} {cy - r:.2f}z" fill="url(#{g})"/>')


def _wolke(x, y, s, dunkel=False):
    if dunkel:
        g, d = lin([(0, '#B9C4D2'), (1, '#8794A6')])
        rand = '#7A8799'
    else:
        g, d = lin([(0, '#FFFFFF'), (0.55, '#F3F7FB'), (1, '#D3DEEB')])
        rand = '#B4C3D6'
    return (f'<defs>{d}</defs><g transform="translate({x} {y}) scale({s})">'
            f'<path d="{WOLKE}" fill="url(#{g})" stroke="{rand}" stroke-opacity=".55" stroke-width="{0.9 / s:.2f}"/></g>')


def _tropfen(punkte):
    g, d = lin([(0, '#55B4F5'), (1, '#1C7BD3')])
    s = f'<defs>{d}</defs>'
    for (x, y) in punkte:
        s += f'<path d="M{x} {y}l-2.6 7" stroke="url(#{g})" stroke-width="3.2" stroke-linecap="round"/>'
    return s


def _flocken(punkte):
    s = ''
    for (x, y) in punkte:
        s += f'<circle cx="{x}" cy="{y}" r="2.6" fill="#FFFFFF" stroke="#8CC8EE" stroke-width="1.3"/>'
    return s


def _blitz(x, y):
    g, d = lin([(0, '#FFE066'), (1, '#FFA200')])
    return f'<defs>{d}</defs><path d="M{x + 6} {y}h8l-5 9h6l-13 16 3-11h-6z" fill="url(#{g})" stroke="#E08A00" stroke-width=".8" stroke-linejoin="round"/>'


def _nebel(y0):
    s = ''
    for i, (x, w) in enumerate([(12, 40), (16, 34), (12, 36)]):
        s += f'<path d="M{x} {y0 + i * 6}h{w}" stroke="#9AA8BA" stroke-width="3.2" stroke-linecap="round"/>'
    return s


def wetter(art):
    """Wettersymbol (Feld 64). Arten: sonne, mond, sonne_wolke, mond_wolke, wolke, wolken,
    regen, sonne_regen, schnee, schneeregen, gewitter, hagel, nebel, wind, unbekannt."""
    if art == 'sonne':
        return _sonne(32, 32, 12)
    if art == 'mond':
        return _mond(30, 32, 18)
    if art == 'sonne_wolke':
        return _sonne(24, 24, 10) + _wolke(16, 27, 1.05)
    if art == 'mond_wolke':
        return _mond(24, 22, 12) + _wolke(16, 27, 1.05)
    if art == 'wolke':
        return _wolke(9, 19, 1.12)
    if art == 'wolken':
        return _wolke(18, 12, 0.9, dunkel=True) + _wolke(7, 24, 1.1)
    if art == 'regen':
        return _wolke(9, 10, 1.12) + _tropfen([(22, 44), (32, 44), (42, 44)])
    if art == 'sonne_regen':
        return _sonne(40, 18, 8) + _wolke(8, 16, 1.05) + _tropfen([(20, 48), (30, 48), (40, 48)])
    if art == 'schnee':
        return _wolke(9, 10, 1.12) + _flocken([(21, 46), (32, 50), (43, 46)])
    if art == 'schneeregen':
        return _wolke(9, 10, 1.12) + _tropfen([(22, 44), (42, 44)]) + _flocken([(32, 50)])
    if art == 'gewitter':
        return _wolke(9, 8, 1.12, dunkel=True) + _blitz(24, 32) + _tropfen([(18, 42), (46, 42)])
    if art == 'hagel':
        return (_wolke(9, 10, 1.12) +
                ''.join(f'<circle cx="{x}" cy="{y}" r="3" fill="#EEF4FA" stroke="#8D9CB0" stroke-width="1.2"/>'
                        for x, y in [(21, 45), (32, 50), (43, 45)]))
    if art == 'nebel':
        return _wolke(9, 8, 1.0) + _nebel(40)
    if art == 'wind':
        return ('<path d="M8 26h32a6 6 0 1 0-6-6" fill="none" stroke="#6E9FD0" stroke-width="3.6" stroke-linecap="round"/>'
                '<path d="M8 36h40a6 6 0 1 1-6 6" fill="none" stroke="#4F87C4" stroke-width="3.6" stroke-linecap="round"/>'
                '<path d="M8 46h18" fill="none" stroke="#8DB6DD" stroke-width="3.6" stroke-linecap="round"/>')
    if art == 'unbekannt':
        return _wolke(9, 19, 1.12, dunkel=True)
    raise ValueError(f'unbekanntes Wettermotiv {art!r}')
