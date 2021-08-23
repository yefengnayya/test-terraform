import os
from flask import Flask, jsonify, request

app = Flask(__name__)
methods = ["GET", "POST", "PATCH", "DELETE"]


@app.route("/", methods=methods)
def hello_world():
    return f"Current commit is ${os.getenv('COMMIT_HASH', '(Hash not found)')}"


@app.route("/healthcheck", methods=methods)
def health():
    return "Healthy!"


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=os.getenv("PORT", 5050))
