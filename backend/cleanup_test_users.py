
from dotenv import load_dotenv
load_dotenv()

from sqlalchemy.orm import Session
from core.database import SessionLocal
from models.user import User

def cleanup_test_users():
    db: Session = SessionLocal()
    emails = ["customer@example.com", "designer@example.com", "admin@example.com"]
    deleted = []
    for email in emails:
        user = db.query(User).filter(User.email == email).first()
        if user:
            db.delete(user)
            deleted.append(email)
    db.commit()
    db.close()
    print(f"Deleted users: {deleted}")

if __name__ == "__main__":
    cleanup_test_users()
