import uuid
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
import bcrypt
from firebase_admin import credentials, firestore
from datetime import datetime
from google.cloud import storage
from werkzeug.utils import secure_filename


app = Flask(__name__)
CORS(app)  # Enable CORS

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r'key_db.json')
firebase_admin.initialize_app(cred)
gcp_cred = r'key_bucket.json'

# Initialize Google Cloud Storage client
gcp_client = storage.Client.from_service_account_json(gcp_cred)
BUCKET_NAME = 'vlookup-bucket'
bucket = gcp_client.get_bucket(BUCKET_NAME)

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
    phone = data['phone']
    dob = data['dob']

    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    # Create user data dictionary with timestamps
    user_data = {
        'name': name,
        'email': email,
        'passwordHash': password_hash,
        'gender': gender,
        'phone': phone,
        'bio': '',
        'location': '',
        'image': 'assets/images/profile.jpg',  # Default profile image
        'dob': dob,
        'createdAt': datetime.now(),
        'updatedAt': datetime.now()
    }

    # Check if email is already in use
    user_ref = db.collection('Users').document(email)
    user_data_check = user_ref.get()
    if user_data_check.exists:
        return jsonify({'message': 'User already exists!'}), 409
    else:
        # Add user data to Firestore
        user_ref.set(user_data)
        return jsonify({'message': 'User created successfully!'}), 200


# update user details
@app.route('/update_user', methods=['PUT'])
def update_user():
    data = request.get_json()
    email = data['email']
    user_ref = db.collection('Users').document(email)

    if not user_ref.get().exists:
        return jsonify({'message': 'User does not exist!'}), 404

    update_data = {key: value for key, value in data.items() if key != 'email' and value is not None}
    update_data['updatedAt'] = datetime.now()

    user_ref.update(update_data)
    return jsonify({'message': 'User updated successfully!'}), 200



# API for login
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
            # Exclude sensitive keys when sending user data back to the client
            user_info = {key: val for key, val in user_data.items() if key not in ['passwordHash', 'createdAt', 'updatedAt', 'profileImage']}
            return jsonify({'message': 'Login successful!', 'user': user_info}), 200
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

    



#API for uploading user picture
@app.route('/upload_profile_pic/<email>', methods=['PUT'])
def upload_profile_pic(email):
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No file selected for uploading"}), 400
    
    filename = secure_filename(file.filename)
    unique_filename = str(uuid.uuid4()) + "_" + filename
    filepath = f'profile_pictures/{unique_filename}'
    
    try:
        bucket = gcp_client.get_bucket(BUCKET_NAME)
        blob = bucket.blob(filepath)
        blob.upload_from_file(file)
        
        
        # Update Firestore with the URL of the uploaded image
        user_ref = db.collection('Users').document(email)
        user_ref.update({'image': blob.public_url, 'updatedAt': datetime.now()})
        
        return jsonify({"message": "File uploaded successfully", "file_url": blob.public_url}), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500



    
#API for deleting profile picture 
@app.route('/delete_profile_pic/<email>', methods=['PUT'])
def delete_profile_pic(email):
    try:
        user_ref = db.collection('Users').document(email)
        user_data = user_ref.get()
        
        if user_data.exists:
            user_data = user_data.to_dict()
            profile_image_url = user_data.get('profileImage', '')
            
            if profile_image_url:
                file_path = profile_image_url.split(f"https://storage.googleapis.com/{BUCKET_NAME}/")[-1]
                
                bucket = gcp_client.get_bucket(BUCKET_NAME)
                blob = bucket.blob(file_path)
                blob.delete()
                
                user_ref.update({'profileImage': '', 'updatedAt': datetime.now()})
                
                return jsonify({'message': 'Profile image deleted successfully!'}), 200
            else:
                return jsonify({'message': 'Profile image not found!'}), 404
        else:
            return jsonify({'message': 'User does not exist!'}), 404
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500






    

#################### Events ####################


# Create an event
@app.route('/create_event', methods=['POST'])
def create_event():
    data = request.get_json()
    event_id = data.get('event_id')
    title = data.get('title')
    description = data.get('description')
    date = data.get('date')
    email = data.get('email')
    location = data.get('location')
    phone_number = data.get('phone_number')
    image = data.get('image', 'assets/images/default_event_image.jpg')  # Use default image if not provided

    # Create event data dictionary with timestamps
    event_data = {
        'event_id': event_id,
        'title': title,
        'description': description,
        'date': date,
        'email': email,
        'image': image,
        'location': location,
        'phone_number': phone_number,
        'createdAt': datetime.now(),
        'updatedAt': datetime.now()
    }

    # Check if the event with the same ID already exists to avoid duplication
    event_ref = db.collection('Events').document(event_id)
    if event_ref.get().exists:
        return jsonify({'message': 'Event already exists!'}), 409

    # Add event data to Firestore with provided event_id
    event_ref.set(event_data)

    return jsonify({'message': 'Event created successfully!', 'event_id': event_id}), 200








