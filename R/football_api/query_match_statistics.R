# Query matches in model data

teams <- match_data %>% 
  filter(date == date("2022-2-12")) %>%
  head(1) %>%
  select(teams.away.id, teams.home.id) %>%
  pivot_longer(cols = c(teams.away.id, teams.home.id))

fixtures <- bind_rows(
  match_data %>%
    inner_join(teams, by = c("teams.away.id" = "value")),
  match_data %>%
    inner_join(teams, by = c("teams.home.id" = "value")) 
  ) %>%
  mutate(fix = as.character(fixture.id)) %>%
  group_by(fix) %>%
  summarise() %>%
  ungroup() %>%
  head(40)
  
match_statistics <- read_parquet("match_stats.parquet")

# Functions that creates cost$$$$$$ ####
# need to add tryCatch to the function I think
new_match_statistics <- fixtures %>%
  anti_join(match_statistics, by = c("fix" = "fix")) %>%
  rowwise() %>%
  mutate(
    fixture_data =tryCatch(
      {
        lapply(fix, get_match_stats)
        },
error = function(e){
  NA
})) %>%
  unnest()
  

match_statistics <- match_statistics %>%
  bind_rows(new_match_statistics)

write_parquet(match_statistics,"match_stats.parquet")

