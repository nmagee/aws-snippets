from chalice import Chalice

app = Chalice(app_name='demo-api')


@app.route('/')
def index():
    return {'hello': 'world'}


@app.route('/hello/{name}')
def hello_name(name):
   # '/hello/james' -> {"hello": "james"}
   return {'hello': name}

@app.route('/users', methods=['POST'])
def create_user():
    # This is the JSON body the user sent in their POST request.
    user_as_json = app.current_request.json_body
    # We'll echo the json body back to the user in a 'user' key.
    return {'package': user_as_json}
