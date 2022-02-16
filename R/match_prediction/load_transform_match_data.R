# match_data <- py$laliga_match_data %>%
#  mutate(date = date(fixture.date))

#saveRDS(match_data, "match_data.RDS")
match_data <- readRDS("match_data.RDS")
match_data_seleted <- match_data %>%
  filter(fixture.status.short == "FT") %>%
  select(
    fixture.id,fixture.status.long, score.fulltime.home, 
    score.fulltime.away, goals.home, goals.away, teams.home.id,
       teams.home.name, teams.away.id, teams.away.name, date)
