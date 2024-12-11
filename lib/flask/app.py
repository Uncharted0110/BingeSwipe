from flask import Flask, jsonify, request
from flask_cors import CORS
from pymongo import MongoClient, errors
import logging
import json
from bson import ObjectId

class JSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, ObjectId):
            return str(obj)
        return super().default(obj)

app = Flask(__name__)
CORS(app)

try:
    client = MongoClient("mongodb+srv://test:jGPHvTinjd27yWoO@cluster0.qpv0m.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
    db = client['BingeSwipe']
    collection = db['Movies']
except errors.ConnectionFailure as e:
    raise RuntimeError(f"Failed to connect to MongoDB: {e}")

@app.route('/movies', methods=['GET'])
def get_movies():
    try:
        # Retrieve movies with only title and description
        movies = list(collection.find({}, {
            '"title"': 1, 
            '"description"': 1, 
            '"image_url"' : 1,
            '_id': 0
        }))
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error retrieving movies: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)