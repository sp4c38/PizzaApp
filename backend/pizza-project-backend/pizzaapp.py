from flask import Flask, make_response, url_for

@app.route("/about/")
def get():
    app.logger.debug("Hello this is my debug message.")
    content = {"Hello": "World"}
    response = make_response(content)
    print(response)
    # import IPython;IPython.embed()
    return response

class PizzaApp(Flask):
    def run(self, host=None, port=None, debug=None, load_dotenv=True, **options):
        if not self.debug or os.getenv("WERKZEUG_RUN_MAIN") == "true":
             

app = PizzaApp()
app.run()