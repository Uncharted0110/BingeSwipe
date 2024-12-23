from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient('mongodb://localhost:27017/')
db = client['BingeSwipe']  # Replace with your actual database name
songs_collection = db['Songs']
artists_collection = db['artists']

# Fetch all songs with their artists
songs = list(songs_collection.find({}, {'song_id': 1, 'artists': 1, '_id': 0}))

# Dictionary to hold artist names and their associated song IDs
artist_songs = {}

# Loop through each song and its artists to populate the artist_songs dictionary
for song in songs:
    song_id = song['song_id']
    for artist in song['artists']:
        if artist not in artist_songs:
            artist_songs[artist] = []
        artist_songs[artist].append(song_id)

# Insert the artist-song mapping into the 'artists' collection
for artist, song_ids in artist_songs.items():
    artists_collection.update_one(
        {'artist_name': artist},  # Find the artist by name
        {'$set': {'song_ids': song_ids}},  # Update their song_ids
        upsert=True  # If artist doesn't exist, insert new document
    )

print("Artists collection updated successfully!")
