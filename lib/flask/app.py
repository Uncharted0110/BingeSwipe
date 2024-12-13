from flask import Flask, jsonify, request
from flask_cors import CORS
from pymongo import MongoClient, errors
import logging
import json
from bson import ObjectId
import random

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
    Movie_collection = db['Movies']
    Genre_collection = db['Genre']
    Actor_collection = db['Actors']
    Playlist_collection = db["Playlist"]
except errors.ConnectionFailure as e:
    raise RuntimeError(f"Failed to connect to MongoDB: {e}")

@app.route('/moviesSwipe', methods=['GET'])
def get_movies():
    random_numbers = random.sample(range(1, 6), 3)

    try:
        movies = []

        for movie_id in random_numbers:
            movies += list(Movie_collection.find({"movie_id": movie_id}, {
                '"title"': 1, 
                '"description"': 1, 
                '"image_url"': 1,
                '_id': 0
            }))
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error retrieving movies: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/getAllMovies', methods=['GET'])
def getAll_movies():
    try:
        movies = list(Movie_collection.find({}, {
            '"title"': 1, 
            '"description"': 1, 
            '"image_url"' : 1,
            '"line"' : 1,
            '"r_year"' : 1,
            '"genre"' : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0
        }).limit(6))
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error retrieving movies: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/searchMovieByTitle', methods=['GET'])
def search_movie_by_title():
    title = request.args.get('title')  # Retrieve the title from query parameters
    
    if not title:
        return jsonify({'error': 'Title parameter is required'}), 400

    try:
        # Search for movies with a matching title (case-insensitive)
        movies = list(Movie_collection.find({'"title"' : {"$regex": title, "$options": "i"}}, {
            '"title"': 1, 
            '"description"': 1, 
            '"image_url"' : 1,
            '"line"' : 1,
            '"r_year"' : 1,
            '"genre"' : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0
        }))


        if not movies:
            return jsonify({'message': 'No movies found matching the title: ' + title}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by title: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/searchMovieByGenre', methods=['GET'])
def search_movie_by_genre():
    genre = request.args.get('genre')  # Retrieve the genre from query parameters
    
    if not genre:
        return jsonify({'error': 'Genre parameter is required'}), 400

    try:
        # Retrieve movie IDs that match the genre as a flat list
        movie_ids = [movie['movie_id'] for movie in Genre_collection.find({'genre': {"$regex": genre, "$options": "i"}},  {"movie_id": 1, '_id': 0})]


        movie_ids = [item for sublist in movie_ids for item in sublist]

        if not movie_ids:
            return jsonify({'message': f'No movies found matching the genre: {genre}'}), 404

        # Fetch detailed movie data for the retrieved IDs
        movies = list(Movie_collection.find({"movie_id": {"$in": movie_ids}}, {
            '"title"': 1, 
            '"description"': 1, 
            '"image_url"' : 1,
            '"line"' : 1,
            '"r_year"' : 1,
            '"genre"' : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0
        }))

        if not movies:
            return jsonify({'message': 'No movies retrieved for the genre'}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by genre: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/searchMovieByActor', methods=['GET'])
def search_movie_by_actor():
    actor = request.args.get('actor')  # Retrieve the genre from query parameters
    
    if not actor:
        return jsonify({'error': 'Actor parameter is required'}), 400

    try:
        # Retrieve movie IDs that match the genre as a flat list
        movie_ids = [movie['movie_ids'] for movie in Actor_collection.find({'name': {"$regex": actor, "$options": "i"}},  {"movie_ids": 1, '_id': 0})]


        movie_ids = [item for sublist in movie_ids for item in sublist]

        if not movie_ids:
            return jsonify({'message': f'No movies found matching the actor: {actor}'}), 404

        # Fetch detailed movie data for the retrieved IDs
        movies = list(Movie_collection.find({"movie_id": {"$in": movie_ids}}, {
            '"title"': 1, 
            '"description"': 1, 
            '"image_url"' : 1,
            '"line"' : 1,
            '"r_year"' : 1,
            '"genre"' : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0
        }))

        if not movies:
            return jsonify({'message': 'No movies retrieved for the actor'}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by genre: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/add_to_playlist', methods=['POST'])
def add_to_playlist():
    data = request.get_json()

    playlist_name = data['playlist_name']
    movie_id = int(data['movie_id'])

    if not playlist_name or not movie_id:
        return jsonify({'error': 'Invalid input'}), 400

    # Check if playlist exists
    playlist = Playlist_collection.find_one({"name": playlist_name})
    
    if not playlist:
        # If playlist doesn't exist, create a new one with the movie ID
        Playlist_collection.insert_one({
            "name": playlist_name,
            "movie_id": [movie_id]
        })
    else:
        # If playlist exists, add the movie ID to the list of movie IDs
        Playlist_collection.update_one(
            {"name": playlist_name},
            {"$push": {"movie_id": movie_id}}
        )

    return jsonify({"message": "Movie added to playlist"}), 200


@app.route('/get_playlists', methods=['GET'])
def get_playlists():
    playlists = list(Playlist_collection.find({}, {"name": 1, "_id": 0}))  # Modify based on your DB schema
    return jsonify([playlist for playlist in playlists])

@app.route('/get_playlist/<name>', methods=['GET'])
def get_playlist(name):
    # Query to find movies by name
    playlist = Playlist_collection.find({"name": name}, {"movie_id": 1, "_id": 0})
    
    # Convert cursor to list
    movie_ids = [movie['movie_id'] for movie in playlist]

    movie_ids = [item for sublist in movie_ids for item in sublist]

    # Fetch detailed movie data for the retrieved IDs
    movies = list(Movie_collection.find({"movie_id": {"$in": movie_ids}}, {
        '"title"': 1, 
        '"description"': 1, 
        '"image_url"' : 1,
        '_id': 0
    }))

    if not movies:
        return jsonify({'message': 'No movies retrieved for the actor'}), 404
        
    return jsonify(movies), 200

if __name__ == '__main__':
    app.run(debug=True)