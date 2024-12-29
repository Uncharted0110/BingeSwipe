import requests
from pymongo import MongoClient

def search_track(song_name, access_token):
    search_url = "https://api.spotify.com/v1/search"
    headers = {"Authorization": f"Bearer {access_token}"}
    params = {
        "q": song_name,
        "type": "track",
        "limit": 1
    }

    response = requests.get(search_url, headers=headers, params=params)
    if response.status_code == 200:
        data = response.json()
        if data["tracks"]["items"]:
            track = data["tracks"]["items"][0]
            return track["id"], track["name"]
        else:
            return None, "No track found for the given name."
    else:
        return None, f"Error: {response.status_code}, {response.text}"

def get_track_details(track_id, access_token):
    track_url = f"https://api.spotify.com/v1/tracks/{track_id}"
    headers = {"Authorization": f"Bearer {access_token}"}

    track_response = requests.get(track_url, headers=headers)
    if track_response.status_code != 200:
        print(f"Failed to fetch track details: {track_response.status_code}")
        print(track_response.text)
        return None

    track_data = track_response.json()

    track_name = track_data['name']
    album_name = track_data['album']['name']
    release_date = track_data['album']['release_date']
    release_year = release_date.split('-')[0]
    image_url = track_data['album']['images'][0]['url'] if track_data['album']['images'] else None
    artists = [artist['name'] for artist in track_data['artists']]

    artist_id = track_data['artists'][0]['id']
    artist_url = f"https://api.spotify.com/v1/artists/{artist_id}"
    artist_response = requests.get(artist_url, headers=headers)
    if artist_response.status_code != 200:
        print(f"Failed to fetch artist details: {artist_response.status_code}")
        print(artist_response.text)
        genres = []
    else:
        genres = artist_response.json().get('genres', [])
        country = artist_response.json().get('country', 'Unknown')  # Using country as a placeholder for language
        language = country  # You can adjust this logic based on more detailed information

    # Capitalize the first letter of each genre
    top_genres = [genre.capitalize() for genre in genres[:3]]

    return {
        "song": track_name,
        "album": album_name,
        "r_year": release_year,
        "image_url": image_url,
        "artists": artists,
        "genre": top_genres,
    }


def store_to_mongodb(track_details, database_name="BingeSwipe", collection_name="Songs"):
    try:
        # Connect to MongoDB
        client = MongoClient("mongodb+srv://test:jGPHvTinjd27yWoO@cluster0.qpv0m.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
        db = client[database_name]
        collection = db[collection_name]

        # Check if the song already exists by its name
        existing_song = collection.find_one({"song": track_details["song"]})
        if existing_song:
            # If the song exists, print a message and do not add it
            print(f"Song '{track_details['song']}' already exists in the database. Skipping insertion.")
            return  # Exit the function without inserting the song

        # Determine the new song_id by incrementing the current number of entries
        next_song_id = collection.count_documents({}) + 1
        track_details["song_id"] = next_song_id

        # Insert the new track details
        collection.insert_one(track_details)
        print(f"Track details saved to MongoDB in '{database_name}.{collection_name}' with song_id: {next_song_id}")
    except Exception as e:
        print(f"Error storing to MongoDB: {e}")


# Example usage
access_token = "BQBLPbwE2rB0V9IM9eJJeGxxmeqyBVWNK50ADrZ1ZXu_sIXlO8fgQ2_i0MboHcjcWzFUbOQ9WosMa90Z708zTyPRSHv632onGQV9mp1fZ3gLTIMKEZ4"  # Replace with your access token
song_name = "bye bye bye"  # Replace with the song name you want to search for

track_id, message = search_track(song_name, access_token)
if track_id:
    print(f"Found Track: {message}")
    print(f"Track ID: {track_id}")

    track_details = get_track_details(track_id, access_token)
    if track_details:
        print("\nTrack Details:")
        print("Track Name:", track_details["song"])
        print("Album Name:", track_details["album"])
        print("Release Year:", track_details["r_year"])
        print("Image URL:", track_details["image_url"])
        print("Artists:", track_details["artists"])
        print("Top Genres:", track_details["genre"])

        # Store track details into MongoDB
        store_to_mongodb(track_details)
else:
    print(message)