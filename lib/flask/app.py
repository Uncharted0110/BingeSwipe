from flask import Flask, jsonify, request
from flask_cors import CORS
from pymongo import MongoClient, errors
import logging
import json
from bson import ObjectId
import random
from werkzeug.security import generate_password_hash, check_password_hash
from pymongo.errors import DuplicateKeyError

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
    Genre_collection = db["MovieGenres"]
    Actor_collection = db['Actors']
    Playlist_collection = db["Playlist"]
    User_collection = db["Users"]
    Song_collection = db["Songs"]
    SongGenre_collection = db["SongGenres"]
    Artist_collection = db["Artists"]
    Album_collection = db["Albums"]
except errors.ConnectionFailure as e:
    raise RuntimeError(f"Failed to connect to MongoDB: {e}")

@app.route('/moviesSwipe', methods=['GET'])
def get_movies():
    random_numbers = random.sample(range(1, 23), 3)

    try:
        total_movies = Movie_collection.count_documents({})
        
        random_numbers = random.sample(range(1, total_movies + 1), 3)

        movies = []

        for movie_id in random_numbers:
            movies += list(Movie_collection.find({"movie_id": movie_id}, {
                "title": 1, 
                "description": 1, 
                "image_url": 1,
                "genre" : 1,
                '_id': 0
            }))
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error retrieving movies: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/songsSwipe', methods=['GET'])
def get_songs():
    total_songs = Song_collection.count_documents({})

    random_numbers = random.sample(range(1, total_songs + 1), 3)

    try:
        songs = []

        for song_id in random_numbers:
            songs += list(Song_collection.find({"song_id": song_id}, {
                "song": 1,
                "genre" : 1,  
                "image_url": 1,
                '_id': 0
            }))
        
        return jsonify(songs), 200
    except Exception as e:
        logging.error(f"Error retrieving songs: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/getAllMovies', methods=['GET'])
def getAll_movies():
    try:
        movies = list(Movie_collection.find({}, {
            "title": 1, 
            "description": 1, 
            "image_url" : 1,
            "line" : 1,
            "r_year" : 1,
            "genre" : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0,
            "language": 1,

        }).limit(6))
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error retrieving movies: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/getAllSongs', methods=['GET'])
def getAll_songs():
    try:
        songs = list(Song_collection.find({}, {
            "song": 1, 
            "artists": 1, 
            "image_url" : 1,
            "r_year" : 1,
            "genre" : 1,
            "song_id" : 1,
            '_id': 0,
            "album": 1,
            "song_url":1,

        }).limit(6))
        
        return jsonify(songs), 200
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
        movies = list(Movie_collection.find({"title" : {"$regex": title, "$options": "i"}}, {
            "title": 1, 
            "description": 1, 
            "image_url" : 1,
            "line" : 1,
            "r_year" : 1,
            "genre" : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0,
            "language": 1,
        }))


        if not movies:
            return jsonify({'message': 'No movies found matching the title: ' + title}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by title: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/searchSongByTrack', methods=['GET'])
def search_song_by_name():
    name = request.args.get('name')  # Retrieve the title from query parameters
    
    if not name:
        return jsonify({'error': 'Name parameter is required'}), 400

    try:
        # Search for movies with a matching title (case-insensitive)
        song = list(Song_collection.find({"song" : {"$regex": name, "$options": "i"}}, {
            "song": 1, 
            "artists": 1, 
            "image_url" : 1,
            "r_year" : 1,
            "genre" : 1,
            "song_id" : 1,
            '_id': 0,
            "album": 1,
            "song_url":1,
        }))


        if not song:
            return jsonify({'message': 'No song found matching the name: ' + name}), 404
        
        return jsonify(song), 200
    except Exception as e:
        logging.error(f"Error searching movies by name: {e}")
        return jsonify({'error': str(e)}), 500
    

@app.route('/searchSongByAlbum', methods=['GET'])
def search_song_by_album():
    album = request.args.get('album')  # Retrieve the album from query parameters

    if not album:
        return jsonify({'error': 'Album parameter is required'}), 400

    try:
        # Retrieve song IDs that match the album as a flat list
        song_ids = [song['song_ids'] for song in Album_collection.find({'name': {"$regex": album, "$options": "i"}},  {"song_ids": 1, '_id': 0})]

        song_ids = [item for sublist in song_ids for item in sublist]

        if not song_ids:
            return jsonify({'message': f'No song found for the album: {album}'}), 404

        # Fetch detailed song data for the retrieved IDs
        songs = list(Song_collection.find({"song_id": {"$in": song_ids}}, {
            "song": 1, 
            "artists": 1, 
            "image_url" : 1,
            "r_year" : 1,
            "genre" : 1,
            "song_id" : 1,
            '_id': 0,
            "album": 1,
            "song_url":1,
        }))

        if not songs:
            return jsonify({'message': 'No songs retrieved for the album'}), 404

        return jsonify(songs), 200
    except Exception as e:
        logging.error(f"Error searching song by album: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/searchMovieByGenre', methods=['GET'])
def search_movie_by_genre():
    genre = request.args.get('genre')  # Retrieve the genre from query parameters
    
    if not genre:
        return jsonify({'error': 'Genre parameter is required'}), 400

    try:
        # Retrieve movie IDs that match the genre as a flat list
        movie_ids = [movie['movie_ids'] for movie in Genre_collection.find({'genre': {"$regex": genre, "$options": "i"}},  {"movie_ids": 1, '_id': 0})]


        movie_ids = [item for sublist in movie_ids for item in sublist]

        if not movie_ids:
            return jsonify({'message': f'No movies found matching the genre: {genre}'}), 404

        # Fetch detailed movie data for the retrieved IDs
        movies = list(Movie_collection.find({"movie_id": {"$in": movie_ids}}, {
            "title": 1, 
            "description": 1, 
            "image_url" : 1,
            "line" : 1,
            "r_year" : 1,
            "genre" : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0,
            "language": 1,
        }))

        if not movies:
            return jsonify({'message': 'No movies retrieved for the genre'}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by genre: {e}")
        return jsonify({'error': str(e)}), 500
    
@app.route('/searchSongByGenre', methods=['GET'])
def search_song_by_genre():
    genre = request.args.get('genre')  # Retrieve the genre from query parameters
    
    if not genre:
        return jsonify({'error': 'Genre parameter is required'}), 400

    try:
        # Retrieve movie IDs that match the genre as a flat list
        song_ids = [song['song_ids'] for song in SongGenre_collection.find({'genre': {"$regex": genre, "$options": "i"}},  {"song_ids": 1, '_id': 0})]


        song_ids = [item for sublist in song_ids for item in sublist]

        if not song_ids:
            return jsonify({'message': f'No song found matching the genre: {genre}'}), 404

        # Fetch detailed movie data for the retrieved IDs
        song = list(Song_collection.find({"song_id": {"$in": song_ids}}, {
            "song": 1, 
            "artists": 1, 
            "image_url" : 1,
            "r_year" : 1,
            "genre" : 1,
            "song_id" : 1,
            '_id': 0,
            "album": 1,
            "song_url":1,
        }))

        if not song:
            return jsonify({'message': 'No song retrieved for the genre'}), 404
        
        return jsonify(song), 200
    except Exception as e:
        logging.error(f"Error searching song by genre: {e}")
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
            "title": 1, 
            "description": 1, 
            "image_url" : 1,
            "line" : 1,
            "r_year" : 1,
            "genre" : 1,
            "cast" : 1,
            "director" : 1,
            "movie_id" : 1,
            '_id': 0,
            "language": 1,
        }))

        if not movies:
            return jsonify({'message': 'No movies retrieved for the actor'}), 404
        
        return jsonify(movies), 200
    except Exception as e:
        logging.error(f"Error searching movies by actor: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/searchSongByArtist', methods=['GET'])
def search_song_by_artist():
    artist = request.args.get('artist')  # Retrieve the artist from query parameters

    if not artist:
        return jsonify({'error': 'Artist parameter is required'}), 400

    try:
        # Retrieve song IDs that match the artist as a flat list
        song_ids = [song['song_ids'] for song in Artist_collection.find({'name': {"$regex": artist, "$options": "i"}},  {"song_ids": 1, '_id': 0})]

        song_ids = [item for sublist in song_ids for item in sublist]

        if not song_ids:
            return jsonify({'message': f'No song found for the artist: {artist}'}), 404

        # Fetch detailed song data for the retrieved IDs
        songs = list(Song_collection.find({"song_id": {"$in": song_ids}}, {
            "song": 1, 
            "artists": 1, 
            "image_url" : 1,
            "r_year" : 1,
            "genre" : 1,
            "song_id" : 1,
            '_id': 0,
            "album": 1,
            "song_url":1,
        }))

        if not songs:
            return jsonify({'message': 'No songs retrieved for the artist'}), 404

        return jsonify(songs), 200
    except Exception as e:
        logging.error(f"Error searching song by artist: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/add_to_playlist', methods=['POST'])
def add_to_playlist():
    data = request.get_json()

    playlist_name = data['playlist_name']
    item_id = int(data['item_id'])
    item_type = data['item_type']  # "movie" or "song"

    if not playlist_name or not item_id or not item_type:
        return jsonify({'error': 'Invalid input'}), 400

    # Check if playlist exists
    playlist = Playlist_collection.find_one({"name": playlist_name})
    
    if not playlist:
        # If playlist doesn't exist, create a new one with the item ID and type
        Playlist_collection.insert_one({
            "name": playlist_name,
            "items": [{"item_id": item_id, "item_type": item_type}]
        })
    else:
        # If playlist exists, add the item ID and type to the list
        Playlist_collection.update_one(
            {"name": playlist_name},
            {"$push": {"items": {"item_id": item_id, "item_type": item_type}}}
        )

    return jsonify({"message": "Item added to playlist"}), 200


@app.route('/get_playlists', methods=['GET'])
def get_playlists():
    playlists = list(Playlist_collection.find({}, {"name": 1, "_id": 0}))  # Modify based on your DB schema
    return jsonify([playlist for playlist in playlists])


@app.route('/get_playlist/<name>', methods=['GET'])
def get_playlist(name):
    # Query to find playlist by name
    playlist = Playlist_collection.find_one({"name": name}, {"items": 1, "_id": 0})

    if not playlist:
        return jsonify({'message': 'Playlist not found'}), 404

    # Fetch detailed data for movies and songs
    movie_ids = [item['item_id'] for item in playlist['items'] if item['item_type'] == 'movie']
    song_ids = [item['item_id'] for item in playlist['items'] if item['item_type'] == 'song']

    # Fetch detailed movie data
    movies = list(Movie_collection.find({"movie_id": {"$in": movie_ids}}, {
        "title": 1, 
        "description": 1, 
        "image_url" : 1,
        '_id': 0
    }))

    # Fetch detailed song data (assuming you have a Song_collection)
    songs = list(Song_collection.find({"song_id": {"$in": song_ids}}, {
        "song": 1, 
        "artist": 1,
        "album": 1,
        "image_url": 1,
        '_id': 0
    }))

    # Combine movies and songs data into a single list
    playlist_data = movies + songs

    # Print only the song names to the terminal
    for song in songs:
        print("Song Name:", song.get("song", "No Name Available"))

    return jsonify(playlist_data), 200


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()  # Get JSON data from the request
    username = data.get('username')
    password = data.get('password')

    # Check if user exists in the database
    user = User_collection.find_one({"username": username})

    if user and check_password_hash(user['password'], password):
        return jsonify({"message": "Login successful!"}), 200
    else:
        return jsonify({"message": "Invalid username or password"}), 400

@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()  # Get JSON data from the request
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    # Check if the required fields are present
    if not username or not email or not password:
        return jsonify({"message": "All fields are required"}), 401

    # Validate password length (MongoDB schema already checks for this too)
    if len(password) < 8:
        return jsonify({"message": "Password must be at least 8 characters long"}), 402

    # Email pattern validation (You can use regex to validate email format)
    import re
    email_pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$'
    if not re.match(email_pattern, email):
        return jsonify({"message": "Invalid email format"}), 403

    # Check if the username or email already exists in the database
    if User_collection.find_one({"username": username}):
        return jsonify({"message": "Username already exists"}), 405
    if User_collection.find_one({"email": email}):
        return jsonify({"message": "Email already exists"}), 406

    # Hash the password
    hashed_password = generate_password_hash(password)

    try:
        # Insert new user into the database
        User_collection.insert_one({
            "username": username,
            "password": hashed_password,
            "email": email
        })
    except DuplicateKeyError as e:
        # Catch duplicate key errors if schema validation allows them
        error_message = str(e)
        if "username" in error_message:
            return jsonify({"message": "Username already exists"}), 405
        elif "email" in error_message:
            return jsonify({"message": "Email already exists"}), 406
        else:
            return jsonify({"message": "A duplicate key error occurred"}), 407

    return jsonify({"message": "Sign up successful!"}), 200

@app.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.get_json()  # Get JSON data from the request
    username = data.get('username')
    new_password = data.get('new_password')

    if not username or not new_password:
        return jsonify({"message": "Username and new password are required"}), 400

    # Check if the user exists in the database
    user = User_collection.find_one({"username": username})
    if not user:
        return jsonify({"message": "User not found"}), 404

    # Hash the new password
    hashed_password = generate_password_hash(new_password)

    # Update the user's password in the database
    User_collection.update_one(
        {"username": username},
        {"$set": {"password": hashed_password}}
    )

    return jsonify({"message": "Password reset successful!"}), 200

@app.route('/get_recommendation', methods=['POST'])
def get_recommendation():
    # Receive genre preferences from the client
    data = request.get_json()
    selected_category = data.get('category', 'Movies')
    genre_preferences = data.get('genres', [])

    # Select the appropriate collection based on category
    collection = db['Movies'] if selected_category == 'Movies' else db['Songs']

    # Different approach for Movies (array of genres) and Songs (array of genres)
    if selected_category == 'Movies':
        # For movies, check if any of the movie's genres match the preferences
        if genre_preferences:
            recommendations = list(collection.aggregate([
                {'$match': {'genre': {'$elemMatch': {'$in': genre_preferences}}}},
                {'$sample': {'size': 1}}
            ]))

            # If no recommendations found with genre match, do a broader search
            if not recommendations:
                recommendations = list(collection.aggregate([
                    {'$sample': {'size': 1}}
                ]))
        else:
            # If no genre preferences, return a random movie
            recommendations = list(collection.aggregate([
                {'$sample': {'size': 1}}
            ]))
    else:
        # For songs, check genre match in array
        if genre_preferences:
            recommendations = list(collection.aggregate([
                {'$match': {'genre': {'$elemMatch': {'$in': genre_preferences}}}},
                {'$sample': {'size': 1}}
            ]))

            # If no recommendations found with genre match, do a broader search
            if not recommendations:
                recommendations = list(collection.aggregate([
                    {'$sample': {'size': 1}}
                ]))
        else:
            # If no genre preferences, return a random song
            recommendations = list(collection.aggregate([
                {'$sample': {'size': 1}}
            ]))

    # If recommendations found, return the first one
    if recommendations:
        recommendation = recommendations[0]
        # Remove MongoDB's internal _id field
        recommendation.pop('_id', None)
        return jsonify(recommendation)

    # Fallback if no recommendations
    return jsonify({
        "title": "No Recommendations",
        "description": "Try swiping on more cards!",
        "image": "https://via.placeholder.com/300x200.png?text=No+Recommendation",
        "genre": "N/A"
    })

if __name__ == '__main__':
    app.run(debug=True)