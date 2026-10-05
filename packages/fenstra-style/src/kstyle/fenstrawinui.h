/*
 * Fenstra: Farb- und Maßwerte der WinUI-3-Steuerelemente (Windows 11), abgeleitet aus der
 * aktuellen QPalette (hell/dunkel) und der Akzentfarbe. Quelle der Zahlen:
 * docs/windows11-referenz.md, Abschnitte 1 und 2 (WinUI-Themenressourcen).
 *
 * SPDX-FileCopyrightText: 2026 Fenstra-Projekt
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QColor>
#include <QPalette>
#include <QtMath>

namespace Fenstra
{
namespace WinUi
{
//* Maße (1.4, 2.x)
constexpr qreal ControlRadius = 4;
constexpr qreal OverlayRadius = 8;
constexpr int ControlHeight = 32;
constexpr int CheckBoxSize = 20;
constexpr int CheckGlyphSize = 12;
constexpr int MenuItemHeight = 32;
constexpr int MenuItemMargin = 4; // Abstand des Hover-Rechtecks zum Menürand
constexpr int ScrollBarWidth = 12; // ausgeklappt
constexpr int ScrollBarThinWidth = 2; // eingeklappt (u)
constexpr int ScrollBarThumbWidth = 6; // ausgeklappt
constexpr int SliderTrackHeight = 4;
constexpr int SliderThumbSize = 18;
constexpr int ProgressTrackHeight = 1;
constexpr int ProgressBarHeight = 3;
constexpr int SelectionPillWidth = 3;
constexpr int SelectionPillHeight = 16;

inline QColor alpha(QRgb rgb, int a)
{
    QColor c = QColor::fromRgb(rgb);
    c.setAlpha(a);
    return c;
}

inline bool isDark(const QPalette &p)
{
    return p.color(QPalette::Active, QPalette::Window).lightnessF() < 0.5;
}

//* Mischung von fg (mit Alpha) über bg -> deckende Farbe
inline QColor over(const QColor &fg, const QColor &bg)
{
    const qreal a = fg.alphaF();
    return QColor::fromRgbF(fg.redF() * a + bg.redF() * (1 - a), fg.greenF() * a + bg.greenF() * (1 - a), fg.blueF() * a + bg.blueF() * (1 - a), 1.0);
}

inline QColor mix(const QColor &a, const QColor &b, qreal t)
{
    t = qBound<qreal>(0, t, 1);
    return QColor::fromRgbF(a.redF() + (b.redF() - a.redF()) * t,
                            a.greenF() + (b.greenF() - a.greenF()) * t,
                            a.blueF() + (b.blueF() - a.blueF()) * t,
                            a.alphaF() + (b.alphaF() - a.alphaF()) * t);
}

// ---- Text (1.1)
inline QColor textPrimary(const QPalette &p)
{
    return isDark(p) ? QColor(0xFF, 0xFF, 0xFF) : alpha(0x000000, 0xE4);
}
inline QColor textSecondary(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0xC5) : alpha(0x000000, 0x9E);
}
inline QColor textTertiary(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x87) : alpha(0x000000, 0x72);
}
inline QColor textDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x5D) : alpha(0x000000, 0x5C);
}

// ---- Flächen von Steuerelementen
inline QColor controlFill(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x0F) : alpha(0xFFFFFF, 0xB3);
}
inline QColor controlFillHover(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x15) : alpha(0xF9F9F9, 0x80);
}
inline QColor controlFillPressed(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x08) : alpha(0xF9F9F9, 0x4D);
}
inline QColor controlFillDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x0B) : alpha(0xF9F9F9, 0x4D);
}
inline QColor controlFillInputActive(const QPalette &p)
{
    return isDark(p) ? alpha(0x1E1E1E, 0xB3) : QColor(0xFF, 0xFF, 0xFF);
}
inline QColor controlStrongFill(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x8B) : alpha(0x000000, 0x72);
}
inline QColor controlStrongFillDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x3F) : alpha(0x000000, 0x51);
}
inline QColor controlSolidFill(const QPalette &p)
{
    return isDark(p) ? QColor(0x45, 0x45, 0x45) : QColor(0xFF, 0xFF, 0xFF);
}
inline QColor subtleHover(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x0F) : alpha(0x000000, 0x09);
}
inline QColor subtlePressed(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x0A) : alpha(0x000000, 0x06);
}
inline QColor controlAltFill(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0x19) : alpha(0x000000, 0x06);
}
inline QColor controlAltFillHover(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x0B) : alpha(0x000000, 0x0F);
}
inline QColor controlAltFillPressed(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x12) : alpha(0x000000, 0x18);
}

// ---- Linien
inline QColor strokeDefault(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x12) : alpha(0x000000, 0x0F);
}
inline QColor strokeSecondary(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x18) : alpha(0x000000, 0x29);
}
inline QColor strongStroke(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x8B) : alpha(0x000000, 0x72);
}
inline QColor strongStrokeDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x28) : alpha(0x000000, 0x37);
}
inline QColor strokeOnAccent(const QPalette &)
{
    return alpha(0xFFFFFF, 0x14);
}
inline QColor strokeOnAccentSecondary(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0x23) : alpha(0x000000, 0x66);
}
inline QColor cardStroke(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0x19) : alpha(0x000000, 0x0F);
}
inline QColor surfaceStrokeFlyout(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0x33) : alpha(0x000000, 0x0F);
}
inline QColor divider(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x15) : alpha(0x000000, 0x0F);
}
inline QColor focusOuter(const QPalette &p)
{
    return isDark(p) ? QColor(0xFF, 0xFF, 0xFF) : alpha(0x000000, 0xE4);
}
inline QColor focusInner(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0xB3) : alpha(0xFFFFFF, 0xB3);
}

// ---- Hintergründe
inline QColor solidBase(const QPalette &p)
{
    return isDark(p) ? QColor(0x20, 0x20, 0x20) : QColor(0xF3, 0xF3, 0xF3);
}
//* Acrylic-Ersatzfarbe für Menüs/Flyouts (1.8), wenn keine Unschärfe dahinter liegt
inline QColor flyoutBackground(const QPalette &p)
{
    return isDark(p) ? QColor(0x2C, 0x2C, 0x2C) : QColor(0xF9, 0xF9, 0xF9);
}
inline QColor tooltipBackground(const QPalette &p)
{
    return isDark(p) ? QColor(0x2C, 0x2C, 0x2C) : QColor(0xF9, 0xF9, 0xF9);
}

// ---- Akzent (1.2)
inline QColor accentBase(const QPalette &p)
{
#if QT_VERSION >= QT_VERSION_CHECK(6, 6, 0)
    const QColor a = p.color(QPalette::Active, QPalette::Accent);
    if (a.isValid() && a.alpha() == 255) {
        return a;
    }
#endif
    return p.color(QPalette::Active, QPalette::Highlight);
}

//* Windows-Palette aus der Grundfarbe; für das Standardblau exakt, sonst über die Helligkeit genähert
inline QColor accentShade(const QColor &base, int step) // step: -3..+3 (Dark3..Light3)
{
    if (base.rgb() == qRgb(0x00, 0x78, 0xD4)) {
        switch (step) {
        case 3:
            return QColor(0x99, 0xEB, 0xFF);
        case 2:
            return QColor(0x4C, 0xC2, 0xFF);
        case 1:
            return QColor(0x00, 0x91, 0xF8);
        case -1:
            return QColor(0x00, 0x67, 0xC0);
        case -2:
            return QColor(0x00, 0x3E, 0x92);
        case -3:
            return QColor(0x00, 0x1A, 0x68);
        default:
            return base;
        }
    }
    float h, s, l, a;
    base.getHslF(&h, &s, &l, &a);
    switch (step) {
    case 3:
        l = l + (1 - l) * 0.66f;
        break;
    case 2:
        l = l + (1 - l) * 0.40f;
        break;
    case 1:
        l = l + (1 - l) * 0.12f;
        break;
    case -1:
        l = l * 0.906f;
        break;
    case -2:
        l = l * 0.688f;
        break;
    case -3:
        l = l * 0.49f;
        break;
    default:
        break;
    }
    return QColor::fromHslF(h, s, l, 1.0f);
}

//* Akzentfläche (Knöpfe, Häkchen, Schalter): hell Dark1, dunkel Light2
inline QColor accentFill(const QPalette &p)
{
    return accentShade(accentBase(p), isDark(p) ? 2 : -1);
}
inline QColor accentFillHover(const QPalette &p)
{
    QColor c = accentFill(p);
    c.setAlphaF(0.9);
    return c;
}
inline QColor accentFillPressed(const QPalette &p)
{
    QColor c = accentFill(p);
    c.setAlphaF(0.8);
    return c;
}
inline QColor accentFillDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x28) : alpha(0x000000, 0x37);
}
inline QColor textOnAccent(const QPalette &p)
{
    return isDark(p) ? QColor(0, 0, 0) : QColor(0xFF, 0xFF, 0xFF);
}
inline QColor textOnAccentSecondary(const QPalette &p)
{
    return isDark(p) ? alpha(0x000000, 0x80) : alpha(0xFFFFFF, 0xB3);
}
inline QColor textOnAccentDisabled(const QPalette &p)
{
    return isDark(p) ? alpha(0xFFFFFF, 0x87) : QColor(0xFF, 0xFF, 0xFF);
}
//* Links / Akzenttext
inline QColor accentText(const QPalette &p)
{
    return accentShade(accentBase(p), isDark(p) ? 3 : -2);
}

} // namespace WinUi
} // namespace Fenstra
