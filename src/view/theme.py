from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from PyQt6.QtGui import QFontDatabase # type: ignore
from PyQt6.QtCore import QObject, pyqtProperty, pyqtSlot, pyqtSignal # type: ignore

class classproperty(object):
    def __init__(self, fget):
        self.fget = fget

    def __get__(self, owner_self, owner_cls):
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
    
@dataclass
class ColorScheme:
    background_color : str
    background_color_last : str
    active_button_color : str 
    active_button_border_color : str

class ColorSchemeKind(Enum):
    GREEN = ColorScheme(
        background_color = '#E6FF76',
        background_color_last = '#C4E047',
        active_button_color = '#93A932',
        active_button_border_color = '#687B11'
    )
    PINK = ColorScheme(
        background_color = "#FFCFE4",
        background_color_last = '#FF81C8',
        active_button_color = "#D2509A",
        active_button_border_color = "#9B336E"
    )
    PURPLE = ColorScheme(
        background_color = '#E1B2f5',
        background_color_last = '#CE5CFF',
        active_button_color = "#972AC6",
        active_button_border_color = "#7918A3"
    )
    BLUE = ColorScheme(
        background_color = "#98E0FF",
        background_color_last = '#4887C3',
        active_button_color = "#24629B",
        active_button_border_color = "#0F4374"
    )
    YELLOW = ColorScheme(
        background_color = "#FCEC9A",
        background_color_last = "#FFE880",
        active_button_color = "#FFC118",
        active_button_border_color = "#ECA100"
    )
    ORANGE = ColorScheme(
        background_color = "#FFD08E",
        background_color_last = "#FFBD71",
        active_button_color = "#FF983F",
        active_button_border_color = "#FF8F2D"
    )

@dataclass(frozen = True, init = False)
class Theme:
    CARD_BG_COLOR = '#FFFFFF'
    CARD_SHADOW_COLOR = "#EBEBEB"

    LOGOUT_BUTTON_BG_COLOR = '#F45742'
    ERROR_COLOR = '#FF4C4C'

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
    themeChanged = pyqtSignal()

    def __init__(self, parent = None):
        super().__init__(parent)
        self.color_scheme_kind = ColorSchemeKind.GREEN # by default

    @pyqtProperty(str, notify = themeChanged)
    def mainBgColor(self): return self.color_scheme_kind.value.background_color

    @pyqtProperty(str, notify = themeChanged)
    def mainBgColorLast(self): return self.color_scheme_kind.value.background_color_last

    @pyqtProperty(str)
    def cardBgColor(self): return Theme.CARD_BG_COLOR

    @pyqtProperty(str)
    def cardShadowColor(self): return Theme.CARD_SHADOW_COLOR

    @pyqtProperty(str, notify = themeChanged)
    def activeButtonBgColor(self): return self.color_scheme_kind.value.active_button_color

    @pyqtProperty(str, notify = themeChanged)
    def activeButtonBorderColor(self): return self.color_scheme_kind.value.active_button_border_color

    @pyqtProperty(str)
    def logoutButtonBgColor(self): return Theme.LOGOUT_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def errorColor(self): return Theme.ERROR_COLOR

    @pyqtProperty(str)
    def darkTextColor(self): return Theme.DARK_TEXT_COLOR

    @pyqtProperty(str)
    def rokkittFontName(self): return Theme.ROKKITT_FONT_NAME

    @pyqtProperty(str)
    def rethinkSansFontName(self): return Theme.RETHINK_SANS_FONT_NAME

    @pyqtSlot(int)
    def setThemeColor(self, index):
        current_index = list(ColorSchemeKind).index(self.color_scheme_kind)
        if (current_index != index):
            self.color_scheme_kind = list(ColorSchemeKind)[index]
            self.themeChanged.emit()

    @pyqtProperty(int, notify = themeChanged)
    def themeColorIndex(self):
        return list(ColorSchemeKind).index(self.color_scheme_kind)
    
    @pyqtProperty('QVariantList')
    def allThemeColors(self):
        return [
            {
                'name': item.name.title(),
                'color1': item.value.background_color,
                'color2': item.value.background_color_last
            } for item in ColorSchemeKind
        ]