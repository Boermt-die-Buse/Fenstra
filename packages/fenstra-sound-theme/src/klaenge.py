#!/usr/bin/env python3
"""Fenstra-Klangschema: alle Ereignisklänge synthetisiert (keine Aufnahmen, keine fremden Dateien).

Klangcharakter wie Windows 11 (docs/windows11-referenz.md 6.7): weiche, glasige
Glocken-/Marimbatöne mit leichtem Raumhall; Anmelden als aufsteigender Akkord,
Fehler als tiefer Doppelton, Papierkorb als Rascheln, Abmelden still.

Aufruf: klaenge.py --out <themenverzeichnis> [--wav]   (Standard: Ogg Vorbis .oga über oggenc)
Benennung nach der freedesktop Sound Naming Specification (dieselben Namen wie Plasma/Ocean).
"""
import argparse
import os
import shutil
import subprocess
import sys
import wave

import numpy as np

RATE = 48000
SPITZE_DB = -1.5        # Spitzenpegel
ZIEL_RMS_DB = -21.0     # einheitliche Lautheit der Ereignisklänge (außer Anmelden/Stille)

rng = np.random.default_rng(4711)   # fest, damit jeder Bau dieselben Klänge erzeugt


def t_achse(dauer):
    return np.arange(int(dauer * RATE)) / RATE


def huelle(n, attack=0.004, decay=0.35, dauer=None):
    t = np.arange(n) / RATE
    a = np.clip(t / max(attack, 1e-4), 0, 1)
    return a * np.exp(-t / decay)


def note(freq, dauer=0.8, art='glocke', laut=1.0, decay=None):
    """Einzelton mit Obertönen. art: glocke (glasig), marimba (holzig, kurz), sinus, pad (weich)"""
    t = t_achse(dauer)
    n = len(t)
    if art == 'glocke':
        partials = [(1.0, 1.0, 1.0), (2.0, 0.35, 0.6), (3.01, 0.12, 0.4), (4.17, 0.08, 0.25), (5.43, 0.04, 0.18)]
        d0 = decay or 0.45
        att = 0.003
    elif art == 'marimba':
        partials = [(1.0, 1.0, 1.0), (3.93, 0.25, 0.18), (9.2, 0.06, 0.06)]
        d0 = decay or 0.28
        att = 0.002
    elif art == 'pad':
        partials = [(1.0, 1.0, 1.0), (2.0, 0.18, 1.0), (3.0, 0.05, 1.0)]
        d0 = decay or 1.4
        att = 0.35
    else:
        partials = [(1.0, 1.0, 1.0)]
        d0 = decay or 0.3
        att = 0.004
    sig = np.zeros(n)
    for ratio, amp, dk in partials:
        f = freq * ratio
        if f > RATE / 2.2:
            continue
        sig += amp * np.sin(2 * np.pi * f * t + rng.uniform(0, 0.3)) * huelle(n, att, d0 * dk)
    return laut * sig


def stille(dauer):
    return np.zeros(int(dauer * RATE))


def misch(*teile):
    """teile: (startzeit, signal)"""
    ende = max(int(s * RATE) + len(x) for s, x in teile)
    out = np.zeros(ende)
    for s, x in teile:
        i = int(s * RATE)
        out[i:i + len(x)] += x
    return out


def rauschen(dauer, lo=1500, hi=7000):
    n = int(dauer * RATE)
    x = rng.standard_normal(n)
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / RATE)
    spec[(f < lo) | (f > hi)] = 0
    return np.fft.irfft(spec, n)


def hall(mono, laenge=0.9, anteil=0.22):
    """Raumhall: Faltung mit exponentiell abklingendem, gefiltertem Rauschen; je Kanal eigenes Rauschen."""
    n = int(laenge * RATE)
    t = np.arange(n) / RATE
    out = []
    for _ in range(2):
        ir = rng.standard_normal(n) * np.exp(-t / (laenge / 5))
        ir = np.convolve(ir, np.ones(6) / 6, mode='same')   # Höhen dämpfen
        ir[:int(0.012 * RATE)] *= np.linspace(0, 1, int(0.012 * RATE))
        ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
        m = len(mono) + n
        nfft = 1 << (m - 1).bit_length()
        wet = np.fft.irfft(np.fft.rfft(mono, nfft) * np.fft.rfft(ir, nfft), nfft)[:m]
        dry = np.concatenate([mono, np.zeros(n)])
        out.append(dry + anteil * wet)
    return np.stack(out, axis=1)


