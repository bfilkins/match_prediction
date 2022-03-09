
# Establish API Crententials, pull match level data and transform to tidy dataframe

headers = {
    'x-rapidapi-host': "api-football-v1.p.rapidapi.com",
    'x-rapidapi-key': "c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24"
    }

# Pull Matches (fixtures) ####

matches_url = "https://api-football-v1.p.rapidapi.com/v3/fixtures"

# Query 2021 data
laliga_2021_querystring = {"league":"140", "season":"2021"}

laliga_2021_response_matches = requests.request("GET", matches_url, headers=headers, params=laliga_2021_querystring)

laliga_2021_match_data = pd.json_normalize(json.loads(laliga_2021_response_matches.text)["response"])

# Query 2020 data
laliga_2020_querystring = {"league":"140", "season":"2020"}

laliga_2020_response_matches = requests.request("GET", matches_url, headers=headers, params=laliga_2020_querystring)

laliga_2020_match_data = pd.json_normalize(json.loads(laliga_2020_response_matches.text)["response"])

# Query 2019 data
laliga_2019_querystring = {"league":"140", "season":"2019"}

laliga_2019_response_matches = requests.request("GET", matches_url, headers=headers, params=laliga_2019_querystring)

laliga_2019_match_data = pd.json_normalize(json.loads(laliga_2019_response_matches.text)["response"])

# Combine datasets
laliga_match_data = pd.concat([laliga_2021_match_data, laliga_2020_match_data, laliga_2019_match_data])

