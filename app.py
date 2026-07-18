from project import create_app

app = create_app()

if __name__ == "__main__":
    # This block only runs when testing locally with `python app.py`.
    # On Render, gunicorn imports the `app` object above directly and
    # never executes this block.
    app.run(host="0.0.0.0", port=5000, debug=True)