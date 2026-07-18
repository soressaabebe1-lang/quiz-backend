from flask import Blueprint,jsonify,request
from flask_jwt_extended import jwt_required,get_jwt_identity
from project.models import db,Questions

question_bp=Blueprint("question",__name__)

@question_bp.route("/question", methods=["GET"])
@jwt_required()
def get_questions():
    question_items=Questions.query.all()
    questions=[items.to_dict() for items in question_items]
    return jsonify({"data":questions}),200


@question_bp.route("/question", methods=["POST"])
@jwt_required()
def add_question():
    data= request.get_json()
    if not data or not data.get("question") or not data.get("A") or not data.get("B") or not data.get("C") or not data.get("D") or not data.get("answer"):
        return jsonify ({"message":"Incomplete data"}), 400
    
    existing_question = Questions.query.filter_by(question=data["question"]).first()

    if existing_question:
        return jsonify({"msg":"question already exists"}), 400
    
    new_questions = Questions(
        question=data["question"],
        A=data["A"],
        B=data["B"],
        C=data["C"],
        D=data["D"],
        answer=data["answer"])

    db.session.add(new_questions)
    db.session.commit()
    Id = get_jwt_identity()
    return jsonify ({"status":"created", "created by":Id, "message":"question is added"}),201


@question_bp.route("/question/<int:id>", methods=["DELETE"])
@jwt_required()
def delete_question(id):
    question = Questions.query.get(id)
    if not question:
        return jsonify({"message": "Question not found"}), 404
    db.session.delete(question)
    db.session.commit()
    return jsonify({"status": "deleted"}), 200

@question_bp.route("/question/<int:id>", methods=["GET"])
@jwt_required()
def get_question(id):
    question = Questions.query.get(id)
    if not question:
        return jsonify({"message": "Not found"}), 404
    return jsonify({"data": question.to_dict()}), 200