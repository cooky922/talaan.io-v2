from enum import Enum
from dataclasses import dataclass 

from src.model.errors import ValidationError, ValidationErrorKind

@dataclass
class FieldInfo:
    internal_name : str
    display_name : str
    underlying_type : type

class DirectoryKind(Enum):
    STUDENT = 'Student'
    PROGRAM = 'Program'
    COLLEGE = 'College'

    def get_entry_type(self):
        match self:
            case DirectoryKind.STUDENT:
                return StudentEntry
            case DirectoryKind.PROGRAM:
                return ProgramEntry
            case DirectoryKind.COLLEGE:
                return CollegeEntry

class GenderKind(Enum):
    MALE = 'Male'
    FEMALE = 'Female'
    OTHER = 'Other'

@dataclass
class StudentEntry:
    class FieldKind(Enum):
        ID = FieldInfo(internal_name = 'id', display_name = 'ID Number', underlying_type = int)
        FIRST_NAME = FieldInfo(internal_name = 'first_name', display_name = 'First Name', underlying_type = str)
        LAST_NAME = FieldInfo(internal_name = 'last_name', display_name = 'Last Name', underlying_type = str)
        PROGRAM_CODE = FieldInfo(internal_name = 'program_code', display_name = 'Program Code', underlying_type = str)
        YEAR = FieldInfo(internal_name = 'year', display_name = 'Year Level', underlying_type = int)
        GENDER = FieldInfo(internal_name = 'gender', display_name = 'Gender', underlying_type = GenderKind)

        @staticmethod
        def from_internal_name(name : str) -> StudentEntry.FieldKind:
            for field_kind in StudentEntry.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[StudentEntry.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in StudentEntry.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> StudentEntry.FieldKind:
        return StudentEntry.FieldKind.ID
    
    @staticmethod
    def validate_field(field : FieldKind, input : str | int, parent_directory = None):
        if field not in [StudentEntry.FieldKind.YEAR, StudentEntry.FieldKind.PROGRAM_CODE] and len(input) == 0:
            raise ValidationError(DirectoryKind.STUDENT, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field:
            case StudentEntry.FieldKind.ID:
                parts = input.split('-')
                if len(parts) != 2:
                    raise ValidationError(DirectoryKind.STUDENT, 
                                          StudentEntry.FieldKind.ID,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'ID Number must contain exactly one \'-\'')
                for part in parts:
                    if len(part) != 4:
                        raise ValidationError(DirectoryKind.STUDENT,
                                              StudentEntry.FieldKind.ID,
                                              ValidationErrorKind.INVALID_FORMAT,
                                              'ID Number must be in format 20XX-XXXX')
                    if not part.isdigit():
                        raise ValidationError(DirectoryKind.STUDENT,
                                              StudentEntry.FieldKind.ID,
                                              ValidationErrorKind.INVALID_FORMAT,
                                              'ID Number must be in digits')
                if not parts[0].startswith('20'):
                    raise ValidationError(DirectoryKind.STUDENT,
                                          StudentEntry.FieldKind.ID,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'ID Number must start with 20XX')

            case StudentEntry.FieldKind.FIRST_NAME:
                pass

            case StudentEntry.FieldKind.LAST_NAME:
                pass

            case StudentEntry.FieldKind.PROGRAM_CODE:
                if input not in [None, ''] and parent_directory is not None and not parent_directory.has_program_code(input):
                    raise ValidationError(DirectoryKind.STUDENT,
                                          StudentEntry.FieldKind.PROGRAM_CODE,
                                          ValidationErrorKind.FOREIGN_KEY_MISSING,
                                          'The given program code does not exist')

            case StudentEntry.FieldKind.YEAR:
                if not isinstance(input, int):
                    raise ValidationError(DirectoryKind.STUDENT,
                                          StudentEntry.FieldKind.YEAR,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The input is not a digit')
                if input < 1 or input > 4:
                    raise ValidationError(DirectoryKind.STUDENT,
                                          StudentEntry.FieldKind.YEAR,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The year must be from 1 to 4')
                
            case StudentEntry.FieldKind.GENDER:
                if input not in ['Male', 'Female', 'Other']:
                    raise ValidationError(DirectoryKind.STUDENT,
                                          StudentEntry.FieldKind.GENDER,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'Not a valid option')
                
    @staticmethod
    def validate_entry(entry : dict[str, str], requires_all = False, parent_directory = None):
        for field_kind in StudentEntry.FieldKind:
            if field_kind.value.internal_name not in entry:
                if requires_all:
                    raise ValidationError(DirectoryKind.STUDENT, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            StudentEntry.validate_field(field_kind, entry[field_kind.value.internal_name], parent_directory)

class ProgramEntry:
    class FieldKind(Enum):
        PROGRAM_CODE = FieldInfo(internal_name = 'program_code', display_name = 'Program Code', underlying_type = str)
        PROGRAM_NAME = FieldInfo(internal_name = 'program_name', display_name = 'Program Name', underlying_type = str)
        COLLEGE_CODE = FieldInfo(internal_name = 'college_code', display_name = 'College Code', underlying_type = str)

        @staticmethod
        def from_internal_name(name : str) -> ProgramEntry.FieldKind:
            for field_kind in ProgramEntry.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[ProgramEntry.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in ProgramEntry.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> ProgramEntry.FieldKind:
        return ProgramEntry.FieldKind.PROGRAM_CODE
    
    @staticmethod
    def validate_field(field : FieldKind, input : str, parent_directory = None):
        if field != ProgramEntry.FieldKind.COLLEGE_CODE and len(input) == 0:
            raise ValidationError(DirectoryKind.PROGRAM, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field:
            case ProgramEntry.FieldKind.PROGRAM_CODE:
                pass

            case ProgramEntry.FieldKind.PROGRAM_NAME:
                pass

            case ProgramEntry.FieldKind.COLLEGE_CODE:
                if input not in [None, ''] and parent_directory is not None and not parent_directory.has_college_code(input):
                    raise ValidationError(DirectoryKind.COLLEGE,
                                          ProgramEntry.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.FOREIGN_KEY_MISSING,
                                          'The given college code does not exist')
                
    @staticmethod
    def validate_entry(entry : dict[str, str], requires_all = False, parent_directory = None):
        for field_kind in ProgramEntry.FieldKind:
            if field_kind.value.internal_name not in entry:
                if requires_all:
                    raise ValidationError(DirectoryKind.PROGRAM, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            ProgramEntry.validate_field(field_kind, entry[field_kind.value.internal_name], parent_directory)

class CollegeEntry:
    class FieldKind(Enum):
        COLLEGE_CODE = FieldInfo(internal_name = 'college_code', display_name = 'College Code', underlying_type = str)
        COLLEGE_NAME = FieldInfo(internal_name = 'college_name', display_name = 'College Name', underlying_type = str)

        @staticmethod
        def from_internal_name(name : str) -> CollegeEntry.FieldKind:
            for field_kind in CollegeEntry.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[CollegeEntry.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in CollegeEntry.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> CollegeEntry.FieldKind:
        return CollegeEntry.FieldKind.COLLEGE_CODE
    
    @staticmethod
    def validate_field(field : FieldKind, input : str, parent_directory = None):
        if len(input) == 0:
            raise ValidationError(DirectoryKind.COLLEGE, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field: 
            case CollegeEntry.FieldKind.COLLEGE_CODE:
                # Must be in one word and all capitals
                if len(input.split()) != 1:
                    raise ValidationError(DirectoryKind.COLLEGE, 
                                          CollegeEntry.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The college code must contain exactly one word')
                if not input.isupper():
                    raise ValidationError(DirectoryKind.COLLEGE, 
                                          CollegeEntry.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The college code must be in uppercase')

            case CollegeEntry.FieldKind.COLLEGE_NAME:
                pass
    
    @staticmethod
    def validate_entry(entry : dict[str, str], requires_all = False, parent_directory = None):
        for field_kind in CollegeEntry.FieldKind:
            if field_kind.value.internal_name not in entry:
                if requires_all:
                    raise ValidationError(DirectoryKind.COLLEGE, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            CollegeEntry.validate_field(field_kind, entry[field_kind.value.internal_name])