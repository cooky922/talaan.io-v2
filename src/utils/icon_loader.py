from pathlib import Path
from PyQt6.QtGui import QIcon

class IconLoader:
    _icons = {}

    @staticmethod
    def load():
        icon_dir = Path(__file__).parent.parent.parent / 'assets' / 'images' / 'icons'
        for icon_file_name in icon_dir.glob('*.svg'):
            IconLoader._icons[icon_file_name.stem] = QIcon(str(icon_file_name))
    
    @staticmethod
    def get(name):
        return IconLoader._icons.get(name)