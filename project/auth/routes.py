from flask import Blueprint,jsonify,request,redirect,url_for
from flask_jwt_extended import create_access_token
from project.models import db,Students

auth_bp = Blueprint("auth",__name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    if not data or not data.get("name") or not data.get("age") or not data.get("password"):
        return jsonify ({
            "status":"error",
            "msg":"incomplete data"
            }),400
    
    users = Students.query.filter_by(name=data["name"]).first()

    if users:
        return jsonify ({
            "status":"error",
            "msg":"user already registerd"
            }),400
    
    new_user = Students(name=data["name"],age=data["age"])
    new_user.set_password(data["password"])

    db.session.add(new_user)
    db.session.commit()


    return jsonify ({
        "status":"created",
        "Account created to":f"{new_user.to_dict()}"}), 201







@auth_bp.route("/login", methods=["POST"])
def login():
    
    data = request.get_json()
    if not data or not data.get("name") or not data.get("password"):
        return jsonify ({
            "status":"error",
            "msg":"Incomplete data"
            }),400
    
    user = Students.query.filter_by(name=data["name"]).first()

    if not user or not user.check_password(data["password"]):
        return jsonify ({
            "status":"error",
            "msg":"Incorrect data"
            }),400
    
    token = create_access_token(identity=str(user.id))


    return jsonify({
        "status": "success", 
        "token": token , 
        "user_id":user.id}), 200
    





