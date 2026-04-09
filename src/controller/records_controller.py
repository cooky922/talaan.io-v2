import math
from PyQt6.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal
from src.database.queries import Paged, Sorted, Search
from src.model.entity_models import EntityKind
from src.model.errors import ValidationError, DatabaseError
from src.model.repositories import (
    StudentRepository, 
    ProgramRepository, 
    CollegeRepository,
    REPOSITORY_MAP
)
    
class QMLRecordsController(QObject):
    selectedEntityChanged = pyqtSignal()
    paginationChanged = pyqtSignal()
    sortStateChanged = pyqtSignal()
    searchChanged = pyqtSignal()

    def __init__(self, table_model, parent = None):
        super().__init__(parent)
        self.table_model = table_model
        self.entity_kind = EntityKind.STUDENT # default selected entity kind
        
        # Core States
        self._page_index = 0
        self._page_size = 100
        self._visible_item_count = 0 # visible number of records in the current page
        self._total_item_count = 0 # total number of records matching the criteria

        self._filter_options = None
        self.resetFilterOptions()

        self._sort_field_index = 0
        self._sort_ascending = True

        self._search_text = ""
        self._search_filter_index = 0

    @pyqtProperty(int, notify = paginationChanged)
    def totalItemCount(self):
        return self._total_item_count
    
    @pyqtProperty(int, notify = paginationChanged)
    def visibleItemCount(self):
        return self._visible_item_count

    @pyqtProperty(str, notify = selectedEntityChanged)
    def selectedEntityName(self):
        return self.entity_kind.value

    @pyqtSlot(result = str)
    def getPrimaryKey(self):
        return REPOSITORY_MAP[self.entity_kind].get_primary_key()

    @pyqtProperty(int, notify = paginationChanged)
    def pageIndex(self):
        return self._page_index
    
    @pyqtProperty(int, notify = paginationChanged)
    def pageSize(self):
        return self._page_size

    @pyqtProperty(int, notify = paginationChanged)
    def totalPages(self):
        if self._total_item_count == 0:
            return 1
        return max(1, math.ceil(self._total_item_count / self._page_size))
    
    @pyqtProperty(list, notify = selectedEntityChanged)
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
    
    @pyqtProperty('QVariantList', notify = selectedEntityChanged)
    def selectedEntityTransformedModel(self):
        fields = self.entity_kind.get_model().get_fields()
        def get_options(field_name : str):
            match field_name:
                case 'gender':
                    return ['Male', 'Female', 'Other']
                case 'program_code' if self.entity_kind == EntityKind.STUDENT:
                    return ['None'] + sorted(ProgramRepository.get_keys())
                case 'college_code' if self.entity_kind == EntityKind.PROGRAM:
                    return ['None'] + sorted(CollegeRepository.get_keys())
                case _:
                    return []
        return [{
            'internal_name': field_info.internal_name,
            'display_name':  field_info.display_name,
            'options': get_options(field_info.internal_name) # used in comboboxes
        } for _, field_info in fields.items()]
    
    @pyqtSlot(str)
    def reselectEntity(self, entity_name):
        if self.selectedEntityName != entity_name:
            match entity_name:
                case 'Student': self.entity_kind = EntityKind.STUDENT
                case 'Program': self.entity_kind = EntityKind.PROGRAM
                case 'College': self.entity_kind = EntityKind.COLLEGE
            self._page_index = 0
            self.resetFilterOptions()
            self._search_filter_index = 0
            self._sort_field_index = 0
            self._sort_ascending = True
            self.sortStateChanged.emit()
            self.selectedEntityChanged.emit()
            self.refreshTable()

    @pyqtSlot(str)
    def updateSearch(self, text):
        if self._search_text != text:
            self._search_text = text
            self._page_index = 0
            
            self.searchChanged.emit()
            self.paginationChanged.emit() 
            self.refreshTable()

    @pyqtSlot(int)
    def setSearchFilterIndex(self, index):
        if self._search_filter_index != index:
            self._search_filter_index = index
            if self._search_text.strip() != '':
                self._page_index = 0
                self.searchChanged.emit()
                self.refreshTable()

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
        self.refreshTable()

    @pyqtSlot()
    def nextPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index += 1
            self.refreshTable()

    @pyqtSlot()
    def prevPage(self):
        if self._page_index > 0:
            self._page_index -= 1
            self.refreshTable()

    @pyqtSlot()
    def setFirstPage(self):
        if self._page_index > 0:
            self._page_index = 0
            self.refreshTable()

    @pyqtSlot()
    def setLastPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index = self.totalPages - 1
            self.refreshTable()

    @pyqtSlot(int)
    def setPage(self, page_number):
        target_index = page_number - 1
        if 0 <= target_index < self.totalPages:
            self._page_index = target_index
            self.refreshTable()

    @pyqtSlot(int)
    def setPageSize(self, size):
        if self._page_size != size:
            self._page_size = size
            self._page_index = 0
            self.paginationChanged.emit()
            self.refreshTable()

    @pyqtSlot()
    def resetStates(self):
        self.entity_kind = EntityKind.STUDENT
        self._page_index = 0
        self._sort_field_index = 0
        self._sort_ascending = True
        self._search_text = ""
        self._search_filter_index = 0
        self._filter_options = None
        self.resetFilterOptions()
        self.sortStateChanged.emit()
        self.selectedEntityChanged.emit()
        self.searchChanged.emit()
        self.refreshTable()

    @pyqtSlot('QVariantMap', 'QVariantMap', result = bool)
    def areRecordsEqual(self, old_data, new_data):
        # TODO: optimize
        return old_data == self.normalizeRecord(new_data)

    @pyqtSlot('QVariantMap', 'QVariantMap', str, result = 'QVariantMap')
    def validateRecord(self, initial_data, current_data, mode):
        # initialize things ...
        entity_model = self.entity_kind.get_model()
        parent_repository = REPOSITORY_MAP.get(self.entity_kind.get_parent())
        primary_key = self.getPrimaryKey()
        # status
        errors = {}
        is_valid = True
        
        # 1. Check for empty fields based on your entity models
        for col in REPOSITORY_MAP[self.entity_kind].get_columns():
            val = current_data.get(col, '')
            # defer empty string checking to field validation
            try:
                entity_model.validate_field(entity_model.FieldKind.from_internal_name(col), val, parent_repository)
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
                    REPOSITORY_MAP[self.entity_kind].check_duplicate_key(val)
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
            record = self.normalizeRecord(new_data)
            REPOSITORY_MAP[self.entity_kind].add_record(record)
            return {'success': True, 'message': 'Record added successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot('QVariantMap', 'QVariantMap', result = 'QVariantMap')
    def updateRecord(self, old_data, new_data):
        try:
            updates = self.normalizeRecord(new_data)
            primary_key = self.getPrimaryKey()
            old_key_value = str(old_data[primary_key])
            REPOSITORY_MAP[self.entity_kind].update_record(updates, key = old_key_value)
            return {'success': True, 'message': 'Changes saved successfully.'}
        except Exception as e:
            print(f'Error updating record: {e}')
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot('QVariantMap', result = 'QVariantMap')
    def deleteRecord(self, old_data):
        try:
            primary_key = self.getPrimaryKey()
            key_value = str(old_data[primary_key])
            REPOSITORY_MAP[self.entity_kind].delete_record(key = key_value)
            return {'success': True, 'message': 'Record deleted successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    # =========================================
    # CORE DATA LOGIC
    # =========================================
    def normalizeRecord(self, data):
        new_data = {}
        for k, v in data.items():
            if k == 'year':
                new_data[k] = v
            elif v is None or v == '':
                new_data[k] = None
            else:
                new_data[k] = str(v)
        for col in REPOSITORY_MAP[self.entity_kind].get_columns():
            if col not in data:
                new_data[col] = None
        return new_data

    def resetFilterOptions(self):
        self._filter_options = ['All Fields'] + [
            self.entity_kind
                .get_model()
                .get_fields()[column].display_name
            for column in REPOSITORY_MAP[self.entity_kind].get_columns()
        ]

    def refreshTable(self):
        # get columns
        columns = REPOSITORY_MAP[self.entity_kind].get_columns()
        
        # building a 'where' clause
        search_request = None
        if self._search_text:
            search_str = self._search_text.strip().lower()
            if self._search_filter_index == 0:
                search_request = Search(text = search_str, prefix_match = False)
            else:
                use_prefix_match = self.entity_kind == EntityKind.STUDENT and self._search_filter_index == 6
                search_request = Search(text = search_str, field = columns[self._search_filter_index - 1], prefix_match = use_prefix_match)

        # sorted and paged request
        paged_request = Paged.Specific(index = self._page_index + 1, size = self._page_size)
        sorted_request = Sorted.By(column = columns[self._sort_field_index] , ascending = self._sort_ascending)

        self._total_item_count = REPOSITORY_MAP[self.entity_kind].get_count(search = search_request)

        entries = REPOSITORY_MAP[self.entity_kind].get_records(
            search = search_request,
            sorted = sorted_request,
            paged = paged_request
        )

        self.table_model.resetModel(self.entity_kind, entries)

        self._visible_item_count = len(entries)

        self.paginationChanged.emit()