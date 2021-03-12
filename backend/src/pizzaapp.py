from flask import Flask, url_for

app = Flask(__name__.split(".")[0])

@app.route("/about/")
def hello_world():
	return f"Hello, World!"