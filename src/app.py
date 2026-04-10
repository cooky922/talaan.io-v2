import ctypes
import os
import sys
from pathlib import Path
from PyQt6.QtCore import QUrl # type: ignore
from PyQt6.QtGui import QSurfaceFormat, QIcon # type: ignore
from PyQt6.QtQml import QQmlApplicationEngine # type: ignore
from PyQt6.QtWidgets import QApplication

from src.controller import QMLRecordsController, QMLDashboardController, QMLSettingsController
from src.database import SQLDatabase, seedDatabase
from src.model import RecordTableModel
from src.utils import QMLUtils
from src.view.theme import FontLoader, QMLAppTheme

class App(QApplication):
    windows_app_id = 'ccc151.talaan_io.desktop_app.2_0'
    app_icon_file_path = str(Path(__file__).parent.parent / 'assets' / 'images' / 'icons' / 'app-logo.ico')
    app_qml_file_path = str(Path(__file__).parent.parent / 'src' / 'view' / 'MainWindow.qml')

    def __init__(self):
        # Load Database First
        SQLDatabase.initialize()

        # Seed database with sample data if empty
        seedDatabase()

        # Force Hardware Multisampling
        fmt = QSurfaceFormat()
        fmt.setSamples(8)
        QSurfaceFormat.setDefaultFormat(fmt)

        super().__init__([])

        # Setup app identity for QSettings
        self.setOrganizationName('ccc151')
        self.setApplicationName('talaan_io')

        # "Bare metal" Windows Initialization
        os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Basic'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(App.windows_app_id)

        # QML Application Engine
        self.engine = QQmlApplicationEngine()
        self.engine.warnings.connect(App.warningHandler)

        # Load Fonts
        FontLoader.initialize()

        # Set Window Icon
        self.setWindowIcon(QIcon(App.app_icon_file_path))

        # Creating objects necessary for QML bridge
        self.appUtils = QMLUtils(self)
        self.appTheme = QMLAppTheme(self)
        self.appRecordTableModel = RecordTableModel(self)
        self.appRecordsController = QMLRecordsController(self.appRecordTableModel, self)
        self.appRecordsController.refreshTable()

        self.appDashboardController = QMLDashboardController(self)
        self.appDashboardController.refreshData()

        self.appSettingsController = QMLSettingsController(self)

        self.appRecordsController.setPageSize(self.appSettingsController.pageSize)
        self.appTheme.setThemeColor(self.appSettingsController.themeColorIndex)

        self.appSettingsController.themeColorIndexChanged.connect(self.appTheme.setThemeColor)
        self.appSettingsController.pageSizeChanged.connect(self.appRecordsController.setPageSize)

        # Prepare QML context properties and load file
        context = self.engine.rootContext()
        context.setContextProperty('appUtils', self.appUtils)
        context.setContextProperty('appTheme', self.appTheme)
        context.setContextProperty('appRecordTableModel', self.appRecordTableModel)
        context.setContextProperty('appRecordsController', self.appRecordsController)
        context.setContextProperty('appDashboardController', self.appDashboardController)
        context.setContextProperty('appSettingsController', self.appSettingsController)
        self.engine.load(QUrl.fromLocalFile(App.app_qml_file_path))

        # Return early if invalid (ex: QML errors)
        if not self.engine.rootObjects():
            self.exitApp(-1)

    def run(self):
        ret = self.exec()
        self.exitApp(ret)

    def exitApp(self, return_code : int):
        sys.exit(return_code)

    @staticmethod
    def warningHandler(warnings):
        for w in warnings:
            print(f'File: {w.url().toString()}')
            print(f'Line: {w.line()}, Column: {w.column()}')
            print(f'Error: {w.description()}')
        print('--------------------------\n')