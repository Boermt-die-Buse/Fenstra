/*
 * Titelleistenknöpfe im Stil von Windows 11 (siehe fenstrabutton.h).
 *
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Fenstra-Projekt
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "fenstrabutton.h"

#include <KDecoration3/DecoratedWindow>
#include <KDecoration3/ScaleHelpers>

#include <QPainter>
#include <QPainterPath>
#include <QVariantAnimation>

namespace Fenstra
{
using KDecoration3::DecorationButtonType;

namespace
{
QColor mixAlpha(const QColor &c, qreal factor)
{
    QColor r(c);
    r.setAlphaF(c.alphaF() * factor);
    return r;
}
}

//________________________________________________________________
Button::Button(DecorationButtonType type, Decoration *decoration, QObject *parent)
    : DecorationButton(type, decoration, parent)
    , m_hoverAnimation(new QVariantAnimation(this))
{
    m_hoverAnimation->setStartValue(0.0);
    m_hoverAnimation->setEndValue(1.0);
    m_hoverAnimation->setDuration(Metrics::HoverDurationMs);
    m_hoverAnimation->setEasingCurve(QEasingCurve::Linear);
    connect(m_hoverAnimation, &QVariantAnimation::valueChanged, this, [this](const QVariant &v) {
        m_hover = v.toReal();
        update();
    });

    connect(this, &DecorationButton::hoveredChanged, this, [this](bool hovered) {
        m_hoverAnimation->setDirection(hovered ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        if (m_hoverAnimation->state() != QAbstractAnimation::Running) {
            m_hoverAnimation->start();
        }
        if (!hovered) {
            return;
        }
        // Tooltips wie im deutschen Windows 11. KDecoration hat in seinem eigenen
        // hoveredChanged-Slot (vor diesem) schon seinen Text angefordert; der folgende
        // Aufruf ersetzt ihn ("Wiederherstellen" -> "Verkleinern", Fenstersymbol ohne Tooltip).
        QString text;
        switch (this->type()) {
        case DecorationButtonType::Minimize:
            text = QStringLiteral("Minimieren");
            break;
        case DecorationButtonType::Maximize:
            text = isChecked() ? QStringLiteral("Verkleinern") : QStringLiteral("Maximieren");
            break;
        case DecorationButtonType::Close:
            text = QStringLiteral("Schließen");
            break;
        default:
            break;
        }
        if (text.isEmpty()) {
            this->decoration()->requestHideToolTip();
        } else {
            this->decoration()->requestShowToolTip(text);
        }
    });

    // Fenster aktiv/inaktiv oder Maximieren ändern die Darstellung
    connect(decoration->window(), &KDecoration3::DecoratedWindow::activeChanged, this, [this]() {
        update();
    });
    if (type == DecorationButtonType::Menu) {
        connect(decoration->window(), &KDecoration3::DecoratedWindow::iconChanged, this, [this]() {
            update();
        });
    }
}

//________________________________________________________________
Button::Button(QObject *parent, const QVariantList &args)
    : Button(args.at(0).value<DecorationButtonType>(), args.at(1).value<Decoration *>(), parent)
{
}

//________________________________________________________________
Button *Button::create(DecorationButtonType type, KDecoration3::Decoration *decoration, QObject *parent)
{
    auto *d = qobject_cast<Decoration *>(decoration);
    if (!d) {
        return nullptr;
    }
    switch (type) {
    case DecorationButtonType::Minimize:
    case DecorationButtonType::Maximize:
    case DecorationButtonType::Close:
    case DecorationButtonType::Menu: {
        auto *b = new Button(type, d, parent);
        if (type == DecorationButtonType::Minimize) {
            b->setVisible(d->window()->isMinimizeable());
            connect(d->window(), &KDecoration3::DecoratedWindow::minimizeableChanged, b, &Button::setVisible);
        } else if (type == DecorationButtonType::Maximize) {
            b->setVisible(d->window()->isMaximizeable());
            connect(d->window(), &KDecoration3::DecoratedWindow::maximizeableChanged, b, &Button::setVisible);
        }
        return b;
    }
    default:
        // Windows hat keine weiteren Titelleistenknöpfe (Hilfe, Rollen, Alle Desktops …)
        return nullptr;
    }
}

//________________________________________________________________
Decoration *Button::deco() const
{
    return static_cast<Decoration *>(decoration());
}

//________________________________________________________________
void Button::paint(QPainter *painter, const QRectF &repaintRegion)
{
    Q_UNUSED(repaintRegion)
    if (!isVisible()) {
        return;
    }
    const Palette &pal = deco()->colors();
    const QRectF box = geometry();
    const bool active = deco()->window()->isActive();

    // Fenstersymbol (16 px) statt Glyphe
    if (type() == DecorationButtonType::Menu) {
        const qreal s = Metrics::IconSize;
        const QRectF iconRect(box.left() + Metrics::IconLeft - 2, box.center().y() - s / 2, s, s);
        deco()->window()->icon().paint(painter, iconRect.toAlignedRect());
        return;
    }

    // Hintergrund
    QColor bg;
    QColor glyph = active ? pal.glyph : pal.glyphInactive;
    if (type() == DecorationButtonType::Close) {
        if (isPressed()) {
            bg = pal.closePressed;
            glyph = QColor(255, 255, 255, 178); // ~70 % Weiß
        } else if (m_hover > 0) {
            bg = mixAlpha(pal.closeHover, m_hover);
            // Glyphe blendet zu Weiß über
            const QColor from = glyph;
            glyph = QColor::fromRgbF(from.redF() + (1.0 - from.redF()) * m_hover,
                                     from.greenF() + (1.0 - from.greenF()) * m_hover,
                                     from.blueF() + (1.0 - from.blueF()) * m_hover,
                                     from.alphaF() + (1.0 - from.alphaF()) * m_hover);
        }
    } else {
        if (isPressed()) {
            bg = pal.pressed;
        } else if (m_hover > 0) {
            bg = mixAlpha(pal.hover, m_hover);
        }
        if (isHovered() && !active) {
            // Windows zeigt beim Hover auch im inaktiven Fenster die volle Glyphe
            glyph = pal.glyph;
        }
    }

    if (bg.isValid() && bg.alpha() > 0) {
        painter->save();
        painter->setPen(Qt::NoPen);
        painter->setBrush(bg);
        // Schließen-Knopf folgt oben rechts der Fensterrundung
        const qreal r = deco()->isMaximized() || deco()->window()->adjacentScreenEdges() != Qt::Edges() ? 0 : Metrics::CornerRadius;
        if (type() == DecorationButtonType::Close && r > 0) {
            painter->setRenderHint(QPainter::Antialiasing, true);
            QPainterPath path;
            path.moveTo(box.left(), box.top());
            path.lineTo(box.right() - r, box.top());
            path.arcTo(QRectF(box.right() - 2 * r, box.top(), 2 * r, 2 * r), 90, -90);
            path.lineTo(box.right(), box.bottom());
            path.lineTo(box.left(), box.bottom());
            path.closeSubpath();
            painter->drawPath(path);
        } else {
            painter->drawRect(box);
        }
        painter->restore();
    }

    drawGlyph(painter, box, glyph);
}

//________________________________________________________________
void Button::drawGlyph(QPainter *painter, const QRectF &box, const QColor &color) const
{
    const qreal scale = deco()->window()->scale();
    const qreal px = KDecoration3::pixelSize(scale);
    const qreal g = KDecoration3::snapToPixelGrid(Metrics::GlyphSize, scale);
    // Glyphe mittig, auf Pixelraster
    const qreal x0 = KDecoration3::snapToPixelGrid(box.left() + (box.width() - g) / 2, scale);
    const qreal y0 = KDecoration3::snapToPixelGrid(box.top() + (box.height() - g) / 2, scale);

    painter->save();
    QPen pen(color, px);
    pen.setCapStyle(Qt::FlatCap);
    pen.setJoinStyle(Qt::MiterJoin);
    painter->setPen(pen);
    painter->setBrush(Qt::NoBrush);

    switch (type()) {
    case DecorationButtonType::Minimize:
        // waagrechte Linie, 10 px, mittig
        painter->setRenderHint(QPainter::Antialiasing, false);
        painter->fillRect(QRectF(x0, y0 + KDecoration3::snapToPixelGrid(g / 2, scale), g, px), color);
        break;
    case DecorationButtonType::Maximize:
        painter->setRenderHint(QPainter::Antialiasing, true);
        if (isChecked()) {
            // Verkleinern: vorderes Quadrat 8×8 unten links, hinteres nur oben/rechts sichtbar
            const qreal s = g - 2 * px;
            const qreal o = 2 * px;
            painter->drawRoundedRect(QRectF(x0 + px / 2, y0 + o + px / 2, s - px, s - px), 1, 1);
            QPainterPath back;
            back.moveTo(x0 + o + px / 2, y0 + o);
            back.lineTo(x0 + o + px / 2, y0 + px / 2 + 1);
            back.quadTo(x0 + o + px / 2, y0 + px / 2, x0 + o + px / 2 + 1, y0 + px / 2);
            back.lineTo(x0 + g - px / 2 - 1, y0 + px / 2);
            back.quadTo(x0 + g - px / 2, y0 + px / 2, x0 + g - px / 2, y0 + px / 2 + 1);
            back.lineTo(x0 + g - px / 2, y0 + g - o - px / 2);
            back.lineTo(x0 + g - o, y0 + g - o - px / 2);
            painter->drawPath(back);
        } else {
            // Quadrat 10×10, Ecken leicht gerundet
            painter->drawRoundedRect(QRectF(x0 + px / 2, y0 + px / 2, g - px, g - px), 1, 1);
        }
        break;
    case DecorationButtonType::Close:
        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->drawLine(QPointF(x0, y0), QPointF(x0 + g, y0 + g));
        painter->drawLine(QPointF(x0 + g, y0), QPointF(x0, y0 + g));
        break;
    default:
        break;
    }
    painter->restore();
}

} // namespace Fenstra