def fertig(stereo, rms_db=ZIEL_RMS_DB, ausklang=0.02):
    x = stereo.copy()
    # Ende abschneiden, sobald es leise ist (Schwelle −55 dB unter der Spitze), dann weich ausblenden
    pegel = np.max(np.abs(x), axis=1)
    if pegel.max() > 0:
        laut = np.where(pegel > pegel.max() * 10 ** (-55 / 20))[0]
        if len(laut):
            x = x[:laut[-1] + 1]
    fe = int(0.005 * RATE)
    fa = int(max(ausklang, 0.005) * RATE)
    if len(x) > fe + fa:
        x[:fe] *= np.linspace(0, 1, fe)[:, None]
        x[-fa:] *= np.linspace(1, 0, fa)[:, None]
    if rms_db is not None and np.any(x):
        # Lautheit: RMS über den lauten Teil (oberhalb −40 dB der Spitze)
        e = np.sqrt(np.mean(x ** 2, axis=1))
        aktiv = e > e.max() * 0.01
        rms = np.sqrt(np.mean(x[aktiv] ** 2))
        x *= 10 ** (rms_db / 20) / rms
    peak = np.max(np.abs(x)) if np.any(x) else 1
    grenze = 10 ** (SPITZE_DB / 20)
    if peak > grenze:
        x *= grenze / peak
    return x


# ---------------------------------------------------------------------------
# Töne (Frequenzen gleichstufig, A4 = 440 Hz)

def hz(name):
    noten = {'C': -9, 'C#': -8, 'D': -7, 'D#': -6, 'Eb': -6, 'E': -5, 'F': -4, 'F#': -3, 'G': -2, 'G#': -1,
             'Ab': -1, 'A': 0, 'A#': 1, 'Bb': 1, 'B': 2}
    n, o = name[:-1], int(name[-1])
    return 440.0 * 2 ** ((noten[n] + 12 * (o - 4)) / 12)


def folge(noten, abstand, art='glocke', dauer=0.7, laut=None, decay=None):
    teile = []
    for i, nm in enumerate(noten):
        teile.append((i * abstand, note(hz(nm), dauer, art, (laut or [1.0] * len(noten))[i], decay)))
    return misch(*teile)


def klang_anmelden():
    # weicher Akkord (Pad) + aufsteigendes Glocken-Arpeggio, ca. 2,8 s
    pad = misch((0.0, note(hz('C4'), 2.6, 'pad', 0.35)), (0.0, note(hz('G4'), 2.6, 'pad', 0.25)),
                (0.15, note(hz('E5'), 2.4, 'pad', 0.18)), (0.3, note(hz('B4'), 2.3, 'pad', 0.12)))
    arp = folge(['G5', 'C6', 'D6', 'G6', 'B6'], 0.13, 'glocke', 1.6, [0.55, 0.6, 0.55, 0.5, 0.35], 0.7)
    return fertig(hall(misch((0.0, pad), (0.35, arp)), 1.6, 0.35), rms_db=-19, ausklang=0.4)


def klang_anmelden_kurz():
    arp = folge(['C6', 'G6'], 0.12, 'glocke', 1.0, [0.7, 0.6], 0.5)
    return fertig(hall(misch((0.0, note(hz('C5'), 1.0, 'pad', 0.3)), (0.05, arp)), 1.0, 0.3), ausklang=0.2)


def klang_benachrichtigung():
    return fertig(hall(folge(['A5', 'E6'], 0.09, 'marimba', 0.45, [0.8, 1.0], 0.25), 0.7, 0.25))


def klang_hinweis():
    return fertig(hall(note(hz('E6'), 0.8, 'glocke', 1.0, 0.35), 0.8, 0.25))


def klang_frage():
    return fertig(hall(folge(['C6', 'E6'], 0.11, 'glocke', 0.7, [0.7, 1.0], 0.3), 0.8, 0.25))


def klang_achtung():
    return fertig(hall(misch((0, note(hz('A5'), 0.6, 'glocke', 1.0, 0.25)), (0.0, note(hz('A4'), 0.6, 'marimba', 0.4))), 0.7, 0.22))


def klang_fehler(tief=0):
    a, b = ['D5', 'A4'] if not tief else ['C5', 'G4']
    return fertig(hall(folge([a, b], 0.13, 'marimba', 0.45, [1.0, 1.0], 0.22), 0.6, 0.2))


def klang_auth():
    return fertig(hall(folge(['E5', 'B5'], 0.12, 'glocke', 0.7, [0.8, 1.0], 0.3), 0.8, 0.25))


def klang_geraet(auf=True, noten=('G5', 'D6')):
    seq = list(noten) if auf else list(reversed(noten))
    return fertig(hall(folge(seq, 0.12, 'marimba', 0.35, [0.9, 1.0], 0.2), 0.6, 0.22))


