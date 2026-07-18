from functools import wraps
from flask import jsonify
from flask_jwt_extended import verify_jwt_in_request, get_jwt


def admin_required(fn):
    """Like @jwt_required(), but also checks the 'is_admin' claim embedded
    in the token at login time. Use this instead of @jwt_required() on any
    route that should be restricted to admin accounts only."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        claims = get_jwt()
        if not claims.get("is_admin"):
            return jsonify({"status": "error", "msg": "Admins only"}), 403
        return fn(*args, **kwargs)
    return wrapper
