from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import sqlite3
import os
from datetime import datetime
import base64

app = Flask(__name__)
CORS(app)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Create uploads directory
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'lost_found'), exist_ok=True)
os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'complaints'), exist_ok=True)
os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'menu'), exist_ok=True)

# Database initialization
def init_db():
    conn = sqlite3.connect('hostel.db')
    c = conn.cursor()
    
    # Users table
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username TEXT UNIQUE NOT NULL,
                  password TEXT NOT NULL,
                  role TEXT NOT NULL,
                  name TEXT NOT NULL)''')
    
    # Lost and Found table
    c.execute('''CREATE TABLE IF NOT EXISTS lost_found
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_id INTEGER,
                  caption TEXT NOT NULL,
                  image_path TEXT NOT NULL,
                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                  FOREIGN KEY (user_id) REFERENCES users (id))''')
    
    # Complaints table
    c.execute('''CREATE TABLE IF NOT EXISTS complaints
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  user_id INTEGER,
                  caption TEXT NOT NULL,
                  image_path TEXT NOT NULL,
                  status TEXT DEFAULT 'pending',
                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                  FOREIGN KEY (user_id) REFERENCES users (id))''')
    
    # Menu table
    c.execute('''CREATE TABLE IF NOT EXISTS menu
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  image_path TEXT NOT NULL,
                  today_update TEXT,
                  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
    
    # Create default warden account
    try:
        hashed = generate_password_hash('warden123')
        c.execute("INSERT INTO users (username, password, role, name) VALUES (?, ?, ?, ?)",
                  ('warden', hashed, 'warden', 'Hostel Warden'))
    except sqlite3.IntegrityError:
        pass
    
    conn.commit()
    conn.close()

init_db()

# Helper function
def get_db():
    conn = sqlite3.connect('hostel.db')
    conn.row_factory = sqlite3.Row
    return conn

# Authentication endpoints
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    name = data.get('name')
    role = data.get('role', 'student')
    
    if not username or not password or not name:
        return jsonify({'error': 'Missing required fields'}), 400
    
    hashed = generate_password_hash(password)
    
    try:
        conn = get_db()
        c = conn.cursor()
        c.execute("INSERT INTO users (username, password, role, name) VALUES (?, ?, ?, ?)",
                  (username, hashed, role, name))
        conn.commit()
        user_id = c.lastrowid
        conn.close()
        
        return jsonify({
            'message': 'User registered successfully',
            'user': {
                'id': user_id,
                'username': username,
                'role': role,
                'name': name
            }
        }), 201
    except sqlite3.IntegrityError:
        return jsonify({'error': 'Username already exists'}), 409

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'error': 'Missing credentials'}), 400
    
    conn = get_db()
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE username = ?", (username,))
    user = c.fetchone()
    conn.close()
    
    if user and check_password_hash(user['password'], password):
        return jsonify({
            'message': 'Login successful',
            'user': {
                'id': user['id'],
                'username': user['username'],
                'role': user['role'],
                'name': user['name']
            }
        }), 200
    else:
        return jsonify({'error': 'Invalid credentials'}), 401

# Lost and Found endpoints
@app.route('/api/lost-found', methods=['POST'])
def create_lost_found():
    user_id = request.form.get('user_id')
    caption = request.form.get('caption')
    image = request.files.get('image')
    
    if not user_id or not caption or not image:
        return jsonify({'error': 'Missing required fields'}), 400
    
    filename = secure_filename(f"{datetime.now().timestamp()}_{image.filename}")
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'lost_found', filename)
    image.save(filepath)
    
    conn = get_db()
    c = conn.cursor()
    c.execute("INSERT INTO lost_found (user_id, caption, image_path) VALUES (?, ?, ?)",
              (user_id, caption, filepath))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Posted successfully'}), 201

@app.route('/api/lost-found', methods=['GET'])
def get_lost_found():
    conn = get_db()
    c = conn.cursor()
    c.execute("""SELECT lf.*, u.name as user_name 
                 FROM lost_found lf 
                 JOIN users u ON lf.user_id = u.id 
                 ORDER BY lf.created_at DESC""")
    items = c.fetchall()
    conn.close()
    
    result = []
    for item in items:
        with open(item['image_path'], 'rb') as f:
            image_data = base64.b64encode(f.read()).decode()
        
        result.append({
            'id': item['id'],
            'user_name': item['user_name'],
            'caption': item['caption'],
            'image': image_data,
            'created_at': item['created_at']
        })
    
    return jsonify(result), 200

# Complaints endpoints
@app.route('/api/complaints', methods=['POST'])
def create_complaint():
    user_id = request.form.get('user_id')
    caption = request.form.get('caption')
    image = request.files.get('image')
    
    if not user_id or not caption or not image:
        return jsonify({'error': 'Missing required fields'}), 400
    
    filename = secure_filename(f"{datetime.now().timestamp()}_{image.filename}")
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'complaints', filename)
    image.save(filepath)
    
    conn = get_db()
    c = conn.cursor()
    c.execute("INSERT INTO complaints (user_id, caption, image_path) VALUES (?, ?, ?)",
              (user_id, caption, filepath))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Complaint submitted successfully'}), 201

@app.route('/api/complaints', methods=['GET'])
def get_complaints():
    conn = get_db()
    c = conn.cursor()
    c.execute("""SELECT c.*, u.name as user_name, u.username 
                 FROM complaints c 
                 JOIN users u ON c.user_id = u.id 
                 ORDER BY c.created_at DESC""")
    items = c.fetchall()
    conn.close()
    
    result = []
    for item in items:
        with open(item['image_path'], 'rb') as f:
            image_data = base64.b64encode(f.read()).decode()
        
        result.append({
            'id': item['id'],
            'user_name': item['user_name'],
            'username': item['username'],
            'caption': item['caption'],
            'image': image_data,
            'status': item['status'],
            'created_at': item['created_at']
        })
    
    return jsonify(result), 200

# Menu endpoints
@app.route('/api/menu', methods=['POST'])
def update_menu():
    today_update = request.form.get('today_update', '')
    image = request.files.get('image')
    
    if not image:
        return jsonify({'error': 'Image is required'}), 400
    
    filename = secure_filename(f"menu_{datetime.now().timestamp()}_{image.filename}")
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], 'menu', filename)
    image.save(filepath)
    
    conn = get_db()
    c = conn.cursor()
    c.execute("INSERT INTO menu (image_path, today_update) VALUES (?, ?)",
              (filepath, today_update))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Menu updated successfully'}), 201

@app.route('/api/menu', methods=['GET'])
def get_menu():
    conn = get_db()
    c = conn.cursor()
    c.execute("SELECT * FROM menu ORDER BY updated_at DESC LIMIT 1")
    menu = c.fetchone()
    conn.close()
    
    if not menu:
        return jsonify({'message': 'No menu available'}), 404
    
    with open(menu['image_path'], 'rb') as f:
        image_data = base64.b64encode(f.read()).decode()
    
    return jsonify({
        'id': menu['id'],
        'image': image_data,
        'today_update': menu['today_update'],
        'updated_at': menu['updated_at']
    }), 200

@app.route('/api/menu/update-text', methods=['PUT'])
def update_menu_text():
    data = request.json
    today_update = data.get('today_update', '')
    
    conn = get_db()
    c = conn.cursor()
    c.execute("SELECT id FROM menu ORDER BY updated_at DESC LIMIT 1")
    menu = c.fetchone()
    
    if not menu:
        conn.close()
        return jsonify({'error': 'No menu exists'}), 404
    
    c.execute("UPDATE menu SET today_update = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
              (today_update, menu['id']))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'Today\'s update modified successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)