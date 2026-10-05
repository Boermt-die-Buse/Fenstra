#!/usr/bin/env python3
"""Fenstra-Stiltest: alle wichtigen Qt-Steuerelemente auf einer Seite (wie eine kleine
WinUI-Galerie), als reproduzierbare Vorlage für Bildschirmfotos und Pixelmessungen
(docs/checkliste-stil.md). Läuft in der Test-VM mit python3-pyqt6.

  stiltest.py                 Fenster 1000×700 an fester Position (Mitte)
  stiltest.py --fokus feld    Fokus ins Eingabefeld (Fokuszustand prüfen)
  stiltest.py --menue         Menü "Datei" nach dem Start öffnen
  stiltest.py --combo         Liste des Kombinationsfelds öffnen

Die Lage der Elemente ist fest (absolute Geometrie), damit Messpunkte in der Prüfliste
gleich bleiben. Koordinaten relativ zur Fensterinnenfläche stehen in KOORDINATEN.
"""
import sys
from PyQt6.QtCore import Qt, QTimer, QRect
from PyQt6.QtGui import QAction, QIcon, QKeySequence
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QPushButton, QToolButton, QLineEdit, QComboBox,
    QCheckBox, QRadioButton, QSlider, QProgressBar, QSpinBox, QListWidget, QTreeWidget,
    QTreeWidgetItem, QTabWidget, QLabel, QGroupBox, QTextEdit, QListWidgetItem,
)

# Lage der Elemente in der Innenfläche (x, y, b, h) – für die Prüfliste
KOORDINATEN = {
    'knopf': (24, 24, 120, 32),
    'knopf_standard': (156, 24, 120, 32),
    'knopf_aus': (288, 24, 120, 32),
    'werkzeugknopf': (420, 24, 40, 32),
    'feld': (24, 72, 252, 32),
    'feld_kennwort': (288, 72, 172, 32),
    'combo': (24, 120, 252, 32),
    'combo_edit': (288, 120, 172, 32),
    'haken_aus': (24, 168, 200, 32),
    'haken_an': (24, 200, 200, 32),
    'haken_teil': (24, 232, 200, 32),
    'option_an': (240, 168, 200, 32),
    'option_aus': (240, 200, 200, 32),
    'regler': (24, 280, 252, 32),
    'fortschritt': (24, 328, 252, 16),
    'drehfeld': (288, 280, 120, 32),
    'liste': (500, 24, 220, 220),
    'baum': (740, 24, 236, 220),
    'register': (500, 264, 476, 160),
    'gruppe': (24, 368, 436, 120),
    'text': (500, 440, 476, 200),
}


