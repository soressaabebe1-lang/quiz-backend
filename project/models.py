from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash,check_password_hash

db = SQLAlchemy()

class Students(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    password_hash = db.Column(db.String(), nullable=False)

    def set_password(self,password):
        self.password_hash = generate_password_hash(password)

    def check_password(self,password):
        return check_password_hash(self.password_hash,password)

    def to_dict(self):
        return {
            "id":self.id,
            "name":self.name,
            "age":self.age
            }



class Questions(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    question = db.Column(db.String(), nullable=False)
    A = db.Column(db.String(), nullable=False)
    B = db.Column(db.String(), nullable=False)
    C = db.Column(db.String(), nullable=False)
    D = db.Column(db.String(), nullable=False)
    answer = db.Column(db.String(), nullable=False)

    def to_dict(self):
        return {
            "id":self.id,
            "Question": self.question,
            "A":self.A,
            "B":self.B,
            "C":self.C,
            "D":self.D,
            "Answer":self.answer
        }
    


class Score(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey("students.id"), nullable=False)
    score = db.Column(db.Integer, nullable=False)
    total = db.Column(db.Integer, nullable=False)
    date = db.Column(db.DateTime, default=db.func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "student_id": self.student_id,
            "score": self.score,
            "total": self.total,
            "date": str(self.date)
        }