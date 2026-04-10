from enum import Enum
from dataclasses import dataclass 

from src.model.errors import ValidationError, ValidationErrorKind

@dataclass
class FieldInfo:
    internal_name : str
    display_name : str
    underlying_type : type

class EntityKind(Enum):
    STUDENT = 'Student'
    PROGRAM = 'Program'
    COLLEGE = 'College'

    def get_model(self):
        match self:
            case EntityKind.STUDENT:
                return StudentModel
            case EntityKind.PROGRAM:
                return ProgramModel
            case EntityKind.COLLEGE:
                return CollegeModel
            
    def get_parent(self):
        match self:
            case EntityKind.STUDENT:
                return EntityKind.PROGRAM
            case EntityKind.PROGRAM:
                return EntityKind.COLLEGE
            case EntityKind.COLLEGE:
                return None

class GenderKind(Enum):
    MALE = 'Male'
    FEMALE = 'Female'
    OTHER = 'Other'

@dataclass
class StudentModel:
    class FieldKind(Enum):
        ID = FieldInfo(internal_name = 'id', display_name = 'ID Number', underlying_type = int)
        FIRST_NAME = FieldInfo(internal_name = 'first_name', display_name = 'First Name', underlying_type = str)
        LAST_NAME = FieldInfo(internal_name = 'last_name', display_name = 'Last Name', underlying_type = str)
        PROGRAM_CODE = FieldInfo(internal_name = 'program_code', display_name = 'Program Code', underlying_type = str)
        YEAR = FieldInfo(internal_name = 'year', display_name = 'Year Level', underlying_type = int)
        GENDER = FieldInfo(internal_name = 'gender', display_name = 'Gender', underlying_type = GenderKind)

        @staticmethod
        def from_internal_name(name : str) -> StudentModel.FieldKind:
            for field_kind in StudentModel.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[StudentModel.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in StudentModel.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> StudentModel.FieldKind:
        return StudentModel.FieldKind.ID
    
    @staticmethod
    def validate_field(field : FieldKind, input : str | int, parent_repository = None):
        if field not in [StudentModel.FieldKind.YEAR, StudentModel.FieldKind.PROGRAM_CODE] and (len(input) == 0 or input == "-"):
            raise ValidationError(EntityKind.STUDENT, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field:
            case StudentModel.FieldKind.ID:
                parts = input.split('-')
                if len(parts) != 2:
                    raise ValidationError(EntityKind.STUDENT, 
                                          StudentModel.FieldKind.ID,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'ID Number must contain exactly one \'-\'')
                for part in parts:
                    if len(part) != 4:
                        raise ValidationError(EntityKind.STUDENT,
                                              StudentModel.FieldKind.ID,
                                              ValidationErrorKind.INVALID_FORMAT,
                                              'ID Number must be in format 20YY-NNNN')
                    if not part.isdigit():
                        raise ValidationError(EntityKind.STUDENT,
                                              StudentModel.FieldKind.ID,
                                              ValidationErrorKind.INVALID_FORMAT,
                                              'ID Number must be in digits')
                if not parts[0].startswith('20'):
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.ID,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'ID Number must start with 20XX')

            case StudentModel.FieldKind.FIRST_NAME:
                if not str(input).replace(' ', '').isalpha():
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.FIRST_NAME,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'Alphabetic characters only')

            case StudentModel.FieldKind.LAST_NAME:
                if not str(input).replace(' ', '').isalpha():
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.LAST_NAME,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'Alphabetic characters only')

            case StudentModel.FieldKind.PROGRAM_CODE:
                if input not in [None, ''] and parent_repository is not None and not parent_repository.has_program_code(input):
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.PROGRAM_CODE,
                                          ValidationErrorKind.FOREIGN_KEY_MISSING,
                                          'The given program code does not exist')

            case StudentModel.FieldKind.YEAR:
                if not isinstance(input, int):
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.YEAR,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The input is not a digit')
                if input < 1 or input > 4:
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.YEAR,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The year must be from 1 to 4')
                
            case StudentModel.FieldKind.GENDER:
                if input not in ['Male', 'Female', 'Other']:
                    raise ValidationError(EntityKind.STUDENT,
                                          StudentModel.FieldKind.GENDER,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'Not a valid option')
                
    @staticmethod
    def validate_record(record : dict[str, str], requires_all = False, parent_repository = None):
        for field_kind in StudentModel.FieldKind:
            if field_kind.value.internal_name not in record:
                if requires_all:
                    raise ValidationError(EntityKind.STUDENT, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            StudentModel.validate_field(field_kind, record[field_kind.value.internal_name], parent_repository)

class ProgramModel:
    class FieldKind(Enum):
        PROGRAM_CODE = FieldInfo(internal_name = 'program_code', display_name = 'Program Code', underlying_type = str)
        PROGRAM_NAME = FieldInfo(internal_name = 'program_name', display_name = 'Program Name', underlying_type = str)
        COLLEGE_CODE = FieldInfo(internal_name = 'college_code', display_name = 'College Code', underlying_type = str)

        @staticmethod
        def from_internal_name(name : str) -> ProgramModel.FieldKind:
            for field_kind in ProgramModel.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[ProgramModel.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in ProgramModel.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> ProgramModel.FieldKind:
        return ProgramModel.FieldKind.PROGRAM_CODE
    
    @staticmethod
    def validate_field(field : FieldKind, input : str, parent_repository = None):
        if field != ProgramModel.FieldKind.COLLEGE_CODE and len(input) == 0:
            raise ValidationError(EntityKind.PROGRAM, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field:
            case ProgramModel.FieldKind.PROGRAM_CODE:
                pass

            case ProgramModel.FieldKind.PROGRAM_NAME:
                pass

            case ProgramModel.FieldKind.COLLEGE_CODE:
                if input not in [None, ''] and parent_repository is not None and not parent_repository.has_college_code(input):
                    raise ValidationError(EntityKind.COLLEGE,
                                          ProgramModel.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.FOREIGN_KEY_MISSING,
                                          'The given college code does not exist')
                
    @staticmethod
    def validate_record(record : dict[str, str], requires_all = False, parent_repository = None):
        for field_kind in ProgramModel.FieldKind:
            if field_kind.value.internal_name not in record:
                if requires_all:
                    raise ValidationError(EntityKind.PROGRAM, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            ProgramModel.validate_field(field_kind, record[field_kind.value.internal_name], parent_repository)

class CollegeModel:
    class FieldKind(Enum):
        COLLEGE_CODE = FieldInfo(internal_name = 'college_code', display_name = 'College Code', underlying_type = str)
        COLLEGE_NAME = FieldInfo(internal_name = 'college_name', display_name = 'College Name', underlying_type = str)

        @staticmethod
        def from_internal_name(name : str) -> CollegeModel.FieldKind:
            for field_kind in CollegeModel.FieldKind:
                if field_kind.value.internal_name == name:
                    return field_kind
            return None

    @staticmethod
    def get_fields() -> dict[CollegeModel.FieldKind, FieldInfo]:
        return {kind.value.internal_name : kind.value for kind in CollegeModel.FieldKind}
    
    @staticmethod
    def get_primary_key_field() -> CollegeModel.FieldKind:
        return CollegeModel.FieldKind.COLLEGE_CODE
    
    @staticmethod
    def validate_field(field : FieldKind, input : str, parent_repository = None):
        if len(input) == 0:
            raise ValidationError(EntityKind.COLLEGE, field,
                                  ValidationErrorKind.MISSING_FIELD,
                                  'This field cannot be empty')
        match field: 
            case CollegeModel.FieldKind.COLLEGE_CODE:
                if len(input.split()) != 1:
                    raise ValidationError(EntityKind.COLLEGE, 
                                          CollegeModel.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The college code must contain exactly one word')
                if not input.isupper():
                    raise ValidationError(EntityKind.COLLEGE, 
                                          CollegeModel.FieldKind.COLLEGE_CODE,
                                          ValidationErrorKind.INVALID_FORMAT,
                                          'The college code must be in uppercase')

            case CollegeModel.FieldKind.COLLEGE_NAME:
                pass
    
    @staticmethod
    def validate_record(record : dict[str, str], requires_all = False, parent_repository = None):
        for field_kind in CollegeModel.FieldKind:
            if field_kind.value.internal_name not in record:
                if requires_all:
                    raise ValidationError(EntityKind.COLLEGE, None,
                                          ValidationErrorKind.MISSING_FIELD,
                                          'The given input is missing some fields')
                else:
                    continue
            CollegeModel.validate_field(field_kind, record[field_kind.value.internal_name])