from pathlib import Path
from typing import Union, Optional, Iterator, List
import csv

from src.database import SQLDatabase, Sorted, Paged, Search
from src.model.errors import DatabaseError, DatabaseErrorKind
from src.model.entity_models import *

# Base repository
class BaseRepository:

    # subclasses declare the following:
    TABLE: str = ''
    PRIMARY_KEY: str = ''
    KIND: EntityKind = None
    PARENT_KIND: Optional[EntityKind] = None

    @classmethod
    def get_kind(cls) -> EntityKind:
        return cls.KIND
    
    @classmethod
    def get_parent_kind(cls) -> Optional[EntityKind]:
        return cls.PARENT_KIND
    
    @classmethod
    def get_primary_key(cls) -> str:
        return cls.PRIMARY_KEY
    
    @classmethod
    def get_columns(cls) -> List[str]:
        return list(cls.KIND.get_model().get_fields().keys())
    
    # deprecated
    @classmethod
    def get_keys(cls) -> List[str]:
        rows = SQLDatabase.fetch_all(f'SELECT {cls.PRIMARY_KEY} FROM {cls.TABLE}')
        return [str(row[cls.PRIMARY_KEY]) for row in rows]

    @classmethod
    def get_key_values(cls) -> List[str]:
        return cls.get_keys()
    
    # deprecated
    @classmethod
    def has_key(cls, key: str) -> bool:
        count = SQLDatabase.fetch_scalar(f'SELECT COUNT(*) FROM {cls.TABLE} where {cls.PRIMARY_KEY} = %s', (key,))
        return (count or 0) > 0
    
    @classmethod
    def has_key_value(cls, key: str) -> bool:
        return cls.has_key(key)
    
    @classmethod
    def _build_where_clause(cls, search : Optional[Search]) -> tuple[str, list]:
        if search is None or search.text is None:
            return '', []
        text = search.text.strip()
        if search.field is not None:
            pattern = f'{text}%' if search.prefix_match else f'%{text}%'
            return f'WHERE {search.field} LIKE %s', [pattern]
        else:
            columns = cls.get_columns()
            like_subclauses = [f'{column} LIKE %s' for column in columns]
            params = [f'%{text}%'] * len(columns)
            return f'WHERE {" OR ".join(like_subclauses)}', params

    @classmethod
    def get_count(cls, search: Optional[Search] = None) -> int:
        where_clause, params = cls._build_where_clause(search)
        query = f'SELECT COUNT(*) FROM {cls.TABLE} {where_clause}'
        return SQLDatabase.fetch_scalar(query, tuple(params)) or 0

    @classmethod
    def get_records(cls, search: Optional[Search] = None, sorted: Optional[Sorted] = None, paged: Optional[Paged] = None) -> Union[List[dict], Iterator[List[dict]]]:
        where_clause, params = cls._build_where_clause(search)
        order_clause = f'ORDER BY {sorted.column} {"ASC" if sorted.ascending else "DESC"}' if sorted is not None else ''
        limit_clause = f'LIMIT %s OFFSET %s' if paged and paged.index is not None else ''
        query = f'SELECT * FROM {cls.TABLE} {where_clause} {order_clause} {limit_clause}'
        if paged is not None and paged.index is not None:
            params.extend([paged.size, (paged.index - 1) * paged.size])
            return SQLDatabase.fetch_all(query, tuple(params))
        elif paged is not None:
            def generator():
                offset = 0
                while True:
                    batch_params = params + [paged.size, offset]
                    batch_query = f'SELECT * FROM {cls.TABLE} {where_clause} {order_clause} LIMIT %s OFFSET %s'
                    batch = SQLDatabase.fetch_all(batch_query, tuple(batch_params))
                    if not batch:
                        break
                    yield batch
                    offset += paged.size
            return generator()
        else:
            return SQLDatabase.fetch_all(query, tuple(params))
        
    @classmethod
    def get_record(cls, key: str) -> Optional[dict]:
        query = f'SELECT * FROM {cls.TABLE} WHERE {cls.PRIMARY_KEY} = %s'
        return SQLDatabase.fetch_one(query, (key,))
    
    @classmethod
    def check_record_exists(cls, key: str) -> None:
        if not cls.has_key(key):
            raise DatabaseError(DatabaseErrorKind.NO_KEY, f'A record with key \'{key}\' does not exist in {cls.TABLE}')
    
    @classmethod
    def check_duplicate_key(cls, key: str) -> None:
        if cls.has_key(key):
            raise DatabaseError(DatabaseErrorKind.DUPLICATE_KEY, f'The key \'{key}\' already exists in {cls.TABLE}')
        
    @classmethod
    def add_record(cls, record: dict[str, Union[str, int, None]], requires_checking: bool = True) -> int:
        if requires_checking:
            cls.check_duplicate_key(str(record[cls.PRIMARY_KEY]))
            cls.KIND.get_model().validate_record(record, requires_all = True, parent_repository = REPOSITORY_MAP.get(cls.PARENT_KIND))
        columns = ', '.join(record.keys())
        placeholders = ', '.join(['%s'] * len(record))
        query = f'INSERT INTO {cls.TABLE} ({columns}) VALUES ({placeholders})'
        return SQLDatabase.execute(query, tuple(record.values()))

    @classmethod
    def update_record(cls, updates: dict[str, Union[str, int, None]], key : str, requires_checking: bool = True) -> int:
        if requires_checking:
            cls.check_record_exists(key)
            cls.KIND.get_model().validate_record(updates, requires_all = False, parent_repository = REPOSITORY_MAP.get(cls.PARENT_KIND))
        set_clause = ', '.join([f'{column} = %s' for column in updates.keys()])
        query = f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PRIMARY_KEY} = %s'
        params = list(updates.values()) + [key]
        return SQLDatabase.execute(query, tuple(params))
    
    @classmethod
    def update_records(cls, keys : list[str], updates: dict[str, Union[str, int, None]], requires_checking: bool = True) -> int:
        if requires_checking:
            for key in keys:
                cls.check_record_exists(key)
            cls.KIND.get_model().validate_record(updates, requires_all = False, parent_repository = REPOSITORY_MAP.get(cls.PARENT_KIND))
        set_clause = ', '.join([f'{column} = %s' for column in updates.keys()])
        placeholders = ', '.join(['%s'] * len(keys))
        query = f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PRIMARY_KEY} IN ({placeholders})'
        params = list(updates.values()) + keys
        return SQLDatabase.execute(query, tuple(params))

    @classmethod
    def delete_record(cls, key: str, requires_checking: bool = True) -> int:
        if requires_checking:
            cls.check_record_exists(key)
        query = f'DELETE FROM {cls.TABLE} WHERE {cls.PRIMARY_KEY} = %s'
        return SQLDatabase.execute(query, (key,))

    @classmethod
    def delete_records(cls, keys : list[str]) -> int:
        if not keys:
            return 0
        placeholders = ', '.join(['%s'] * len(keys))
        query = f'DELETE FROM {cls.TABLE} WHERE {cls.PRIMARY_KEY} IN ({placeholders})'
        return SQLDatabase.execute(query, tuple(keys))

    @classmethod
    def import_from_csv(cls, file_path: Path) -> int:
        # bulk insert records from a CSV file using MYSQL
        if not file_path.exists():
            raise FileNotFoundError(f'File \'{file_path}\' does not exist')
        
        with open(str(file_path), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            columns = cls.get_columns()
            placeholders = ', '.join(['%s'] * len(columns))
            col_str = ', '.join(columns)
            # ignore duplicate keys since we want to allow re-importing the same file for updates, but we will still validate the total_item_count
            query = f'INSERT IGNORE INTO {cls.TABLE} ({col_str}) VALUES ({placeholders})'
            
            params_seq = []
            for row in reader:
                clean_row = []
                for col in columns:
                    val = row.get(col, '').strip()
                    if val == '':
                        clean_row.append(None)
                    else:
                        clean_row.append(val)
                params_seq.append(tuple(clean_row))

            return SQLDatabase.execute_many(query, params_seq)

    
    @classmethod
    def export_to_csv(cls, file_path: Path) -> bool:
        records = cls.get_records()
        if not records: 
            return False
        try:
            with open(str(file_path), mode = 'w', newline = '', encoding = 'utf-8') as f:
                writer = csv.DictWriter(f, fieldnames = cls.get_columns())         
                writer.writeheader()
                clean_data = []
                for row in records:
                    clean_row = {k: (v if v is not None else '') for k, v in row.items()}
                    clean_data.append(clean_row)
                writer.writerows(clean_data)
            return True
        except Exception as e:
            return False
    
class StudentRepository(BaseRepository):
    TABLE = 'students'
    PRIMARY_KEY = 'id'
    KIND = EntityKind.STUDENT
    PARENT_KIND = EntityKind.PROGRAM

    @classmethod
    def get_ids(cls) -> List[str]:
        return cls.get_keys()
    
    @classmethod
    def has_id(cls, key: str) -> bool:
        return cls.has_key(key)

class ProgramRepository(BaseRepository):
    TABLE = 'programs'
    PRIMARY_KEY = 'program_code'
    KIND = EntityKind.PROGRAM
    PARENT_KIND = EntityKind.COLLEGE

    @classmethod
    def get_program_codes(cls) -> List[str]:
        return cls.get_keys()
    
    @classmethod
    def has_program_code(cls, key: str) -> bool:
        return cls.has_key(key)

class CollegeRepository(BaseRepository):
    TABLE = 'colleges'
    PRIMARY_KEY = 'college_code'
    KIND = EntityKind.COLLEGE
    PARENT_KIND = None

    @classmethod
    def get_college_codes(cls) -> List[str]:
        return cls.get_keys()
    
    @classmethod
    def has_college_code(cls, key: str) -> bool:
        return cls.has_key(key)

# repository_map
REPOSITORY_MAP = {
    EntityKind.STUDENT: StudentRepository,
    EntityKind.PROGRAM: ProgramRepository,
    EntityKind.COLLEGE: CollegeRepository,
}