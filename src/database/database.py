from pathlib import Path
from typing import Any, Optional
 
import mysql.connector
from mysql.connector import pooling
from dotenv import load_dotenv
import os

class SQLDatabase:
    _pool : Optional[pooling.MySQLConnectionPool] = None

    @classmethod
    def initialize(cls, pool_size : int = 5) -> None:
        load_dotenv(dotenv_path = Path(__file__).parent.parent.parent / '.env')
        # Run the SQL script first to create the database (if not exists) before pooling
        temp_connection = None
        temp_cursor = None
        port = int(os.getenv('DB_PORT').strip())
        user = os.getenv('DB_USER').strip()
        password = os.getenv('DB_PASSWORD').strip()
        host = os.getenv('DB_HOST').strip()
        db_name = os.getenv('DB_NAME').strip()
        try:
            temp_connection = mysql.connector.connect(
                host = host,
                user = user,
                password = password,
                port = port,
                use_pure = True
            )
            temp_cursor = temp_connection.cursor()
            sql_path = Path(__file__).parent / 'init_db.sql'
            with open(str(sql_path), 'r', encoding = 'utf-8') as f:
                sql_script = f.read()
            sql_commands = sql_script.split(';')
            for command in sql_commands:
                clean_command = command.strip()
                if clean_command:
                    temp_cursor.execute(clean_command)
            temp_connection.commit()
        except mysql.connector.Error as e:
            print(f'Error running SQL initialization script: {e}')
            raise e 
        finally:
            if temp_cursor is not None:
                temp_cursor.close()
            if temp_connection is not None and temp_connection.is_connected():
                temp_connection.close()
        # Now, create the connection pool
        try:
            cls._pool = pooling.MySQLConnectionPool(
                pool_name = 'talaan_pool',
                pool_size = pool_size,
                host = host,
                user = user,
                password = password,
                port = port,
                database = db_name,
                autocommit = False,
                use_pure = True
            )
        except Exception as e:
            print(f"Error creating connection pool: {e}")
            raise e
    
    @classmethod 
    def get_connection(cls) -> mysql.connector.MySQLConnection:
        if cls._pool is None:
            raise Exception('Connection pool not initialized. Call SQLDatabase.initialize() first.')
        return cls._pool.get_connection()
    
    # runs an 'INSERT', 'UPDATE', or 'DELETE' query and returns the number of affected rows
    @classmethod 
    def execute(cls, query: str, params: Optional[tuple] = None) -> int:
        connection = cls.get_connection()
        try:
            cursor = connection.cursor()
            cursor.execute(query, params)
            affected_rows = cursor.rowcount
            connection.commit()
            return affected_rows
        except Exception as e:
            connection.rollback()
            raise e
        finally:
            cursor.close()
            connection.close()

    # bulk 'INSERT', 'UPDATE', or 'DELETE' using executemany and returns the total number of affected rows
    @classmethod 
    def execute_many(cls, query: str, params_seq: list[tuple]) -> int:
        connection = cls.get_connection()
        try:
            cursor = connection.cursor()
            cursor.executemany(query, params_seq)
            affected_rows = cursor.rowcount
            connection.commit()
            return affected_rows
        except Exception as e:
            connection.rollback()
            raise e
        finally:
            cursor.close()
            connection.close()

    # runs a 'SELECT' query and returns the first row
    @classmethod
    def fetch_one(cls, query : str, params : tuple = ()) -> Optional[dict]:
        connection = cls.get_connection()
        try:
            cursor = connection.cursor(dictionary = True)
            cursor.execute(query, params)
            return cursor.fetchone()
        finally:
            cursor.close()
            connection.close()

    # runs a 'SELECT' query and returns all rows
    @classmethod
    def fetch_all(cls, query : str, params : tuple = ()) -> list[dict]:
        connection = cls.get_connection()
        try:
            cursor = connection.cursor(dictionary = True)
            cursor.execute(query, params)
            return cursor.fetchall()
        finally:
            cursor.close()
            connection.close()

    # returns a value from the 'SELECT' query result
    @classmethod
    def fetch_scalar(cls, query : str, params : tuple = ()) -> Any:
        row = cls.fetch_one(query, params)
        return next(iter(row.values())) if row else None