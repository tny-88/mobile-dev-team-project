from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
import bcrypt
from firebase_admin import credentials, firestore
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r'private_key/jet-labs-firebase.json')
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()


############ Users ####################

# Create a user
@app.route('/create_user', methods=['POST'])
def create_user():
    data = request.get_json()
    name = data['name']
    email = data['email']
    password = data['passwordHash']
    gender = data['gender']
    
    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Create user data dictionary with timestamps
    user_data = {
        'name': name,
        'email': email,
        'passwordHash': password_hash,
        'gender': gender,
        'bio': '',
        'location': '',
        'profileImage': '',
        'createdAt': datetime.now(),
        'updatedAt': datetime.now()
    }
    
    # Add user data to Firestore
    db.collection('Users').document(email).set(user_data)
    

    
    return jsonify({'message': 'User created successfully!'}), 200


# Update bio and location information
@app.route('/add_details/<email>', methods=['PUT'])
def update_user(email):
    data = request.get_json()
    fields_to_update = {key: value for key, value in data.items() if key in ['bio', 'location', 'profileImage']}
    fields_to_update['updatedAt'] = datetime.now()

    # Update user data
    user_ref = db.collection('Users').document(email)
    user_ref.update(fields_to_update)
    
    return jsonify({'message': 'User updated successfully!'}), 200

#Login functionality 
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data['email']
    password = data['passwordHash']
    
    # Get user data from Firestore
    user_ref = db.collection('Users').document(email)
    user_data = user_ref.get()
    
    if user_data.exists:
        user_data = user_data.to_dict()
        if bcrypt.checkpw(password.encode('utf-8'), user_data['passwordHash'].encode('utf-8')):
            return jsonify({'message': 'Login successful!'}), 200
        else:
            return jsonify({'message': 'Invalid password!'}), 401
    else:
        return jsonify({'message': 'User does not exist!'}), 404
    
    
#Get all user details
@app.route('/get_user/<email>', methods=['GET'])
def get_user(email):
    user_ref = db.collection('Users').document(email)
    user_data = user_ref.get()
    
    if user_data.exists:
        user_data = user_data.to_dict()
        return jsonify(user_data), 200
    else:
        return jsonify({'message': 'User does not exist!'}), 404
    
#Delete user
@app.route('/delete_user/<email>', methods=['DELETE'])
def delete_user(email):
    user_ref = db.collection('Users').document(email)
    user_ref.delete()
    
    return jsonify({'message': 'User deleted successfully!'}), 200


#Change password
@app.route('/change_password/<email>', methods=['PUT'])
def change_password(email):
    data = request.get_json()
    old_password = data['oldPassword']
    new_password = data['newPassword']
    
    user_ref = db.collection('Users').document(email)
    user_data = user_ref.get().to_dict()
    
    if bcrypt.checkpw(old_password.encode('utf-8'), user_data['passwordHash'].encode('utf-8')):
        new_password_hash = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        user_ref.update({'passwordHash': new_password_hash})
        return jsonify({'message': 'Password changed successfully!'}), 200
    else:
        return jsonify({'message': 'Invalid password!'}), 401
    

############ Events ####################
# Create an event
@app.route('/create_event', methods=['POST'])
def create_event():
    data = request.get_json()
    title = data['title']
    description = data['description']
    date = data['date']
    email = data['email']
        
    # Create event data dictionary with timestamps
    event_data = {
        'title': title,
        'description': description,
        'date': date,
        'email': email,
        'image': '',
        'location': {'address': '', 'city': ''},
        'coordinates': {'latitude': '', 'longitude': ''},
        'createdAt': datetime.now(),
        'updatedAt': datetime.now()
    }
    
    # Add event data to Firestore with auto-generated ID
    event_ref = db.collection('Events').add(event_data)
    event_id = event_ref[1].id  # Get the generated document ID
    
    return jsonify({'message': 'Event created successfully!', 'event_id': event_id}), 200


# Update event details
@app.route('/update_event/<event_id>', methods=['PUT'])
def update_event(event_id):
    data = request.get_json()
    fields_to_update = {key: value for key, value in data.items() if key in ['title', 'description', 'date', 'image', 'location', 'coordinates']}
    fields_to_update['updatedAt'] = datetime.now()

    # Update event data
    event_ref = db.collection('Events').document(event_id)
    event_ref.update(fields_to_update)
    
    return jsonify({'message': 'Event updated successfully!'}), 200


# Get event details
@app.route('/get_event/<event_id>', methods=['GET'])
def get_event(event_id):
    event_ref = db.collection('Events').document(event_id)
    event_data = event_ref.get()
    
    if event_data.exists:
        event_data = event_data.to_dict()
        return jsonify(event_data), 200
    else:
        return jsonify({'message': 'Event does not exist!'}), 404


# Delete event  
@app.route('/delete_event/<event_id>', methods=['DELETE'])
def delete_event(event_id):
    event_ref = db.collection('Events').document(event_id)
    event_ref.delete()
    
    return jsonify({'message': 'Event deleted successfully!'}), 200

