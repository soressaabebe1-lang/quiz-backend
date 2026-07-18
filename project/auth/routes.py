from flask import Blueprint,jsonify,request,redirect,url_for
from flask_jwt_extended import create_access_token
from project.models import db,Students
import os

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
    
    token = create_access_token(
        identity=str(user.id),
        additional_claims={"is_admin": user.is_admin}
    )


    return jsonify({
        "status": "success", 
        "token": token , 
        "user_id":user.id,
        "is_admin":user.is_admin}), 200


@auth_bp.route("/admin/promote", methods=["POST"])
def promote_to_admin():
    """
    Promotes an existing user to admin. Protected by a shared secret
    (ADMIN_SETUP_KEY) set as an environment variable on Render, since the
    free tier doesn't offer shell access to run make_admin.py directly.

    Usage (e.g. from Thunder Client, pointed at your Render URL):
        POST /admin/promote
        Header: X-Admin-Setup-Key: <the secret you set on Render>
        Body:   {"name": "the_username"}

    IMPORTANT: set ADMIN_SETUP_KEY in Render's dashboard under
    Environment, NOT in your code or git repo. Anyone who knows this
    secret can promote any user to admin.
    """
    setup_key = os.environ.get("ADMIN_SETUP_KEY")
    provided_key = request.headers.get("X-Admin-Setup-Key")

    if not setup_key or not provided_key or provided_key != setup_key:
        return jsonify({"status": "error", "msg": "Unauthorized"}), 403

    data = request.get_json()
    if not data or not data.get("name"):
        return jsonify({"status": "error", "msg": "Missing 'name'"}), 400

    user = Students.query.filter_by(name=data["name"]).first()
    if not user:
        return jsonify({"status": "error", "msg": "User not found"}), 404

    user.is_admin = True
    db.session.commit()

    return jsonify({
        "status": "success",
        "msg": f"'{user.name}' is now an admin"
    }), 200
    





