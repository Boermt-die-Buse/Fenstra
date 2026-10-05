/*
 * Titelleistenknöpfe im Stil von Windows 11: 46×32 px, rechteckig, ohne Abstand,
 * Glyphen 10×10 px mit 1-px-Strich, Schließen-Hover #C42B1C.
 *
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2026 Fenstra-Projekt
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "fenstradecoration.h"

#include <KDecoration3/DecorationButton>

class QVariantAnimation;

namespace Fenstra
{
class Button : public KDecoration3::DecorationButton
{
    Q_OBJECT

public:
    //* für KPluginFactory (nicht direkt benutzt)
    explicit Button(QObject *parent, const QVariantList &args);
    ~Button() override = default;

    static Button *create(KDecoration3::DecorationButtonType type, KDecoration3::Decoration *decoration, QObject *parent);

    void paint(QPainter *painter, const QRectF &repaintRegion) override;

private:
    explicit Button(KDecoration3::DecorationButtonType type, Decoration *decoration, QObject *parent = nullptr);

    Decoration *deco() const;
    void drawGlyph(QPainter *painter, const QRectF &box, const QColor &color) const;

    //* Hover-Überblendung 0..1 (83 ms)
    QVariantAnimation *m_hoverAnimation = nullptr;
    qreal m_hover = 0;
};

} // namespace Fenstra
