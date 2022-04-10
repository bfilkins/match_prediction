
headers = {
    'x-rapidapi-host': "api-football-v1.p.rapidapi.com",
    'x-rapidapi-key': 
    }


odds_url = "https://api-football-v1.p.rapidapi.com/v3/odds"

# Query 2021 Laliga data
laliga_2021_querystring = {"league":"140", "season":"2021"}

laliga_2021_response_odds = requests.request("GET", odds_url, headers=headers, params=laliga_2021_querystring)

laliga_2021_odds_data = pd.json_normalize(json.loads(laliga_2021_response_odds.text)["response"])



