//////////////////////////////////////////////////////////////////////////////
// fenstraanimationconfigitem.h
// animation configuration item
// -------------------
//
// SPDX-FileCopyrightText: 2010 Hugo Pereira Da Costa <hugo.pereira@free.fr>
//
// SPDX-License-Identifier: MIT
//////////////////////////////////////////////////////////////////////////////

#include <QAbstractScrollArea>
#include <QApplication>
#include <QIcon>

#include <KCMultiDialog>
#include <KLocalizedString>
#include <KPluginMetaData>

//__________________________________________
int main(int argc, char *argv[])
{
    KLocalizedString::setApplicationDomain("fenstra_style_config");

    QApplication app(argc, argv);
    app.setApplicationName(i18n("Fenstra Settings"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("fenstra-settings")));

    KCMultiDialog dialog;
    dialog.setWindowTitle(i18n("Fenstra Settings"));
    dialog.addModule(KPluginMetaData(QStringLiteral("kstyle_config/fenstrastyleconfig")));
    dialog.addModule(KPluginMetaData(QStringLiteral("org.kde.kdecoration3.kcm/kcm_fenstradecoration.so")));
    dialog.show();

    const auto children = dialog.findChildren<QAbstractScrollArea *>();
    for (auto child : children) {
        child->adjustSize();
        child->viewport()->adjustSize();
    }

    return app.exec();
}
