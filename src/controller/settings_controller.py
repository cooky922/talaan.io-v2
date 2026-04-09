from PyQt6.QtCore import QObject, pyqtProperty, pyqtSlot, pyqtSignal, QSettings

class QMLSettingsController(QObject):
    themeColorIndexChanged = pyqtSignal(int)
    pageSizeChanged = pyqtSignal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.settings = QSettings()
        
        # > load saved values
        self._theme_color_index = self.settings.value('theme/colorIndex', 0, type = int)
        self._page_size = self.settings.value('ui/pageSize', 10, type = int)

    @pyqtProperty(int, notify = themeColorIndexChanged)
    def themeColorIndex(self):
        return self._theme_color_index

    @pyqtSlot(int)
    def setThemeColorIndex(self, index):
        if self._theme_color_index != index:
            self._theme_color_index = index
            self.settings.setValue('theme/colorIndex', index)
            self.themeColorIndexChanged.emit(index)

    @pyqtProperty(int, notify = pageSizeChanged)
    def pageSize(self):
        return self._page_size

    @pyqtSlot(int)
    def setPageSize(self, size):
        if self._page_size != size:
            self._page_size = size
            self.settings.setValue('ui/pageSize', size) # > save to disk instantly
            self.pageSizeChanged.emit(size)