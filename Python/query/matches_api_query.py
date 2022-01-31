
# Establish API Crententials, pull match level data and transform to tidy dataframe

headers = {
    'x-rapidapi-host': "api-football-v1.p.rapidapi.com",
    'x-rapidapi-key': "c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24"
    }


# Pull Matches (fixtures)

matches_url = "https://api-football-v1.p.rapidapi.com/v3/fixtures"

laliga_querystring = {"league":"140","season":"2021"}

response_matches = requests.request("GET", matches_url, headers=headers, params=laliga_querystring)

matches_data = pd.json_normalize(json.loads(response_matches.text)["response"])

# Pull match statistics

match_stats_url = "https://api-football-v1.p.rapidapi.com/v3/fixtures"

laliga_querystring = {"league":"140","season":"2021"}

response_matches = requests.request("GET", matches_url, headers=headers, params=laliga_querystring)

matches_data = pd.json_normalize(json.loads(response_matches.text)["response"])

# Pull Standings ####
# 
# standings_url = "https://api-football-v1.p.rapidapi.com/v3/standings"
# 
# response_standings = requests.request("GET", standings_url, headers=headers, params=laliga_querystring)
# 
# data = json.load(response_standings)
# 
# print(data.decode("utf-8"))
# 
# 
# data = res.read()
#
# print(data.decode("utf-8"))


# standings_data_1 = pd.json_normalize(json.loads(response_standings.text)["response"])
# 
# standings_data_2 =  pd.json_normalize(standings_data_1.loc[0,'league.standings']).apply(pd.Series)