# Get all events and store in a list
@app.route('/get_events', methods=['GET'])
def get_events():
    events = []
    event_ref = db.collection('Events').get()
    
    for event in event_ref:
        event_data = event.to_dict()
        events.append(event_data)
    
    return jsonify(events), 200




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

# Update an event
@app.route('/update_event', methods=['PUT'])
def update_event():
    data = request.get_json()
    event_id = data.get('event_id')
    event_ref = db.collection('Events').document(event_id)

    if not event_ref.get().exists:
        return jsonify({'message': 'Event does not exist!'}), 404

    update_data = {key: value for key, value in data.items() if key != 'event_id' and value is not None}
    update_data['updatedAt'] = datetime.now()

    event_ref.update(update_data)
    return jsonify({'message': 'Event updated successfully!'}), 200



#Get all events created by a specific user
@app.route('/get_user_events/<email>', methods=['GET'])
def get_user_events(email):
    events = []
    event_ref = db.collection('Events').where('email', '==', email).get()
    
    for event in event_ref:
        event_data = event.to_dict()
        events.append(event_data)
    
    return jsonify(events), 200

# Delete event  
@app.route('/delete_event/<event_id>', methods=['DELETE'])
def delete_event(event_id):
    event_ref = db.collection('Events').document(event_id)
    event_ref.delete()
    
    return jsonify({'message': 'Event deleted successfully!'}), 200




#API for uploading event picture
@app.route('/upload_event_pic/<event_id>', methods=['POST'])
def upload_event_pic(event_id):
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No file selected for uploading"}), 400
    
    filename = secure_filename(file.filename)
    unique_filename = str(uuid.uuid4()) + "_" + filename
    filepath = f'events/{unique_filename}'
    
    try:
        bucket = gcp_client.get_bucket(BUCKET_NAME)
        blob = bucket.blob(filepath)
        blob.upload_from_file(file)
        
        
        # Update Firestore with the URL of the uploaded image
        event_ref = db.collection('Events').document(event_id)
        event_ref.update({'image': blob.public_url, 'updatedAt': datetime.now()})
        
        return jsonify({"message": "File uploaded successfully", "file_url": blob.public_url}), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500




#################### Volunteership ####################



# Join an event
@app.route('/join_event', methods=['POST'])
def join_event():
    # Create an Volunteership Collection
    data = request.get_json()
    email = data['email']
    event_id = data['event_id']

    volunteership_data = {
            'email': email,
            'event_id': event_id,
            'createdAt': datetime.now()
        }

    # Prevent joining the same event twice or joining an event you created
    volunteership_ref = db.collection('Volunteerships').where('email', '==', email).where('event_id', '==', event_id).get()
    event_ref = db.collection('Events').document(event_id).get().to_dict()

    if volunteership_ref:
        return jsonify({'message': 'You have already joined this event!'}), 409
    elif event_ref and event_ref['email'] == email:
        return jsonify({'message': 'You cannot volunteer for your own event!'}), 403
    else:
        db.collection('Volunteerships').add(volunteership_data)
        return jsonify({'message': 'You have successfully joined the event!'}), 200
    
    


# Get all volunteerships for a specific user
@app.route('/get_volunteerships/<email>', methods=['GET'])
def get_volunteerships(email):
    volunteerships = []
    volunteership_ref = db.collection('Volunteerships').where('email', '==', email).get()
    
    for volunteership in volunteership_ref:
        volunteership_data = volunteership.to_dict()
        volunteerships.append(volunteership_data)
    
    # Get details of the events the user has volunteered for and store it in a list
    event_data = []
    for volunteership in volunteerships:
        event_ref = db.collection('Events').document(volunteership['event_id'])
        event = event_ref.get().to_dict()
        event_data.append(event)
    
    return jsonify(event_data), 200

#Count the number of volunteers for a specific event
@app.route('/get_volunteer_count/<event_id>', methods=['GET'])
def get_volunteer_count(event_id):
    volunteership_ref = db.collection('Volunteerships').where('event_id', '==', event_id).get()
    volunteer_count = len(list(volunteership_ref))
    
    return jsonify({'volunteer_count': volunteer_count}), 200


# Leave an event
@app.route('/leave_event', methods=['DELETE'])
def leave_event():
    data = request.get_json()
    email = data['email']
    event_id = data['event_id']
    
    volunteership_ref = db.collection('Volunteerships').where('email', '==', email).where('event_id', '==', event_id).get()
    
    if volunteership_ref:
        for doc in volunteership_ref:
            doc.reference.delete()
        return jsonify({'message': 'Volunteership deleted successfully!'}), 200
    else:
        return jsonify({'message': 'Volunteership does not exist!'}), 404


if __name__ == '__main__':
    app.run(port=8080)  # Ensures the server is accessible on the network

