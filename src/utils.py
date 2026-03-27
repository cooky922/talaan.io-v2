from PyQt6.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal # type: ignore
from PyQt6.QtGui import QGuiApplication, QIcon, QColor # type: ignore

class QMLUtils(QObject):
    def __init__(self, parent = None):
        super().__init__(parent)

    @pyqtSlot(str, result = bool)
    def printLog(self, msg):
        print(msg)
        return True

    @pyqtSlot(str, bool, bool, result = str)
    def calculateColor(self, color, is_hovered, is_pressed):
        qcolor = QColor(color)
        is_light_color = qcolor.lightness() > 220
        if is_hovered:
            return (qcolor.darker(110) if is_light_color else qcolor.lighter(110)).name()
        elif is_pressed:
            return (qcolor.darker(120) if is_light_color else qcolor.lighter(120)).name()
        else:
            return color

    @pyqtSlot(str, result = str)
    def prettifyColumnName(self, name):
        return name.replace('_', ' ').title()