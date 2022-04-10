
# Establish API Crententials, pull match level data and transform to tidy dataframe

# Define function for querying league data
def league_query(api_key):
  headers = {
    'x-rapidapi-host': "api-football-v1.p.rapidapi.com",
    'x-rapidapi-key': api_key
    }

  # Pull Leagues ####

  matches_url = "https://api-football-v1.p.rapidapi.com/v3/leagues"

  # define parameters
  #querystring = {"league":league, "season":year}

  response_leagues = requests.request("GET", matches_url, headers=headers)

  league_data = pd.json_normalize(json.loads(response_leagues.text)["response"])
  return league_data


# Define function for querying fixtures
def fixture_query(api_key, league, year):
  headers = {
    'x-rapidapi-host': "api-football-v1.p.rapidapi.com",
    'x-rapidapi-key': api_key
    }

  # Pull Matches (fixtures) ####

  matches_url = "https://api-football-v1.p.rapidapi.com/v3/fixtures"

  # define parameters
  querystring = {"league":league, "season":year}

  response_matches = requests.request("GET", matches_url, headers=headers, params=querystring)

  match_data = pd.json_normalize(json.loads(response_matches.text)["response"])
  return match_data



