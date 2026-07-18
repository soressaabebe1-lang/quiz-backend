from flask import Flask
from flask_jwt_extended import JWTManager
from project.models import db
import os


def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = "sqlite:///database.db"
    app.config['JWT_SECRET_KEY'] = os.environ.get("JWT_SECRET_KEY", "dev-key")
    app.json.sort_keys = False
    
    jwt=JWTManager(app)
    db.init_app(app)

    from project.users.routes import users_bp
    app.register_blueprint(users_bp)
    from project.auth.routes import auth_bp
    app.register_blueprint(auth_bp)
    from project.question.routes import question_bp
    app.register_blueprint(question_bp)
    from project.quiz.routes import quiz_bp
    app.register_blueprint(quiz_bp)


    with app.app_context():
            db.create_all()
            
            from project.models import Students
            admin_exists = Students.query.filter_by(is_admin=True).first()
            
            if not admin_exists:
                admin = Students(
                    username="soressa",
                    age=19,
                    is_admin=True
                )
                admin.set_password("211664")
                db.session.add(admin)
                db.session.commit()
                print("====== Live Admin Created Successfully! ======")

    return app