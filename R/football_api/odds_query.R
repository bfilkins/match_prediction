# Query match odds ####


odds_url <- "https://api-football-v1.p.rapidapi.com/v3/odds"

odds_queryString <- list(fixture = "568989")

odds_response <- VERB(
  "GET",
  odds_url,
  query = odds_queryString, 
  add_headers(
    'x-rapidapi-host' = 'api-football-v1.p.rapidapi.com', 
    'x-rapidapi-key' = 'c5c5e223d6msh45c25cf6ec57892p1aa1d2jsn43203354fc24'
  )
)

odds_raw <- jsonlite::fromJSON(httr::content(odds_response, as = "text", encoding = "UTF-8"))

odd_data <- odds_response$content #%>%
  pluck(data.frame) %>%
  unnest(statistics) %>%
  tibble()

content(odds_response, "text")


