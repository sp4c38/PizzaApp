from flask import Flask, make_response, url_for

app = Flask("PizzaApp")

@app.route("/about/")
def get():
    app.logger.debug("Hello this is my debug message.")
    content = {"Hello": "World"}
    response = make_response(content)
    print(response)
    # import IPython;IPython.embed()
    return response

if __name__ == "__main__":
    app.run()
