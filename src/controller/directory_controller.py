import math
from PyQt6.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal # type: ignore

from src.model.entries import EntryKind
from src.model.errors import ValidationError, ValidationErrorKind, DatabaseError, DatabaseErrorKind
from src.model.database import (
    StudentDirectory, 
    ProgramDirectory, 
    CollegeDirectory, 
    ConstraintAction, 
    Paged, 
    Sorted
)
    
class QMLDirectoryController(QObject):
    directoryChanged = pyqtSignal()
    paginationChanged = pyqtSignal()
    sortStateChanged = pyqtSignal()
    searchChanged = pyqtSignal()

    def __init__(self, model, parent = None):
        super().__init__(parent)
        self.model = model
        self.db = StudentDirectory # default directory
        
        # Core States
        self._page_index = 0
        self._page_size = 100
        self._visible_entries = 0
        self._total_entries = 0

        self._filter_options = None
        self.reset_filter_options()

        self._sort_field_index = 0
        self._sort_ascending = True

        self._search_text = ""
        self._search_filter_index = 0

    @pyqtProperty(int, notify = paginationChanged)
    def totalEntries(self):
        return self._total_entries
    
    @pyqtProperty(int, notify = paginationChanged)
    def visibleEntries(self):
        return self._visible_entries

    @pyqtProperty(str, notify = directoryChanged)
    def currentDirectoryName(self):
        return self.db.get_entry_kind().value

    @pyqtSlot(result = str)
    def getPrimaryKey(self):
        return self.db.get_primary_key()

    @pyqtProperty(int, notify = paginationChanged)
    def pageIndex(self):
        return self._page_index
    
    @pyqtProperty(int)
    def pageSize(self):
        return self._page_size

    @pyqtProperty(int, notify = paginationChanged)
    def totalPages(self):
        if self._total_entries == 0:
            return 1
        return max(1, math.ceil(self._total_entries / self._page_size))
    
    @pyqtProperty(list, notify = directoryChanged)
    def filterOptions(self):
        return self._filter_options
    
    @pyqtProperty(int, notify = sortStateChanged)
    def sortFieldIndex(self):
        return self._sort_field_index
    
    @pyqtProperty(bool, notify = sortStateChanged)
    def sortAscending(self):
        return self._sort_ascending
    
    @pyqtProperty(str, notify = searchChanged)
    def searchText(self):
        return self._search_text
    
    @pyqtProperty(int, notify = searchChanged)
    def searchFilterIndex(self):
        return self._search_filter_index
    
    @pyqtProperty('QVariantList', notify = directoryChanged)
    def currentDirectorySchema(self):
        fields = self.db.get_entry_kind().get_entry_type().get_fields()
        def get_options(field_name : str):
            results = []
            match field_name:
                case 'gender':
                    results = ['Male', 'Female', 'Other']
                case 'program_code' if self.db.get_entry_kind() == EntryKind.STUDENT:
                    results = ['None'] + sorted(ProgramDirectory.get_keys())
                case 'college_code' if self.db.get_entry_kind() == EntryKind.PROGRAM:
                    results = ['None'] + sorted(CollegeDirectory.get_keys())
            return results
        return [{
            'internal_name': field_info.internal_name,
            'display_name':  field_info.display_name,
            'options': get_options(field_info.internal_name) # used in comboboxes
        } for _, field_info in fields.items()]
    
    @pyqtSlot(str)
    def changeDirectory(self, directory_name):
        if self.currentDirectoryName != directory_name:
            match directory_name:
                case 'Student':
                    self.db = StudentDirectory
                case 'Program':
                    self.db = ProgramDirectory
                case 'College':
                    self.db = CollegeDirectory
            self._page_index = 0
            self.reset_filter_options()
            self._search_filter_index = 0
            self._sort_field_index = 0
            self._sort_ascending = True
            self.sortStateChanged.emit()
            self.directoryChanged.emit()
            self.refresh_table()

    @pyqtSlot(str)
    def updateSearch(self, text):
        if self._search_text != text:
            self._search_text = text
            self._page_index = 0
            
            self.searchChanged.emit()
            self.paginationChanged.emit() 
            self.refresh_table()

    @pyqtSlot(int)
    def setSearchFilterIndex(self, index):
        if self._search_filter_index != index:
            self._search_filter_index = index
            if self._search_text.strip() != '':
                self._page_index = 0
                self.searchChanged.emit()
                self.refresh_table()

    @pyqtSlot(int)
    def toggleSort(self, field_index):
        if self._sort_field_index == field_index:
            self._sort_ascending = not self._sort_ascending
        else:
            self._sort_field_index = field_index
            self._sort_ascending = True
        self._page_index = 0
        self.sortStateChanged.emit()
        self.paginationChanged.emit()
        self.refresh_table()

    @pyqtSlot()
    def nextPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index += 1
            self.refresh_table()

    @pyqtSlot()
    def prevPage(self):
        if self._page_index > 0:
            self._page_index -= 1
            self.refresh_table()

    @pyqtSlot()
    def setFirstPage(self):
        if self._page_index > 0:
            self._page_index = 0
            self.refresh_table()

    @pyqtSlot()
    def setLastPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index = self.totalPages - 1
            self.refresh_table()

    @pyqtSlot()
    def resetOnLogout(self):
        self.db = StudentDirectory
        self._page_index = 0
        self._sort_field_index = 0
        self._sort_ascending = True
        self._search_text = ""
        self._search_filter_index = 0
        self._filter_options = None
        self.reset_filter_options()
        self.sortStateChanged.emit()
        self.directoryChanged.emit()
        self.searchChanged.emit()
        self.refresh_table()

    @pyqtSlot('QVariantMap', 'QVariantMap', str, result = 'QVariantMap')
    def validateForm(self, initial_data, current_data, mode):
        # initialize things ...
        entry_kind = self.db.get_entry_kind()
        EntryType = entry_kind.get_entry_type()
        ParentDirectoryType = None
        match entry_kind:
            case EntryKind.STUDENT:
                ParentDirectoryType = ProgramDirectory
            case EntryKind.PROGRAM:
                ParentDirectoryType = CollegeDirectory
        primary_key = self.db.get_primary_key()
        # status
        errors = {}
        is_valid = True
        
        # 1. Check for empty fields based on your schema
        for col in self.db.get_columns():
            val = current_data.get(col, '')
            # defer empty string checking to field validation
            try:
                if entry_kind != EntryKind.COLLEGE:
                    EntryType.validate_field(EntryType.FieldKind.from_internal_name(col), val, ParentDirectoryType)
                else:
                    EntryType.validate_field(EntryType.FieldKind.from_internal_name(col), val)
            except ValidationError as e:
                errors[col] = e.message
                is_valid = False
                continue
            # check add record, update record (only for primary key)
            if primary_key is not None and col == primary_key:
                try:
                    if mode == 'edit' and current_data[primary_key] == initial_data[primary_key]:
                        continue
                    # check if the key already exists
                    self.db._db.validate_add_record(current_data)
                except DatabaseError as e:
                    errors[col] = e.message
                    is_valid = False
        return {
            'isValid': is_valid,
            'errors': errors
        }
    
    @pyqtSlot('QVariantMap', result = 'QVariantMap')
    def addRecord(self, new_data):
        try:
            record = {k: (v if k == 'year' else str(v)) for k, v in new_data.items()}
            # inject it as an empty string so 'requires_all = True' doesn't panic.
            for col in self.db.get_columns():
                if col not in record:
                    record[col] = ''
            self.db.add_record(record)
            return {'success': True, 'message': 'Record added successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refresh_table()

    @pyqtSlot('QVariantMap', 'QVariantMap', result = 'QVariantMap')
    def updateRecord(self, old_data, new_data):
        try:
            updates = {k: (v if k == 'year' else str(v)) for k, v in new_data.items()}
            primary_key = self.db.get_primary_key()
            old_key_value = str(old_data[primary_key])
            self.db.update_record(updates, key = old_key_value)                
            return {'success': True, 'message': 'Changes saved successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refresh_table()

    @pyqtSlot('QVariantMap', result = 'QVariantMap')
    def deleteRecord(self, old_data):
        try:
            primary_key = self.db.get_primary_key()
            key_value = str(old_data[primary_key])
            self.db.delete_record(key = key_value)
            return {'success': True, 'message': 'Record deleted successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refresh_table()

    # =========================================
    # CORE DATA LOGIC
    # =========================================
    def reset_filter_options(self):
        self._filter_options = ['All Fields'] + [
            self.db.get_entry_kind()
                .get_entry_type()
                .get_fields()[column].display_name
            for column in self.db.get_columns()
        ]

    def refresh_table(self):
        # get columns
        columns = self.db.get_columns()
        
        # building a 'where' clause
        where_clause = None
        if self._search_text:
            search_str = self._search_text.strip().lower()
            if self._search_filter_index == 0:
                where_clause = lambda row: any(search_str in str(val).lower() for val in row.values)
            else:
                # Special Case: when db == Student and search filter == Gender
                if self.db.get_entry_kind() == EntryKind.STUDENT and self._search_filter_index == 6:
                    where_clause =  lambda row: str(row.get(columns[self._search_filter_index - 1], '')).lower().startswith(search_str)
                else:
                    where_clause = lambda row: search_str in str(row.get(columns[self._search_filter_index - 1], '')).lower()

        # sorted and paged request
        paged_request = Paged.Specific(index = self._page_index + 1, size = self._page_size)
        sorted_request = Sorted.By(column = columns[self._sort_field_index] , ascending = self._sort_ascending)

        self._total_entries = self.db.get_count(where = where_clause)

        entries = self.db.get_records(
            where = where_clause,
            sorted = sorted_request,
            paged = paged_request
        )

        self.model.resetModel(self.db, entries)

        self._visible_entries = len(entries)

        self.paginationChanged.emit()