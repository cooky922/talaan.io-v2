from PyQt6.QtCore import Qt, QAbstractTableModel, QModelIndex, pyqtSlot, pyqtProperty # type: ignore

from src.model.entity_models import EntityKind
from src.model.repositories import REPOSITORY_MAP

class RecordTableModel(QAbstractTableModel):
    def __init__(self):
        super().__init__()
        self._entity_kind = EntityKind.STUDENT
        self._headers = REPOSITORY_MAP[self._entity_kind].get_columns()
        self._data = [] # This data holds only the exact rows for the current page

    def resetModel(self, entity_kind, data : list[dict] = None):
        self.beginResetModel()
        self._entity_kind = entity_kind
        self._headers = REPOSITORY_MAP[entity_kind].get_columns()
        self._data = data if data is not None else []
        self.endResetModel()
    
    def rowCount(self, parent = QModelIndex()):
        return len(self._data)
    
    def columnCount(self, parent = QModelIndex()):
        return len(self._headers)
    
    def data(self, index, role = Qt.ItemDataRole.DisplayRole):
        if not index.isValid():
            return None
        if role == Qt.ItemDataRole.DisplayRole:
            row = index.row()
            col = index.column()
            key = self._headers[col]
            value = self._data[row].get(key, '')
            return None if value is None else str(value)
        return None
    
    def headerData(self, section, orientation, role = Qt.ItemDataRole.DisplayRole):
        if role == Qt.ItemDataRole.DisplayRole and orientation == Qt.Orientation.Horizontal:
            return self._entity_kind.get_model().get_fields()[self._headers[section]].display_name
        return None
    
    @pyqtSlot(int, result = 'QVariantMap')
    def getRowData(self, row):
        if 0 <= row < len(self._data):
            return self._data[row]
        else:
            return {}

    @pyqtSlot(int, result = int)
    def getColumnWidth(self, column):
        """
        Calculates the maximum pixel width needed for a column by checking 
        the header title and all visible rows in the current page.
        """
        # if the table is empty or booting up
        if not self._data or not self._entity_kind:
            return 150 
            
        columns = REPOSITORY_MAP[self._entity_kind].get_columns()
        if column < 0 or column >= len(columns):
            return 150
            
        col_key = columns[column]
        
        # start with the length of the Header title
        try:
            fields_info = self._entity_kind.get_model().get_fields()
            header_text = fields_info[col_key].display_name
            max_chars = len(header_text)
        except Exception:
            max_chars = 10
            
        # scan the current page of data for the longest string
        for record in self._data:
            # assuming your records are dictionaries or have a .get() method
            val_str = str(record.get(col_key, ''))
            if len(val_str) > max_chars:
                max_chars = len(val_str)
                
        # convert character count to pixels
        # [~9 pixels per character (for standard 12px font) + 30px for cell padding]
        calculated_width = (max_chars * 9) + 20
        
        # cap the max width to prevent a massive paragraph from breaking the UI
        # [and ensure a minimum width of 80 so tiny columns still look like headers]
        final_width = max(50, min(calculated_width, 400))
        
        return final_width