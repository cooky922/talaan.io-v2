import ctypes
import os
import sys
from pathlib import Path
from PyQt6.QtCore import QUrl # type: ignore
from PyQt6.QtGui import QGuiApplication, QIcon # type: ignore
from PyQt6.QtQml import QQmlApplicationEngine # type: ignore

from src.controller.directory_controller import QMLDirectoryController
from src.database.database import SQLDatabase
from src.model.table_model import DirectoryTableModel
from src.view.theme import FontLoader, QMLAppTheme
from src.utils import QMLUtils

class App(QGuiApplication):
    windows_app_id = 'ccc151.talaan_io.desktop_app.2_0'
    app_icon_file_path = str(Path(__file__).parent.parent / 'assets' / 'images' / 'icons' / 'app-logo.ico')
    app_qml_file_path = str(Path(__file__).parent.parent / 'src' / 'view' / 'MainWindow.qml')

    def __init__(self):
        # Load Database First
        SQLDatabase.initialize()

        # TODO: Remove this and replace with proper migration system.
        # CollegeDirectory.import_from_csv(Path(__file__).parent.parent / 'data' / 'colleges.csv')
        # ProgramDirectory.import_from_csv(Path(__file__).parent.parent / 'data' / 'programs.csv')
        # StudentDirectory.import_from_csv(Path(__file__).parent.parent / 'data' / 'students.csv')

        super().__init__([])

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
        self.appDirectoryModel = DirectoryTableModel()
        self.appDirectoryController = QMLDirectoryController(self.appDirectoryModel, self)
        self.appDirectoryController.refresh_table()

        # Prepare QML context properties and load file
        context = self.engine.rootContext()
        context.setContextProperty('appUtils', self.appUtils)
        context.setContextProperty('appTheme', self.appTheme)
        context.setContextProperty('appDirectoryModel', self.appDirectoryModel)
        context.setContextProperty('appDirectoryController', self.appDirectoryController)
        self.engine.load(QUrl.fromLocalFile(App.app_qml_file_path))

        # Return early if invalid (e.g. QML errors)
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