match_data <- py$laliga_match_data %>%
  mutate(date = date(fixture.date))

match_data_seleted <- match_data %>%
  filter(fixture.status.short == "FT") %>%
  select(
    fixture.id,fixture.status.long, score.fulltime.home, 
    score.fulltime.away, goals.home, goals.away, 
    teams.home.name,teams.away.name, date)
