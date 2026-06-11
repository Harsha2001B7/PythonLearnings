from database import SessionLocal
from db_models import Course, Student


def seed_courses(db):
    existing = db.query(Course).count()
    if existing == 0:
        courses = [
            Course(name="Engineering",  description="Study of mathematics, science and technology"),
            Course(name="Medicine",     description="Study of human health, disease and treatment"),
            Course(name="Arts",         description="Study of humanities, literature and creative disciplines"),
            Course(name="Commerce",     description="Study of business, economics and finance"),
            Course(name="Science",      description="Study of natural sciences and research"),
        ]
        db.add_all(courses)
        db.commit()
        print("Seeded: 5 courses inserted.")
    else:
        print(f"Courses already exist ({existing} found), skipping.")


def seed_students(db):
    existing = db.query(Student).count()
    if existing == 0:
        students = [
            Student(name="Harsha Reddy",     roll_number=1001, course_id=1, year=2, gpa=8.5),
            Student(name="Priya Sharma",     roll_number=1002, course_id=2, year=1, gpa=9.1),
            Student(name="Arjun Nair",       roll_number=1003, course_id=1, year=3, gpa=7.8),
            Student(name="Sneha Patel",      roll_number=1004, course_id=3, year=2, gpa=8.0),
            Student(name="Rahul Verma",      roll_number=1005, course_id=4, year=4, gpa=7.2),
            Student(name="Divya Iyer",       roll_number=1006, course_id=5, year=1, gpa=9.4),
            Student(name="Kiran Kumar",      roll_number=1007, course_id=1, year=4, gpa=6.9),
            Student(name="Ananya Bose",      roll_number=1008, course_id=2, year=2, gpa=8.8),
            Student(name="Vikram Singh",     roll_number=1009, course_id=4, year=3, gpa=7.5),
            Student(name="Meena Joshi",      roll_number=1010, course_id=3, year=1, gpa=8.3),
            Student(name="Rohan Desai",      roll_number=1011, course_id=5, year=2, gpa=9.0),
            Student(name="Lakshmi Rao",      roll_number=1012, course_id=1, year=1, gpa=8.1),
            Student(name="Amit Gupta",       roll_number=1013, course_id=2, year=3, gpa=7.6),
            Student(name="Pooja Menon",      roll_number=1014, course_id=5, year=4, gpa=8.7),
            Student(name="Siddharth Pillai", roll_number=1015, course_id=3, year=3, gpa=7.9),
        ]
        db.add_all(students)
        db.commit()
        print("Seeded: 15 students inserted.")
    else:
        print(f"Students already exist ({existing} found), skipping.")


def run_seeds():
    db = SessionLocal()
    try:
        seed_courses(db) 
        seed_students(db)
    finally:
        db.close()