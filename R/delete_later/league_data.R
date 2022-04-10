

leagues_url <- "https://api-football-v1.p.rapidapi.com/v3/leagues"

leagues_queryString <- list(id = "39")

leagues_response <- VERB(
  "GET", 
  leagues_url, 
  add_headers(
    'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
    'x-rapidapi-key' = ''
  ), 
  query = queryString
)

leagues_raw <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

leagues_data <- leagues_raw$response %>%
  pluck(data.frame)
