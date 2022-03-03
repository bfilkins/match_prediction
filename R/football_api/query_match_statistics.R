# load base match data from py environment into R and save locally ####

# match_data <- py$laliga_match_data %>%
#  mutate(date = date(fixture.date))

#saveRDS(match_data, "match_data.RDS")


# query uncollected match statistic data for matches in model data ####
# get all matches list ####

# fixtures <- match_data %>%
#   mutate(fix = as.character(fixture.id)) %>%
#   group_by(fix) %>%
#   summarise() %>%
#   ungroup()


# Load and query match level statistics ####

match_statistics <- read_parquet("match_stats.parquet")

# !! this is the function that can run costs up 
# Need to fix: un-nest
# 
# new_match_statistics <- fixtures %>%
#   anti_join(match_statistics, by = c("fix" = "fix")) %>%
#   rowwise() %>%
#   mutate(fixture_data = tryCatch(
#     {lapply(fix, get_match_stats)},
#     error = function(e) {
#     NA})) %>%
#   unnest()
# 
# # Need to fix: this anti join is redundant so I don't get recursive shit
# # is this the right approach here?
# match_statistics <- match_statistics %>%
#   bind_rows(
#     new_match_statistics %>%
#       anti_join(
#         match_statistics, by = c("fix" = "fix")
#         )
#     ) %>%
#   filter(!is.na(value))

# Write to database. Eventually replace with AWS
# write_parquet(match_statistics,"match_stats.parquet")