class Fenster(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Fenstra Stiltest')
        self.setWindowIcon(QIcon.fromTheme('preferences-desktop-theme'))
        self.resize(1000, 700)
        mb = self.menuBar()
        datei = mb.addMenu('&Datei')
        for name, icon, key in [('Neu', 'document-new', 'Ctrl+N'), ('Öffnen …', 'document-open', 'Ctrl+O'),
                                ('Speichern', 'document-save', 'Ctrl+S'), ('Speichern unter …', '', 'Ctrl+Shift+S')]:
            a = QAction(QIcon.fromTheme(icon) if icon else QIcon(), name, self)
            a.setShortcut(QKeySequence(key))
            datei.addAction(a)
        datei.addSeparator()
        zuletzt = datei.addMenu('Zuletzt verwendet')
        zuletzt.addAction('Bericht.txt')
        zuletzt.addAction('Notizen.md')
        a = QAction('Zeilenumbruch', self, checkable=True, checked=True)
        datei.addAction(a)
        dis = QAction('Drucken …', self)
        dis.setEnabled(False)
        datei.addAction(dis)
        datei.addSeparator()
        datei.addAction(QAction('Beenden', self, shortcut=QKeySequence('Ctrl+Q'), triggered=self.close))
        mb.addMenu('&Bearbeiten').addAction('Rückgängig')
        mb.addMenu('&Anzeigen').addAction('Zoom')

        w = QWidget()
        self.setCentralWidget(w)
        k = KOORDINATEN

        def setze(widget, key):
            widget.setParent(w)
            widget.setGeometry(QRect(*k[key]))
            return widget

        setze(QPushButton('Schaltfläche'), 'knopf')
        b = setze(QPushButton('Standard'), 'knopf_standard')
        b.setDefault(True)
        b = setze(QPushButton('Deaktiviert'), 'knopf_aus')
        b.setEnabled(False)
        t = setze(QToolButton(), 'werkzeugknopf')
        t.setIcon(QIcon.fromTheme('edit-copy'))
        t.setAutoRaise(True)
        self.feld = setze(QLineEdit(), 'feld')
        self.feld.setPlaceholderText('Platzhaltertext')
        self.feld.setClearButtonEnabled(True)
        p = setze(QLineEdit('geheim'), 'feld_kennwort')
        p.setEchoMode(QLineEdit.EchoMode.Password)
        self.combo = setze(QComboBox(), 'combo')
        self.combo.addItems(['Hell', 'Dunkel', 'Benutzerdefiniert'])
        c = setze(QComboBox(), 'combo_edit')
        c.setEditable(True)
        c.addItems(['100 %', '125 %', '150 %'])
        setze(QCheckBox('Kontrollkästchen'), 'haken_aus')
        cb = setze(QCheckBox('Angehakt'), 'haken_an')
        cb.setChecked(True)
        cb = setze(QCheckBox('Teilweise'), 'haken_teil')
        cb.setTristate(True)
        cb.setCheckState(Qt.CheckState.PartiallyChecked)
        r = setze(QRadioButton('Option an'), 'option_an')
        r.setChecked(True)
        setze(QRadioButton('Option aus'), 'option_aus')
        s = setze(QSlider(Qt.Orientation.Horizontal), 'regler')
        s.setValue(40)
        pb = setze(QProgressBar(), 'fortschritt')
        pb.setValue(60)
        pb.setTextVisible(False)
        sp = setze(QSpinBox(), 'drehfeld')
        sp.setValue(12)

        lw = setze(QListWidget(), 'liste')
        for i, n in enumerate(['Desktop', 'Downloads', 'Dokumente', 'Bilder', 'Musik', 'Videos',
                               'Lokaler Datenträger (C:)', 'Netzwerk', 'Papierkorb', 'Vorlagen']):
            it = QListWidgetItem(QIcon.fromTheme('folder'), n)
            lw.addItem(it)
        lw.setCurrentRow(2)
        tw = setze(QTreeWidget(), 'baum')
        tw.setHeaderLabels(['Name', 'Größe'])
        root = QTreeWidgetItem(tw, ['Dieser PC', ''])
        for n, g in [('Lokaler Datenträger (C:)', '237 GB'), ('Daten (D:)', '931 GB')]:
            QTreeWidgetItem(root, [n, g])
        QTreeWidgetItem(tw, ['Netzwerk', ''])
        tw.expandAll()
        tw.setCurrentItem(root.child(0))

        tabs = setze(QTabWidget(), 'register')
        for n in ['Allgemein', 'Freigabe', 'Sicherheit']:
            lab = QLabel(f'Inhalt des Registers „{n}“')
            lab.setAlignment(Qt.AlignmentFlag.AlignCenter)
            tabs.addTab(lab, n)
        g = setze(QGroupBox('Gruppe'), 'gruppe')
        QLabel('Beschriftung in einer Gruppe.\nZweite Zeile, sekundär.', g).setGeometry(16, 32, 400, 40)
        te = setze(QTextEdit(), 'text')
        te.setPlainText('\n'.join(f'Zeile {i}: Fenstra zeigt hier Text, damit eine Bildlaufleiste entsteht.'
                                  for i in range(1, 60)))
        for widget in w.findChildren(QWidget):
            widget.setToolTip(widget.metaObject().className())


def main():
    app = QApplication(sys.argv)
    f = Fenster()
    f.show()
    if '--fokus' in sys.argv:
        QTimer.singleShot(500, f.feld.setFocus)
    if '--menue' in sys.argv:
        QTimer.singleShot(800, lambda: f.menuBar().actions()[0].menu().popup(
            f.menuBar().mapToGlobal(f.menuBar().actionGeometry(f.menuBar().actions()[0]).bottomLeft())))
    if '--combo' in sys.argv:
        QTimer.singleShot(800, f.combo.showPopup)
    sys.exit(app.exec())


if __name__ == '__main__':
    main()
