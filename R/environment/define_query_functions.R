
# Define Match stats function
get_match_stats <- function(fixture.id) {
  match_stats_url <- "https://api-football-v1.p.rapidapi.com/v3/fixtures/statistics"
  match_stats_queryString <- list(fixture = fixture.id)
  
  match_stats_response <- VERB(
    "GET",
    match_stats_url,
    query = match_stats_queryString, 
    add_headers(
      'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
      'x-rapidapi-key' = Sys.getenv("rapid_api_key")
      )
    )
  match_stats_raw <- jsonlite::fromJSON(httr::content(match_stats_response, as = "text", encoding = "UTF-8"))
  
  match_stats_data <- match_stats_raw$response %>%
  pluck(data.frame) %>%
  unnest(statistics) %>%
  tibble()
  return(match_stats_data)
  }


