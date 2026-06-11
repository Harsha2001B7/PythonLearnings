class StudentNotFoundException(Exception):
    def __init__(self, student_id):
        self.student_id = student_id
        super().__init__(f"Student with ID {student_id} not found.")

class DuplicateRollNumberException(Exception):
    def __init__(self, roll_number):
        self.roll_number = roll_number
        super().__init__(f"Student with roll number {roll_number} already exists.")