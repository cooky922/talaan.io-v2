from dataclasses import dataclass
from typing import Optional

@dataclass
class Sorted:
    column: str
    ascending: bool = True
    
    @staticmethod
    def By(column: str, ascending: bool = True) -> Sorted:
        return Sorted(column, ascending)

@dataclass
class Paged:
    size: int
    index: Optional[int] = None

    # Requests a list that yields specific page of 'size' records
    @staticmethod
    def Specific(index: int, size: int) -> Paged:
        return Paged(size = size, index = index)

    # Requests a generator that yields pages of 'size' records each
    @staticmethod
    def Stream(size: int) -> Paged:
        return Paged(size = size, index = None)
    
@dataclass
class Search:
    text : str
    field: Optional[str] = None
    prefix_match : bool = False