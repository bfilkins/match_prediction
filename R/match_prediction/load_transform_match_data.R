# Load and Transform base match data and match statistics

match_data <- readRDS("match_data.RDS")
match_data_seleted <- match_data %>%
  filter(fixture.status.short == "FT") %>%
  select(
    fixture.id,fixture.status.long, score.fulltime.home, 
    score.fulltime.away, goals.home, goals.away, teams.home.id,
       teams.home.name, teams.away.id, teams.away.name, date)

match_statistics <- read_parquet("match_stats.parquet")
