from PyQt6.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot # type: ignore
from src.database.database import SQLDatabase
from src.model.directories import StudentDirectory, ProgramDirectory, CollegeDirectory

class QMLDashboardController(QObject):
    # > signal emitted once all queries finish updating the state
    dataChanged = pyqtSignal()

    def __init__(self, parent = None):
        super().__init__(parent)
        
        self._total_students = 0
        self._total_programs = 0
        self._total_colleges = 0
        
        self._null_program_students = 0
        self._null_college_programs = 0
        
        self._students_by_gender_data = []
        self._students_by_year_data = []
        self._students_by_college_data = []
        
        self._top_programs_data = []
        self._least_popular_programs_data = []

    # ==========================================
    # PROPERTIES FOR QML (Grouped by Category)
    # ==========================================
    
    @pyqtProperty(int, notify = dataChanged)
    def totalStudents(self): return self._total_students

    @pyqtProperty(int, notify = dataChanged)
    def totalPrograms(self): return self._total_programs

    @pyqtProperty(int, notify = dataChanged)
    def totalColleges(self): return self._total_colleges

    @pyqtProperty(int, notify = dataChanged)
    def nullProgramStudents(self): return self._null_program_students

    @pyqtProperty(int, notify = dataChanged)
    def nullCollegePrograms(self): return self._null_college_programs

    @pyqtProperty('QVariantList', notify = dataChanged)
    def studentDistributionByGenderData(self): return self._students_by_gender_data

    @pyqtProperty('QVariantList', notify = dataChanged)
    def studentDistributionByYearData(self): return self._students_by_year_data

    @pyqtProperty('QVariantList', notify = dataChanged)
    def studentDistributionByCollegeData(self): return self._students_by_college_data

    @pyqtProperty('QVariantList', notify = dataChanged)
    def topProgramsData(self): return self._top_programs_data

    @pyqtProperty('QVariantList', notify = dataChanged)
    def leastPopularProgramsData(self): return self._least_popular_programs_data

    # ==========================================
    # DATA FETCHING LOGIC
    # ==========================================
    @pyqtSlot()
    def refreshData(self):        
        self._total_students = StudentDirectory.get_count()
        self._total_programs = ProgramDirectory.get_count()
        self._total_colleges = CollegeDirectory.get_count()

        null_students_query = "SELECT COUNT(*) FROM students WHERE program_code IS NULL OR program_code = ''"
        self._null_program_students = SQLDatabase.fetch_scalar(null_students_query) or 0
        
        null_programs_query = "SELECT COUNT(*) FROM programs WHERE college_code IS NULL OR college_code = ''"
        self._null_college_programs = SQLDatabase.fetch_scalar(null_programs_query) or 0
        
        # Gender Distribution
        gender_query = """
            SELECT gender as label, COUNT(*) as value 
            FROM students 
            WHERE gender IS NOT NULL AND gender != ''
            GROUP BY gender
        """
        self._students_by_gender_data = SQLDatabase.fetch_all(gender_query) or []

        # Year Level Distribution (Ordered 1st, 2nd, 3rd, 4th)
        year_query = """
            SELECT CONCAT('Year ', year) as label, COUNT(*) as value 
            FROM students 
            WHERE year IS NOT NULL 
            GROUP BY year 
            ORDER BY year ASC
        """
        self._students_by_year_data = SQLDatabase.fetch_all(year_query) or []

        # College Distribution (Requires JOIN to link Student -> Program -> College)
        college_dist_query = """
            SELECT p.college_code as label, COUNT(s.id) as value
            FROM students s
            JOIN programs p ON s.program_code = p.program_code
            WHERE p.college_code IS NOT NULL AND p.college_code != ''
            GROUP BY p.college_code
            ORDER BY value DESC
        """
        self._students_by_college_data = SQLDatabase.fetch_all(college_dist_query) or []
        
        # Top 10 Most Common Programs (DESCENDING)
        top_prog_query = """
            SELECT program_code as label, COUNT(*) as value 
            FROM students 
            WHERE program_code IS NOT NULL AND program_code != ''
            GROUP BY program_code 
            ORDER BY value DESC 
            LIMIT 10
        """
        self._top_programs_data = SQLDatabase.fetch_all(top_prog_query) or []

        # Top 10 Least Popular Programs (ASCENDING)
        least_prog_query = """
            SELECT program_code as label, COUNT(*) as value 
            FROM students 
            WHERE program_code IS NOT NULL AND program_code != ''
            GROUP BY program_code 
            ORDER BY value ASC 
            LIMIT 10
        """
        self._least_popular_programs_data = SQLDatabase.fetch_all(least_prog_query) or []

        # > notify changes to UI
        self.dataChanged.emit()