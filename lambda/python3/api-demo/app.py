from chalice import Chalice

app = Chalice(app_name='api-demo')

@app.route('/')
def index():
    return {'hey': 'there'}

@app.route('/hello/{name}')
def hello_name(name):
   # '/hello/james' -> {"hello": "james"}
   return {'hello': name}

@app.route('/users', methods=['POST'])
def create_user():
    # This is the JSON body the user sent in their POST request.
    user_as_json = app.current_request.json_body
    # We'll echo the json body back to the user in a 'user' key.
    # return {'user': user_as_json}
    fname = user_as_json['firstname']
    lname = user_as_json['lastname']
    return {'fullname': fname + ' ' + lname}