def klang_ding():
    return fertig(hall(note(hz('E6'), 0.35, 'glocke', 1.0, 0.16), 0.5, 0.18))


def klang_papierkorb():
    # Rascheln: kurze, zufällige Knister-Bündel aus gefiltertem Rauschen über ~1 s
    dauer = 1.0
    n = int(dauer * RATE)
    sig = np.zeros(n)
    t = 0.0
    while t < dauer - 0.06:
        laenge = rng.uniform(0.015, 0.06)
        b = rauschen(laenge, rng.uniform(1200, 2500), rng.uniform(5000, 9000))
        b *= np.hanning(len(b)) * rng.uniform(0.3, 1.0) * (1 - 0.6 * t / dauer)
        i = int(t * RATE)
        sig[i:i + len(b)] += b[:max(0, n - i)]
        t += rng.uniform(0.008, 0.045)
    return fertig(hall(sig, 0.4, 0.12))


def klang_akku(anzahl, note_name='F5'):
    return fertig(hall(folge([note_name] * anzahl, 0.22, 'glocke', 0.5, [1.0] * anzahl, 0.18), 0.6, 0.2))


def klang_akku_voll():
    return fertig(hall(folge(['C6', 'E6', 'G6'], 0.1, 'glocke', 0.7, [0.8, 0.9, 1.0], 0.3), 0.8, 0.25))


def klang_wecker():
    figur = ['E6', 'G6', 'C7']
    teile = []
    for r in range(3):
        for i, nm in enumerate(figur):
            teile.append((r * 0.8 + i * 0.12, note(hz(nm), 0.6, 'glocke', 0.9, 0.25)))
    return fertig(hall(misch(*teile), 0.9, 0.25))


def klang_erfolg():
    return fertig(hall(folge(['E6', 'A6'], 0.1, 'glocke', 0.7, [0.8, 1.0], 0.3), 0.8, 0.25))


def klang_misserfolg():
    return fertig(hall(folge(['A4', 'F4'], 0.14, 'marimba', 0.5, [1.0, 1.0], 0.25), 0.6, 0.2))


def klang_teilweise():
    return fertig(hall(note(hz('A5'), 0.5, 'marimba', 1.0, 0.2), 0.6, 0.2))


def klang_tick(laenge=0.03):
    b = rauschen(laenge, 2000, 8000) * np.hanning(int(laenge * RATE))
    b = misch((0, b), (0, note(hz('A6'), laenge * 2, 'sinus', 0.3, laenge / 2)))
    return fertig(hall(b, 0.15, 0.05))


def klang_ausloeser():
    # Kamera: zwei kurze Klicks mit tiefem Anteil
    k1 = rauschen(0.025, 800, 6000) * np.hanning(int(0.025 * RATE))
    k2 = rauschen(0.04, 500, 4000) * np.hanning(int(0.04 * RATE))
    tief = note(110, 0.08, 'sinus', 0.8, 0.02)
    return fertig(hall(misch((0, k1), (0, tief), (0.07, k2)), 0.25, 0.08))


def klang_mail():
    return fertig(hall(folge(['C6', 'E6', 'G6'], 0.07, 'marimba', 0.45, [0.8, 0.9, 1.0], 0.22), 0.7, 0.25))


def klang_kontakt(rein=True):
    return klang_geraet(rein, ('E6', 'B6'))


def klang_gesendet():
    s = rauschen(0.25, 800, 5000)
    s *= np.sin(np.linspace(0, np.pi, len(s))) ** 2
    return fertig(hall(s, 0.3, 0.1))


def klang_anruf():
    teile = []
    for r in range(2):
        for i, nm in enumerate(['E6', 'C6', 'E6', 'C6']):
            teile.append((r * 1.0 + i * 0.09, note(hz(nm), 0.3, 'marimba', 0.9, 0.12)))
    return fertig(hall(misch(*teile), 0.6, 0.2))


def klang_spiel(gewonnen=True):
    seq = ['C6', 'E6', 'G6', 'C7'] if gewonnen else ['G5', 'E5', 'C5', 'G4']
    return fertig(hall(folge(seq, 0.12, 'glocke' if gewonnen else 'marimba', 0.7, [0.8, 0.85, 0.9, 1.0], 0.3), 0.8, 0.25))


def klang_stille():
    return np.zeros((int(0.05 * RATE), 2))


