# Query standings data and transform to dataframe ####

url <- "https://api-football-v1.p.rapidapi.com/v3/standings"

queryString <- list(
  season = "2021",
  league = "140"
)

response <- VERB(
  "GET", 
  url, 
  add_headers(
    'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
    'x-rapidapi-key' = 'c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24'
    ), 
  query = queryString
  )

standings_raw <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

standings_data <- standings_raw$response$league$standings %>%
  pluck(data.frame)

# Match Statistics
match_stats_url <- "https://api-football-v1.p.rapidapi.com/v3/fixtures/statistics"

match_stats_queryString <- list(fixture = "215662")

match_stats_response <- VERB(
  "GET",
  match_stats_url,
  query = match_stats_queryString, 
  add_headers(
    'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
    'x-rapidapi-key' = 'c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24'
    )
  )

match_stats_raw <- jsonlite::fromJSON(httr::content(match_stats_response, as = "text", encoding = "UTF-8"))

match_stats_data <- match_stats_raw$response$team %>%
  pluck(data.frame)

# Query Match Data and Transform Long 

# matches_url <- "https://api-football-v1.p.rapidapi.com/v3/fixtures"
# 
# match_response <- VERB(
#   "GET", 
#   matches_url, 
#   add_headers(
#     'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
#     'x-rapidapi-key' = 'c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24'
#   ), 
#   query = queryString, 
#   content_type("application/octet-stream")
# )
# 
# matches_raw <- jsonlite::fromJSON(httr::content(match_response, as = "text", encoding = "UTF-8"))
# 
# matches_data <- matches_raw$response %>%
#   pluck(data.frame)

#match_data <- py$ %>%
  # mutate(date = date(fixture$date)) %>%
  # filter(date >= date("2020-1-1"),
  #        date <= date("2022-1-23")
  # )

