

leagues_url <- "https://api-football-v1.p.rapidapi.com/v3/leagues"

leagues_queryString <- list(id = "39")

leagues_response <- VERB(
  "GET", 
  leagues_url, 
  add_headers(
    'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
    'x-rapidapi-key' = 'c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24'
  ), 
  query = queryString
)

leagues_raw <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

leagues_data <- leagues_raw$response %>%
  pluck(data.frame)
