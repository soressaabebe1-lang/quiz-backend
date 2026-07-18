"""
One-off helper to make a student an admin.

Usage:
    python make_admin.py <username>

Run this AFTER that user has registered normally through POST /register.
This directly flips their is_admin flag in the database — there is
deliberately no API endpoint for this, since "become an admin" should never
be a public, self-service action.
"""
import sys
from project import create_app
from project.models import db, Students

def make_admin(username: str):
    app = create_app()
    with app.app_context():
        user = Students.query.filter_by(name=username).first()
        if not user:
            print(f"No user found with name '{username}'.")
            return
        user.is_admin = True
        db.session.commit()
        print(f"'{username}' (id={user.id}) is now an admin.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python make_admin.py <username>")
        sys.exit(1)
    make_admin(sys.argv[1])
