from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from project.models import db, Questions, Score

quiz_bp = Blueprint("quiz", __name__)


@quiz_bp.route("/quiz/submit", methods=["POST"])
@jwt_required()
def submit_quiz():
    student_id = get_jwt_identity()
    data = request.get_json()

    # data should be a list of:
    # [{"question_id": 1, "answer": "A"}, ...]
    if not data:
        return jsonify({"message": "No answers provided"}), 400

    questions = Questions.query.all()
    total = len(questions)

    if total == 0:
        return jsonify({"message": "No questions in database"}), 400

    
    correct_answers = {q.id: q.answer for q in questions}

    score = 0
    for item in data:
        question_id = item.get("question_id")
        answer = item.get("answer", "").upper()
        if correct_answers.get(question_id) == answer:
            score += 1

    
    new_score = Score(
        student_id=student_id,
        score=score,
        total=total
    )
    db.session.add(new_score)
    db.session.commit()

    return jsonify({
        "status": "submitted",
        "score": score,
        "total": total,
        "percentage": round((score / total) * 100, 1),
        "result": "Passed" if score >= total * 0.5 else "Failed"
    }), 201



@quiz_bp.route("/quiz/scores", methods=["GET"])
@jwt_required()
def get_scores():
    scores = Score.query.order_by(Score.score.desc()).all()
    return jsonify({
        "count": len(scores),
        "data": [s.to_dict() for s in scores]
    }), 200



@quiz_bp.route("/quiz/my-scores", methods=["GET"])
@jwt_required()
def my_scores():
    student_id = get_jwt_identity()
    scores = Score.query.filter_by(student_id=student_id).all()
    return jsonify({
        "count": len(scores),
        "data": [s.to_dict() for s in scores]
    }), 200