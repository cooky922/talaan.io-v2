import ctypes
import os
import sys
from pathlib import Path
from PyQt6.QtCore import QUrl # type: ignore
from PyQt6.QtGui import QGuiApplication, QIcon, QColor # type: ignore
from PyQt6.QtQml import QQmlApplicationEngine # type: ignore

from src.model.database import StudentDirectory, ProgramDirectory, CollegeDirectory
from src.model.table_model import DirectoryTableModel
from src.view.theme import FontLoader, QMLAppTheme
from src.controller.directory_controller import QMLDirectoryController
from src.utils import QMLUtils
    
def warning_handler(warnings):
    for w in warnings:
        print(f'File: {w.url().toString()}')
        print(f'Line: {w.line()}, Column: {w.column()}')
        print(f'Error: {w.description()}')
    print('--------------------------\n')

def initialize_app():
    # os.environ['QML_DISABLE_DISK_CACHE'] = '1'
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Basic'
    try:
        myappid = 'ccc151.talaan_io.desktop_app.2_0'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
    except AttributeError:
        pass

def initialize_gui():
    FontLoader.initialize()

def exit_app(return_code : int):
    StudentDirectory.save()
    ProgramDirectory.save()
    CollegeDirectory.save()
    sys.exit(return_code)

def main():
    initialize_app()
    app = QGuiApplication([])
    engine = QQmlApplicationEngine()
    engine.warnings.connect(warning_handler)
    initialize_gui()

    app_icon_file_path = str(Path(__file__).parent / 'assets' / 'images' / 'icons' / 'app-logo.ico')
    qml_file_path = str(Path(__file__).parent / 'src' / 'view' / 'MainWindow.qml')

    app.setWindowIcon(QIcon(app_icon_file_path))

    appUtils = QMLUtils(app)
    appTheme = QMLAppTheme(app)
    appDirectoryModel = DirectoryTableModel(StudentDirectory)
    appDirectoryController = QMLDirectoryController(appDirectoryModel, app)
    appDirectoryController.refresh_table()

    context = engine.rootContext()
    context.setContextProperty('appUtils', appUtils)
    context.setContextProperty('appTheme', appTheme)
    context.setContextProperty('appDirectoryModel', appDirectoryModel)
    context.setContextProperty('appDirectoryController', appDirectoryController)

    engine.load(QUrl.fromLocalFile(qml_file_path))

    if not engine.rootObjects():
        exit_app(-1)
        
    ret = app.exec()
    exit_app(ret)

if __name__ == '__main__':
    main()