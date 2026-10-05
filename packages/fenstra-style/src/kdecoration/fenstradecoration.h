/*
 * Fenstra-Fensterdekoration im Stil von Windows 11.
 * Entstanden aus der Breeze-Dekoration (KDE), stark vereinfacht und umgebaut:
 * Titelleiste 32 px, rechteckige Knöpfe 46×32 px, Schließen rot, Ecken 8 px,
 * 1-px-Umriss, großer weicher Schatten.
 *
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Fenstra-Projekt
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <KDecoration3/DecoratedWindow>
#include <KDecoration3/Decoration>
#include <KDecoration3/DecorationButtonGroup>
#include <KDecoration3/DecorationSettings>

#include <QColor>
#include <QVariant>
#include <QVariantAnimation>

#include <memory>

namespace Fenstra
{
//* Maße in logischen Pixeln (100 % Skalierung), Quelle docs/windows11-referenz.md 3.x
namespace Metrics
{
static constexpr qreal TitleBarHeight = 32; // 3.1
static constexpr qreal ButtonWidth = 46; // 3.2
static constexpr qreal ButtonHeight = 32;
static constexpr qreal GlyphSize = 10;
static constexpr qreal CornerRadius = 8; // 1.4
static constexpr qreal IconSize = 16;
static constexpr qreal IconLeft = 10; // (u) Abstand Fensterkante -> Symbol
static constexpr qreal IconTextGap = 8; // (u) Symbol -> Titeltext
static constexpr qreal TitleFontPx = 12; // 3.1
static constexpr qreal ResizeBorder = 8; // unsichtbarer Rand zum Größe ändern
static constexpr int HoverDurationMs = 83; // 1.6 ControlFasterAnimationDuration
}

//* Farben je nach hellem/dunklem Fenster (aus WinUI-Tokens, 1.1)
struct Palette {
    QColor titleBar;
    QColor text; // aktiv
    QColor textInactive;
    QColor glyph;
    QColor glyphInactive;
    QColor hover; // Minimieren/Maximieren
    QColor pressed;
    QColor closeHover; // #C42B1C
    QColor closePressed;
    QColor outline;
    QColor outlineInactive;
    bool dark = false;
};

class Button;

class Decoration : public KDecoration3::Decoration
{
    Q_OBJECT

public:
    explicit Decoration(QObject *parent = nullptr, const QVariantList &args = QVariantList());
    ~Decoration() override;

    bool init() override;
    void paint(QPainter *painter, const QRectF &repaintRegion) override;

    const Palette &colors() const
    {
        return m_palette;
    }

    bool isMaximized() const
    {
        return window()->isMaximized();
    }
    //* Fenster an einer Bildschirmkante (maximiert oder eingerastet): keine Rundung dort
    bool isTiledEdge(Qt::Edge edge) const
    {
        return window()->adjacentScreenEdges().testFlag(edge);
    }

private Q_SLOTS:
    void reconfigure();
    void recalculateBorders();
    void updateButtonsGeometry();
    void updateShadow();

private:
    void createButtons();
    void updatePalette();
    QRectF captionRect() const;
    qreal radius() const;
    std::shared_ptr<KDecoration3::DecorationShadow> createShadow(bool active) const;

    Palette m_palette;
    KDecoration3::DecorationButtonGroup *m_rightButtons = nullptr;
    KDecoration3::DecorationButtonGroup *m_leftButtons = nullptr;
};

} // namespace Fenstra