KLAENGE = {
    'desktop-login': klang_anmelden, 'theme-demo': klang_anmelden,
    'service-login': klang_anmelden_kurz, 'system-ready': klang_anmelden_kurz,
    'desktop-logout': klang_stille, 'service-logout': klang_stille,
    'message-new-instant': klang_benachrichtigung, 'message-attention': klang_benachrichtigung,
    'message-highlight': klang_benachrichtigung, 'window-attention': klang_benachrichtigung,
    'message': klang_benachrichtigung,
    'dialog-information': klang_hinweis, 'dialog-question': klang_frage, 'media-insert-request': klang_frage,
    'dialog-warning': klang_achtung, 'dialog-warning-auth': klang_auth,
    'dialog-error': klang_fehler, 'dialog-error-serious': lambda: klang_fehler(1),
    'dialog-error-critical': lambda: klang_fehler(1),
    'device-added': lambda: klang_geraet(True), 'device-removed': lambda: klang_geraet(False),
    'power-plug': lambda: klang_geraet(True, ('C6', 'G6')), 'power-unplug': lambda: klang_geraet(False, ('C6', 'G6')),
    'network-connectivity-established': lambda: klang_geraet(True, ('E6', 'A6')),
    'network-connectivity-lost': lambda: klang_geraet(False, ('E6', 'A6')),
    'audio-volume-change': klang_ding, 'bell': klang_ding, 'bell-window-system': klang_ding, 'bell-terminal': klang_ding,
    'trash-empty': klang_papierkorb,
    'battery-low': lambda: klang_akku(2), 'battery-caution': lambda: klang_akku(3, 'D5'), 'battery-full': klang_akku_voll,
    'alarm-clock-elapsed': klang_wecker,
    'completion-success': klang_erfolg, 'outcome-success': klang_erfolg, 'complete-media-burn': klang_erfolg,
    'complete-download': klang_erfolg, 'complete-copy': klang_erfolg,
    'completion-fail': klang_misserfolg, 'outcome-failure': klang_misserfolg, 'complete-media-error': klang_misserfolg,
    'completion-partial': klang_teilweise, 'completion-rotation': lambda: klang_tick(0.02),
    'button-pressed': klang_tick, 'button-pressed-modifier': lambda: klang_tick(0.02), 'item-selected': klang_tick,
    'camera-shutter': klang_ausloeser, 'screen-capture': klang_ausloeser,
    'message-new-email': klang_mail, 'message-contact-in': lambda: klang_kontakt(True),
    'message-contact-out': lambda: klang_kontakt(False), 'message-sent-instant': klang_gesendet,
    'message-sent-email': klang_gesendet,
    'phone-incoming-call': klang_anruf, 'phone-outgoing-calling': klang_anruf,
    'game-over-winner': lambda: klang_spiel(True), 'game-over-loser': lambda: klang_spiel(False),
}


def schreibe_wav(pfad, stereo):
    daten = (np.clip(stereo, -1, 1) * 32767).astype('<i2')
    with wave.open(pfad, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(daten.tobytes())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--wav', action='store_true', help='WAV statt Ogg Vorbis schreiben')
    ap.add_argument('--bericht', action='store_true', help='Länge, Spitze und RMS je Klang ausgeben')
    a = ap.parse_args()
    if not a.wav and not shutil.which('oggenc'):
        sys.exit('oggenc fehlt (vorbis-tools) – oder --wav verwenden')
    sdir = os.path.join(a.out, 'stereo')
    if os.path.exists(a.out):
        shutil.rmtree(a.out)
    os.makedirs(sdir)
    cache = {}
    for name, fn in KLAENGE.items():
        key = fn.__name__ if fn.__name__ != '<lambda>' else name
        if key not in cache:
            cache[key] = fn()
        x = cache[key]
        wav = os.path.join(sdir, name + '.wav')
        schreibe_wav(wav, x)
        if not a.wav:
            subprocess.run(['oggenc', '-Q', '-q', '5', '-o', os.path.join(sdir, name + '.oga'), wav], check=True)
            os.remove(wav)
        if a.bericht:
            peak = 20 * np.log10(np.max(np.abs(x)) + 1e-12)
            rms = 20 * np.log10(np.sqrt(np.mean(x ** 2)) + 1e-12)
            print(f'{name:36s} {len(x) / RATE:5.2f} s  Spitze {peak:6.1f} dBFS  RMS {rms:6.1f} dBFS')
    with open(os.path.join(a.out, 'index.theme'), 'w', encoding='utf-8') as fh:
        fh.write('[Sound Theme]\nName=Fenstra\nName[de]=Fenstra\n'
                 'Comment=Fenstra event sounds, synthesized\nComment[de]=Fenstra-Ereignisklänge, synthetisiert\n'
                 'Directories=stereo\n\n[stereo]\nOutputProfile=stereo\n')
    print(len(KLAENGE), 'Klänge')


if __name__ == '__main__':
    main()
