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

remove_non_alpha <- function(x,y) {gsub("[^[:alnum:]]", paste(y), str_trim(x))}  

chosen_match <- match_statistics %>%
  filter(id == 546| id == 530) %>%
  group_by(id) %>%
  summarise(n = n())

normalize <- function(x) {(x - min(x))/ (max(x)-min(x))}

match_statistics <- read_parquet("match_stats.parquet") %>%
  unnest(cols = c(team)) %>%
  mutate(value = as.numeric(remove_non_alpha(if_else(is.na(value),"0",value),""))) %>%
  group_by(type) %>%
  mutate(normized_value = normalize(value)) %>%
  ungroup() %>%
  inner_join(chosen_match, by = c("id" = "id"))

match_stats_wide <- match_statistics %>%
  select(-normized_value) %>%
  pivot_wider(names_from = type, values_from = value)

match_up_viz <- match_statistics %>%
  ggplot() +
  ggridges::geom_density_ridges(aes(x = normized_value, y = type, fill = name))
match_up_viz

# # Functions that creates cost$$$$$$ ####
# # need to add tryCatch to the function I think
# new_match_statistics <- fixtures %>%
#   anti_join(match_statistics, by = c("fix" = "fix")) %>%
#   rowwise() %>%
#   mutate(
#     fixture_data =tryCatch(
#       {
#         lapply(fix, get_match_stats)
#         },
# error = function(e){
#   NA
# })) %>%
#   unnest()
#   
# 
# match_statistics <- match_statistics %>%
#   bind_rows(new_match_statistics)
# 
# write_parquet(match_statistics,"match_stats.parquet")



lag_exclude_current <- function(x) {
  rollsum(
    x,
    k = games_back,
    align = "right",
    fill = NA) - x
}

# Add match team level features ####
new_match_structure.test <-  match_data_seleted %>%
  pivot_longer(cols = c( "teams.home.id", "teams.away.id")) %>%
  mutate(fix = as.character(fixture.id)) %>%
  ungroup() %>%
  inner_join(
    match_stats_wide %>% 
      mutate(team_id = as.character(id)), 
    by = c("fix" = "fix", "value" = "id")
    ) %>%
  mutate(
    team_role = if_else(name.x == "teams.home.id", "teams.home.id","teams.away.id"),
    target_team_goals = if_else(team_role == "teams.home.name", goals.home, goals.away),
    opposing_team_goals = if_else(team_role == "teams.home.name", goals.away, goals.home),
    win_outcome_target = if_else(target_team_goals > opposing_team_goals, 1, 0),
    tie_outcome_target = if_else(target_team_goals == opposing_team_goals, 1, 0)
  ) %>%
  group_by(value, team_role) %>%
  arrange(date) %>%
  mutate_if(is.numeric,lag_exclude_current)# %>%
  ungroup() %>%
  drop_na() %>%
  select(fixture.id, value, name, prior_games_goals, prior_games_conceded,prior_wins) %>%
  pivot_wider(id_cols = c(fixture.id, value), values_from = c(prior_games_goals,prior_games_conceded,prior_wins)) %>%
  ungroup() %>%
  mutate_if(is.numeric ,.funs = na.locf, na.rm = FALSE) %>%
  drop_na()
