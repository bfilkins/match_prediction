# Query Matches
years_selected <- tibble(
  year = c("2018", "2019", "2020", "2021","2022"), 
  join = "x"
  )

# Query Leagues 
leagues <- py$league_query(api_key = Sys.getenv("rapid_api_key"))

# Refine to specific leagues I like for no real specific reason 
selected_leagues <- leagues %>%
  filter(
    league.name == "Bundesliga 1"| league.name == "La Liga" |
    league.name == "Major League Soccer" | league.id == "39"
    ) %>% #(39 is premier league)
  select(league.id,league.name,country.name,country.flag) %>%
  mutate(
    league = as.character(league.id),
    join = "x"
    ) %>%
  inner_join(
    years_selected, 
    by = c("join"= "join")
    )

fixtures <- py$fixture_query(
  api_key = Sys.getenv("rapid_api_key"), 
  league = "140", 
  year = "2021"
  ) 

# Query fixtures function
fixtures_query <- function(league, year){
  py$fixture_query(
    api_key = Sys.getenv("rapid_api_key"), 
    league = league, 
    year = year) %>%
  mutate(across(everything(), as.character))
  }

# Query 
fixtures <- selected_leagues %>%
  rowwise() %>%
  mutate(
    matches_data = tryCatch(
      {lapply(league, fixtures_query, year = year)}, 
      error = function(e) {NA}
      )
    ) %>%
  unnest()

# Query fixture statistics ####
# This is the function that can run costs up

new_match_statistics <- fixtures %>%
  mutate(fix = as.character(fixture.id)) %>%
  #anti_join(match_statistics, by = c("fix" = "fix")) %>% #bring this back eventually?
  rowwise() %>%
  mutate(fixture_data = tryCatch(
    {lapply(fix, get_match_stats)},
    error = function(e) {
    NA})) %>%
  unnest() %>%
  filter(!is.na(value))

# Need to fix: this anti join is redundant so I don't get recursive stuff ####
# is this the right approach here?
# match_statistics <- match_statistics %>%
#   bind_rows(
#     new_match_statistics %>%
#       anti_join(
#         match_statistics, by = c("fix" = "fix")
#         )
#     ) %>%
#   filter(!is.na(value))


# query odds (this still needs work) ####

odds_data <- py$odds_query(api_key = Sys.getenv("rapid_api_key"),league = "140", year = "2021")
