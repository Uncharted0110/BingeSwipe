import yt_dlp
from pymongo import MongoClient

# Function to get the song URL from yt-dlp and update MongoDB
def get_song_url(song_name, artists, song_id):
    # Combine the song name with all artist names in the list
    artist_names = " ".join(artists)
    query = f"{song_name} {artist_names}"
    
    # Define the options for yt-dlp
    ydl_opts = {
        'format': 'bestaudio/best',  # Best audio format
        'extractaudio': True,        # Ensure only audio is extracted
        'audioformat': 'mp3',        # Save as MP3
        'noplaylist': True,          # Avoid downloading playlists
        'quiet': True,               # Silence the output except for the URL
        'force_generic_extractor': True,  # Force generic extractor for search
    }

    # Print the search query being used
    print(f"Searching for song: {song_name} by {', '.join(artists)}")

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        # Search for the song using the provided query
        try:
            result = ydl.extract_info(f"ytsearch:{query}", download=False)
            
            # Retrieve the URL of the top search result
            if 'entries' in result and len(result['entries']) > 0:
                top_result = result['entries'][0]
                song_url = top_result['url']  # Get the URL of the top search result
                print(f"Found the song MP3 URL: {song_url}")

                # Update the MongoDB document with the song_url
                songs_collection.update_one(
                    {'song_id': song_id},  # Find the song by its song_id
                    {'$set': {'song_url': song_url}}  # Set the song_url field
                )
                print(f"Updated song {song_name} with song_url in the database.")
            else:
                print(f"No results found for {song_name} by {', '.join(artists)}")
        except Exception as e:
            print(f"Error occurred while searching for {song_name} by {', '.join(artists)}: {e}")

# Connect to the MongoDB client and access the Songs collection
print("Connecting to MongoDB...")
client = MongoClient('mongodb+srv://test:jGPHvTinjd27yWoO@cluster0.qpv0m.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0')  # Replace with your MongoDB URI
db = client['BingeSwipe']  # Replace with your database name
songs_collection = db['Songs']  # Replace with your collection name

# Fetch the first 5 songs starting from song_id 1
print("Fetching songs from the database...")
songs_cursor = songs_collection.find({'song_id': {'$gte': 4}}).limit(5)

# Loop through each song and artist(s), then get the MP3 URL
for index, song_doc in enumerate(songs_cursor, start=1):
    print(f"\nProcessing song {index}...")
    song_name = song_doc.get('song')
    artists = song_doc.get('artists')
    song_id = song_doc.get('song_id')  # Get the song_id to update the correct song

    if song_name and artists:
        get_song_url(song_name, artists, song_id)
    else:
        print(f"Skipping song {index} due to missing data.")
