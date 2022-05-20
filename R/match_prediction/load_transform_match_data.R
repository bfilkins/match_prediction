# Load and Transform base match data and match statistics

match_data <- readRDS("match_data.RDS")
match_data_seleted <- match_data %>%
  filter(fixture.status.short == "FT") %>%
  select(
    fixture.id,fixture.status.long, score.fulltime.home, 
    score.fulltime.away, goals.home, goals.away, teams.home.id,
    teams.home.name, teams.away.id, teams.away.name, fixture.date) %>%
  mutate(date = date(fixture.date)) %>%
  mutate_if(is_all_numeric,as.numeric)

match_statistics <- readRDS("match_statistics.RDS")
# This will need to be fixed (bug)
match_statistics.0 <- match_statistics %>%
  select(-team)

write.csv(match_statistics.0, "match_statistics.csv")
