from flask import Blueprint,request,jsonify
from flask_jwt_extended import jwt_required
from project.models import db, Students, Score

users_bp = Blueprint("users",__name__)


@users_bp.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "success",
        "message": "Welcome to the Users API homepage"
    }), 200

@users_bp.route("/students/<int:user_id>", methods=["GET"])
@jwt_required()
def student_private_homepage(user_id):
    student = Students.query.filter_by(id=user_id).first()
    if not student:
        return jsonify({"Status": "error", "msg": "ID not found"}), 404

    scores_list = Score.query.filter_by(student_id=user_id).all()
    score = [item.to_dict() for item in scores_list]

    return jsonify({
        "Status": "success",
        "User_Info": student.to_dict(),
        "Score_Info": score
    })


@users_bp.route("/students", methods=["GET"])
@jwt_required()
def get_student():
    students_list = Students.query.all()


    students = [student.to_dict() for student in students_list]
    
    return jsonify ({
        "Status": "success",
        "data":students
        }), 200


@users_bp.route("/students/<int:data_id>", methods=["PUT"])
@jwt_required()
def update_student(data_id):
    data = request.get_json()

    if not data or "name" not in data:
        return jsonify ({
            "Status": "error",
            "msg": "Missing 'name'"
            }), 400
    
    data_list=Students.query.get(data_id)
    if not data_list:
        return jsonify ({
            "Status": "error",
            "msg":"ID not found"
            }), 404
    
    data_list.name = data.get("name", data_list.name)
    data_list.age = data.get("age", data_list.age)

    db.session.commit()
    return jsonify ({
        "status":"updated", 
        "data":data_list.to_dict()}), 200

@users_bp.route("/students/<int:data_id>", methods=["DELETE"])
@jwt_required()
def delete_student(data_id):
    data_list=Students.query.get(data_id)
    if not data_list:
        return jsonify ({
            "Status": "error",
            "msg":"ID not found"}), 404 
    

    db.session.delete(data_list)
    db.session.commit()

    return jsonify ({
        "states":"deleted", 
        "msg": f"Item {data_id} was successfully deleted"}), 200
