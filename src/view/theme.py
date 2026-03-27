from dataclasses import dataclass
from pathlib import Path
from PyQt6.QtGui import QFontDatabase # type: ignore
from PyQt6.QtCore import QObject, pyqtProperty # type: ignore

class classproperty(object):
    def __init__(self, fget):
        self.fget = fget

    def __get__(self, owner_self, owner_cls):
        # The owner_cls is the class from which the attribute is accessed
        return self.fget(owner_cls)

class FontLoader:
    _font_resource_dir = Path(__file__).parent.parent.parent / 'assets' / 'fonts'
    _fonts = {
        'DEFAULT': {
            'family_name' : 'Arial'
        },
        'ROKKITT': {
            # undefined 'family_name' yet
            'path': str(_font_resource_dir / 'Rokkitt' / 'Rokkitt-VariableFont_wght.ttf')
        },
        'RETHINK_SANS': {
            # undefined 'family_name' yet
            'path': str(_font_resource_dir / 'Rethink_Sans' / 'RethinkSans-VariableFont_wght.ttf')
        }
    }

    @classmethod
    def hasInitialized(self):
        for _, font_info in self._fonts.items():
            if 'family_name' not in font_info:
                return False
        return True   

    @classmethod
    def initialize(self):
        for _, font_info in self._fonts.items():
            if 'path' in font_info:
                font_path = font_info['path']
                if not Path(font_path).exists():
                    raise FileNotFoundError(f'Font file not found: {font_path}')
                font_id = QFontDatabase.addApplicationFont(font_path)
                if font_id == -1:
                    raise Exception(f'Failed to load font: {font_path}')
                # success
                family_name = QFontDatabase.applicationFontFamilies(font_id)[0]
                font_info.update({ 'family_name': family_name })

    @classmethod
    def getFamilyName(self, key):
        return self._fonts.get(key.upper(), 'DEFAULT')['family_name']
    
@dataclass(frozen = True, init = False)
class Theme:
    # Colors
    MAIN_BG_COLOR = '#E6FF76'
    MAIN_BG_COLOR_LAST = '#C4E047'

    CARD_BG_COLOR = '#FFFFFF'
    CARD_SHADOW_COLOR = "#EBEBEB"

    HEADER_BG_COLOR = '#EFFFA4'
    HEADER_BUTTON_BG_COLOR = '#E8F3B5'

    ACTIVE_BUTTON_BG_COLOR = '#93A932'
    ACTIVE_BUTTON_BORDER_COLOR = '#687B11'

    LOGIN_BUTTON_BG_COLOR = '#5759D7'
    LOGOUT_BUTTON_BG_COLOR = '#F45742'

    DARK_TEXT_COLOR = '#333333'

    # Fonts
    _ROKKITT_FONT_NAME = None
    _RETHINK_SANS_FONT_NAME = None

    @classproperty
    def ROKKITT_FONT_NAME(self):
        if self._ROKKITT_FONT_NAME is None and FontLoader.hasInitialized():
            self._ROKKITT_FONT_NAME = FontLoader.getFamilyName('ROKKITT')
        return self._ROKKITT_FONT_NAME
    
    @classproperty
    def RETHINK_SANS_FONT_NAME(self):
        if self._RETHINK_SANS_FONT_NAME is None and FontLoader.hasInitialized():
            self._RETHINK_SANS_FONT_NAME = FontLoader.getFamilyName('RETHINK_SANS')
        return self._RETHINK_SANS_FONT_NAME

class QMLAppTheme(QObject):
    def __init__(self, parent = None):
        super().__init__(parent)

    @pyqtProperty(str)
    def mainBgColor(self): return Theme.MAIN_BG_COLOR

    @pyqtProperty(str)
    def mainBgColorLast(self): return Theme.MAIN_BG_COLOR_LAST

    @pyqtProperty(str)
    def cardBgColor(self): return Theme.CARD_BG_COLOR

    @pyqtProperty(str)
    def cardShadowColor(self): return Theme.CARD_SHADOW_COLOR

    @pyqtProperty(str)
    def headerBgColor(self): return Theme.HEADER_BG_COLOR

    @pyqtProperty(str)
    def headerButtonBgColor(self): return Theme.HEADER_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def activeButtonBgColor(self): return Theme.ACTIVE_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def activeButtonBorderColor(self): return Theme.ACTIVE_BUTTON_BORDER_COLOR

    @pyqtProperty(str)
    def loginButtonBgColor(self): return Theme.LOGIN_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def logoutButtonBgColor(self): return Theme.LOGOUT_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def darkTextColor(self): return Theme.DARK_TEXT_COLOR

    @pyqtProperty(str)
    def rokkittFontName(self): return Theme.ROKKITT_FONT_NAME

    @pyqtProperty(str)
    def rethinkSansFontName(self): return Theme.RETHINK_SANS_FONT_NAME