/*
 * Fenstra-Fensterdekoration im Stil von Windows 11 (siehe fenstradecoration.h).
 *
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Fenstra-Projekt
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "fenstradecoration.h"
#include "fenstrabutton.h"

#include "fenstraboxshadowrenderer.h"

#include <KDecoration3/DecorationShadow>
#include <KDecoration3/ScaleHelpers>

#include <KPluginFactory>

#include <QPainter>
#include <QPainterPath>
#include <QTimer>

K_PLUGIN_FACTORY_WITH_JSON(FenstraDecoFactory, "fenstra.json", registerPlugin<Fenstra::Decoration>(); registerPlugin<Fenstra::Button>();)

namespace Fenstra
{
using KDecoration3::ColorGroup;
using KDecoration3::ColorRole;

namespace
{
//* Schatten wie Windows 11 (docs/windows11-referenz.md 1.5, Werte (u)):
//  aktiv groß und weich, inaktiv deutlich kleiner.
struct ShadowLayer {
    QPoint offset;
    int radius;
    qreal opacity;
};
struct ShadowSpec {
    ShadowLayer outer;
    ShadowLayer inner;
};
const ShadowSpec s_activeShadow{{QPoint(0, 12), 40, 0.30}, {QPoint(0, 2), 8, 0.14}};
const ShadowSpec s_inactiveShadow{{QPoint(0, 6), 20, 0.20}, {QPoint(0, 1), 4, 0.10}};
//* Überlappung des Schattens unter dem Fenster (gegen Lücken bei Skalierung)
constexpr int ShadowOverlap = 3;

std::shared_ptr<KDecoration3::DecorationShadow> g_shadowActive;
std::shared_ptr<KDecoration3::DecorationShadow> g_shadowInactive;
int g_decoCount = 0;

QColor withAlpha(QColor c, qreal alpha)
{
    c.setAlphaF(alpha);
    return c;
}
}

//________________________________________________________________
Decoration::Decoration(QObject *parent, const QVariantList &args)
    : KDecoration3::Decoration(parent, args)
{
    g_decoCount++;
}

Decoration::~Decoration()
{
    if (--g_decoCount == 0) {
        g_shadowActive.reset();
        g_shadowInactive.reset();
    }
}

//________________________________________________________________
bool Decoration::init()
{
    auto s = settings();
    connect(s.get(), &KDecoration3::DecorationSettings::reconfigured, this, &Decoration::reconfigure);
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsLeftChanged, this, &Decoration::updateButtonsGeometry);
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsRightChanged, this, &Decoration::updateButtonsGeometry);

    auto w = window();
    connect(w, &KDecoration3::DecoratedWindow::activeChanged, this, [this]() {
        updateShadow();
        recalculateBorders(); // Umrissfarbe aktiv/inaktiv
        update();
    });
    connect(w, &KDecoration3::DecoratedWindow::paletteChanged, this, &Decoration::reconfigure);
    connect(w, &KDecoration3::DecoratedWindow::captionChanged, this, [this]() {
        update(titleBar());
    });
    connect(w, &KDecoration3::DecoratedWindow::iconChanged, this, [this]() {
        update(titleBar());
    });
    connect(w, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::recalculateBorders);
    connect(w, &KDecoration3::DecoratedWindow::adjacentScreenEdgesChanged, this, &Decoration::recalculateBorders);
    connect(w, &KDecoration3::DecoratedWindow::shadedChanged, this, &Decoration::recalculateBorders);
    connect(w, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateButtonsGeometry);
    connect(w, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::updateButtonsGeometry);
    connect(w, &KDecoration3::DecoratedWindow::nextScaleChanged, this, &Decoration::recalculateBorders);
    connect(this, &KDecoration3::Decoration::bordersChanged, this, &Decoration::updateButtonsGeometry);

    updatePalette();
    createButtons();
    recalculateBorders();
    updateShadow();
    return true;
}

//________________________________________________________________
void Decoration::reconfigure()
{
    updatePalette();
    g_shadowActive.reset();
    g_shadowInactive.reset();
    recalculateBorders();
    updateButtonsGeometry();
    updateShadow();
    update();
}

//________________________________________________________________
void Decoration::updatePalette()
{
    // Grundfarbe der Titelleiste kommt aus dem Farbschema ([WM] activeBackground),
    // hell #F3F3F3 bzw. dunkel #202020 (Fenstra-Farbschemata).
    const QColor base = window()->color(ColorGroup::Active, ColorRole::TitleBar);
    const bool dark = base.lightnessF() < 0.5;
    Palette p;
    p.dark = dark;
    p.titleBar = base;
    p.closeHover = QColor(0xC4, 0x2B, 0x1C);
    p.closePressed = withAlpha(p.closeHover, 0.9);
    p.outline = withAlpha(QColor(0x75, 0x75, 0x75), 0.40); // SurfaceStrokeColorDefault
    p.outlineInactive = withAlpha(QColor(0x75, 0x75, 0x75), 0.28);
    if (dark) {
        p.text = Qt::white; // TextFillColorPrimary
        p.textInactive = withAlpha(Qt::white, 0x87 / 255.0); // Tertiary
        p.glyph = Qt::white;
        p.glyphInactive = withAlpha(Qt::white, 0x5D / 255.0); // Disabled
        p.hover = withAlpha(Qt::white, 0x0F / 255.0); // SubtleFillColorSecondary
        p.pressed = withAlpha(Qt::white, 0x0A / 255.0); // SubtleFillColorTertiary
    } else {
        p.text = withAlpha(Qt::black, 0xE4 / 255.0);
        p.textInactive = withAlpha(Qt::black, 0x72 / 255.0);
        p.glyph = withAlpha(Qt::black, 0xE4 / 255.0);
        p.glyphInactive = withAlpha(Qt::black, 0x5C / 255.0);
        p.hover = withAlpha(Qt::black, 0x09 / 255.0);
        p.pressed = withAlpha(Qt::black, 0x06 / 255.0);
    }
    m_palette = p;
}

//________________________________________________________________
qreal Decoration::radius() const
{
    // Windows 11: keine Rundung bei maximierten oder eingerasteten Fenstern
    if (isMaximized() || window()->adjacentScreenEdges() != Qt::Edges()) {
        return 0;
    }
    return KDecoration3::snapToPixelGrid(Metrics::CornerRadius, window()->nextScale());
}

//________________________________________________________________
void Decoration::recalculateBorders()
{
    const qreal scale = window()->nextScale();
    const qreal top = window()->isShaded() ? KDecoration3::snapToPixelGrid(Metrics::TitleBarHeight, scale)
                                           : KDecoration3::snapToPixelGrid(Metrics::TitleBarHeight, scale);
    setBorders(QMarginsF(0, top, 0, 0));

    // unsichtbarer Rand zum Größe ändern (außen, wie Windows)
    const qreal ext = isMaximized() ? 0 : KDecoration3::snapToPixelGrid(Metrics::ResizeBorder, scale);
    setResizeOnlyBorders(QMarginsF(isTiledEdge(Qt::LeftEdge) ? 0 : ext,
                                   isTiledEdge(Qt::TopEdge) ? 0 : ext / 2,
                                   isTiledEdge(Qt::RightEdge) ? 0 : ext,
                                   isTiledEdge(Qt::BottomEdge) ? 0 : ext));

    const qreal r = radius();
    setBorderRadius(KDecoration3::BorderRadius(r, r, r, r));

    if (isMaximized()) {
        setBorderOutline(KDecoration3::BorderOutline());
    } else {
        const qreal thickness = std::max(KDecoration3::pixelSize(scale), KDecoration3::snapToPixelGrid(1, scale));
        // KWin 6.7 mischt die Umrissfarbe als vormultiplizierte Farbe (gemessen: 40 % Grau
        // ergab reines Weiß). Deshalb RGB hier selbst mit Alpha multiplizieren.
        QColor color = window()->isActive() ? m_palette.outline : m_palette.outlineInactive;
        const qreal a = color.alphaF();
        color = QColor::fromRgbF(color.redF() * a, color.greenF() * a, color.blueF() * a, a);
        setBorderOutline(KDecoration3::BorderOutline(thickness, color, KDecoration3::BorderRadius(r, r, r, r)));
    }

    setOpaque(isMaximized());
    updateButtonsGeometry();
    update();
}

//________________________________________________________________
void Decoration::createButtons()
{
    m_leftButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Left, this, &Button::create);
    m_rightButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Right, this, &Button::create);
    updateButtonsGeometry();
}

//________________________________________________________________
void Decoration::updateButtonsGeometry()
{
    if (!m_leftButtons || !m_rightButtons) {
        return;
    }
    const qreal scale = window()->nextScale();
    const qreal h = KDecoration3::snapToPixelGrid(Metrics::ButtonHeight, scale);

    // rechts: Minimieren, Maximieren, Schließen – 46×32, ohne Abstand, bündig oben rechts
    for (auto *b : m_rightButtons->buttons()) {
        auto *btn = static_cast<Button *>(b);
        const qreal w = btn->type() == KDecoration3::DecorationButtonType::Menu ? h : KDecoration3::snapToPixelGrid(Metrics::ButtonWidth, scale);
        btn->setGeometry(QRectF(0, 0, w, h));
    }
    m_rightButtons->setSpacing(0);
    m_rightButtons->setPos(QPointF(size().width() - m_rightButtons->geometry().width(), 0));

    // links: Fenstersymbol (Fenstermenü wie unter Windows: Klick Menü, Doppelklick schließt)
    for (auto *b : m_leftButtons->buttons()) {
        auto *btn = static_cast<Button *>(b);
        const qreal w = btn->type() == KDecoration3::DecorationButtonType::Menu
            ? KDecoration3::snapToPixelGrid(Metrics::IconLeft * 2 + Metrics::IconSize - 4, scale)
            : KDecoration3::snapToPixelGrid(Metrics::ButtonWidth, scale);
        btn->setGeometry(QRectF(0, 0, w, h));
    }
    m_leftButtons->setSpacing(0);
    m_leftButtons->setPos(QPointF(KDecoration3::snapToPixelGrid(2, scale), 0));

    update();
}

//________________________________________________________________
QRectF Decoration::captionRect() const
{
    qreal left = Metrics::IconLeft;
    if (m_leftButtons && !m_leftButtons->buttons().isEmpty()) {
        // Titel neben dem Symbol: Symbol (16) + Abstand
        left = Metrics::IconLeft + Metrics::IconSize + Metrics::IconTextGap;
        left = std::max(left, m_leftButtons->geometry().right() + 2);
    }
    const qreal right = m_rightButtons ? m_rightButtons->geometry().left() - 8 : size().width() - 8;
    return QRectF(left, 0, std::max<qreal>(0, right - left), borderTop());
}

//________________________________________________________________
void Decoration::paint(QPainter *painter, const QRectF &repaintRegion)
{
    const qreal r = radius();
    const QRectF tb(0, 0, size().width(), borderTop());

    if (tb.intersects(repaintRegion)) {
        painter->save();
        painter->setRenderHint(QPainter::Antialiasing, r > 0);
        painter->setPen(Qt::NoPen);
        painter->setBrush(m_palette.titleBar);
        if (r > 0) {
            // oben gerundet, unten gerade (der Inhalt schließt direkt an)
            QPainterPath path;
            path.addRoundedRect(QRectF(tb.x(), tb.y(), tb.width(), tb.height() + r), r, r);
            painter->setClipRect(tb);
            painter->drawPath(path);
        } else {
            painter->drawRect(tb);
        }
        painter->restore();

        // Titeltext 12 px, links
        QFont f = settings()->font();
        f.setPixelSize(int(Metrics::TitleFontPx));
        f.setWeight(QFont::Normal);
        painter->save();
        painter->setFont(f);
        painter->setPen(window()->isActive() ? m_palette.text : m_palette.textInactive);
        const QRectF cr = captionRect();
        const QString caption = painter->fontMetrics().elidedText(window()->caption(), Qt::ElideRight, int(cr.width()));
        painter->drawText(cr, Qt::AlignVCenter | Qt::AlignLeft | Qt::TextSingleLine, caption);
        painter->restore();

        m_leftButtons->paint(painter, repaintRegion);
        m_rightButtons->paint(painter, repaintRegion);
    }
}

//________________________________________________________________
void Decoration::updateShadow()
{
    if (!g_shadowActive) {
        g_shadowActive = createShadow(true);
        g_shadowInactive = createShadow(false);
    }
    setShadow(window()->isActive() ? g_shadowActive : g_shadowInactive);
}

//________________________________________________________________
std::shared_ptr<KDecoration3::DecorationShadow> Decoration::createShadow(bool active) const
{
    const ShadowSpec spec = active ? s_activeShadow : s_inactiveShadow;
    const qreal cornerRadius = Metrics::CornerRadius;

    const QSize boxSize = BoxShadowRenderer::calculateMinimumBoxSize(spec.outer.radius)
                              .expandedTo(BoxShadowRenderer::calculateMinimumBoxSize(spec.inner.radius));

    BoxShadowRenderer renderer;
    renderer.setBorderRadius(cornerRadius + 0.5);
    renderer.setBoxSize(boxSize);
    // dunkle Designs: kräftigerer Schatten (Windows verdoppelt etwa die Deckkraft)
    const qreal k = m_palette.dark ? 1.6 : 1.0;
    renderer.addShadow(spec.outer.offset, spec.outer.radius, withAlpha(Qt::black, std::min(1.0, spec.outer.opacity * k)));
    renderer.addShadow(spec.inner.offset, spec.inner.radius, withAlpha(Qt::black, std::min(1.0, spec.inner.opacity * k)));

    QImage texture = renderer.render();
    QPainter painter(&texture);
    painter.setRenderHint(QPainter::Antialiasing);

    const QRectF outerRect = texture.rect();
    QRectF boxRect(QPoint(0, 0), boxSize);
    boxRect.moveCenter(outerRect.center());

    // Der Schatten liegt um das Fenster; den Bereich unter dem Fenster ausstanzen
    const QPoint offset = spec.outer.offset;
    const QMarginsF padding(boxRect.left() - outerRect.left() - ShadowOverlap - offset.x(),
                            boxRect.top() - outerRect.top() - ShadowOverlap - offset.y(),
                            outerRect.right() - boxRect.right() - ShadowOverlap + offset.x(),
                            outerRect.bottom() - boxRect.bottom() - ShadowOverlap + offset.y());
    QRectF innerRect = outerRect - padding;
    innerRect.adjust(2, 2, -2, -2);

    painter.setPen(Qt::NoPen);
    painter.setBrush(Qt::black);
    painter.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    painter.drawRoundedRect(innerRect, cornerRadius + 0.5, cornerRadius + 0.5);
    painter.end();

    auto shadow = std::make_shared<KDecoration3::DecorationShadow>();
    shadow->setPadding(padding);
    shadow->setInnerShadowRect(QRectF(outerRect.center(), QSizeF(1, 1)));
    shadow->setShadow(texture);
    return shadow;
}

} // namespace Fenstra

#include "fenstradecoration.moc"
