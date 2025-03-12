from flask import Flask, request, send_from_directory, jsonify
from flask_cors import CORS
import os

from model import classify_image

import google.generativeai as genai

api_key = "AIzaSyCYCkim3poZsB7po2ggAyJRFcMX6IBZoF0"

genai.configure(api_key=api_key)

model = genai.GenerativeModel("gemini-1.5-pro")


app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter frontend

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload_file():

    category = request.form.get("category")  # Get category value
    type_name = request.form.get("type") 
    
    print(category,type_name)

    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    file_path = os.path.join(UPLOAD_DIR, file.filename)
    file.save(file_path)

    diseaseName=(classify_image(file_path,category,type_name))

    return jsonify({"diseaseName": diseaseName}), 200

@app.route('/images/<filename>')
def get_image(filename):
    return send_from_directory(UPLOAD_DIR, filename)

@app.route('/chat', methods=['POST'])
def chat():

    

    data = request.get_json()
    user_message = data.get("message", "")
    disease_name=data.get('diseaseName',"apple_blotch")
    
    # Basic reply logic
    response = model.generate_content(user_message+f" for '{disease_name}' in one line")
    
    print(response.text)

    return jsonify({"reply": response.text})
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
