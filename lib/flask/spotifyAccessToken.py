import requests
import base64

def get_access_token(client_id, client_secret):
    # Spotify token URL
    token_url = "https://accounts.spotify.com/api/token"

    # Encode client_id and client_secret for Basic Authorization
    credentials = f"{client_id}:{client_secret}"
    encoded_credentials = base64.b64encode(credentials.encode()).decode()

    # Headers and data for the token request
    headers = {
        "Authorization": f"Basic {encoded_credentials}",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {
        "grant_type": "client_credentials"
    }

    # Request the token
    response = requests.post(token_url, headers=headers, data=data)
    if response.status_code == 200:
        token_data = response.json()
        return token_data["access_token"]
    else:
        print(f"Failed to get access token: {response.status_code}")
        print(response.text)
        return None

# Example usage
client_id = "bf8977abaa02442894437d8a292b1414"  # Replace with your Spotify app's client_id
client_secret = "019bcbd3fa834792bdd8ac54cbcb975b"  # Replace with your Spotify app's client_secret

access_token = get_access_token(client_id, client_secret)
if access_token:
    print("New Access Token:", access_token)
else:
    print("Failed to obtain a new access token.")
