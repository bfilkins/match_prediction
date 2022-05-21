# Load and Transform base match data and match statistics

# match_data <- readRDS("match_data.RDS")
# match_data_seleted <- match_data %>%
#   filter(fixture.status.short == "FT") %>%
#   select(
#     fixture.id,fixture.status.long, score.fulltime.home,
#     score.fulltime.away, goals.home, goals.away, teams.home.id,
#     teams.home.name, teams.away.id, teams.away.name, fixture.date) %>%
#   mutate(date = date(fixture.date)) %>%
#   mutate_if(is_all_numeric,as.numeric)
# 
# arrow::write_parquet(match_data_seleted, "match_data_selected.parquet")

# match_statistics <- readRDS("match_statistics.RDS") %>%
#   unnest(team)
# 
# arrow::write_parquet(match_statistics,"match_statistics.parquet")
# # This will need to be fixed (bug)
# match_statistics.0 <- match_statistics %>%
#   select(-team)
# 
# write.csv(match_statistics.0, "match_statistics.csv")
# match_data %>%
#   summarise(
#     n= n(),
#     n_dis = n_distinct(fixture.id)
#   )
