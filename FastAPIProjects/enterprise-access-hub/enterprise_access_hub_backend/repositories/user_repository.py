from models.user import User

def get_by_username(db, username):
    return db.query(User).filter(User.Username == username).first()

def get_by_email(db, email):
    return db.query(User).filter(User.Email == email).first()

def create_user(db, user):
    db.add(user)
    db.commit()
    db.refresh(user)
    return user