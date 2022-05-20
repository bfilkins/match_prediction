

import requests

url = "https://api-football-v1.p.rapidapi.com/v3/odds"

querystring = {"league":"140","season":"2021","date":"2022-05-15"}

headers = {
	"X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
	"X-RapidAPI-Key": "c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24"
}

odds_response = requests.request("GET", url, headers=headers, params=querystring)

odds_data = pd.json_normalize(json.loads(odds_response.text)["response"])

print(response.text)
