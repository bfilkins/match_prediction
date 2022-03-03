# Create prior performance for home and away matches for each team going into a match #### 
games_back <- 8 

new_match_structure.0 <-  match_data_seleted %>%
  pivot_longer(cols = c( "teams.home.id", "teams.away.id")) %>%
  ungroup() %>%
  mutate(
    team_role = if_else(
      name == "teams.home.id",
      "teams.home.id",
      "teams.away.id"
    ),
    target_team_goals = if_else(team_role == "teams.home.name", goals.home, goals.away),
    opposing_team_goals = if_else(team_role == "teams.home.name", goals.away, goals.home),
    win_outcome_target = if_else(target_team_goals > opposing_team_goals, 1, 0),
    tie_outcome_target = if_else(target_team_goals == opposing_team_goals, 1, 0)
  ) %>%
  group_by(value, team_role) %>%
  arrange(date) %>%
  mutate(
    lag_sum_goals_scored = rollsum(
      target_team_goals,
      k = games_back,
      align = "right",
      fill = NA
    ),
    lag_sum_goals_conceded = rollsum(
      opposing_team_goals,
      k = games_back,
      align = "right",
      fill = NA
    ),
    lag_sum_wins = rollsum(
      win_outcome_target,
      k = games_back,
      align = "right",
      fill = NA
    )
  ) %>%
  ungroup() %>%
  mutate(
    prior_games_goals = lag_sum_goals_scored - target_team_goals,
    prior_games_conceded = lag_sum_goals_conceded - opposing_team_goals,
    prior_wins = lag_sum_wins - win_outcome_target
  ) %>%
  drop_na() %>%
  select(fixture.id, value, name, prior_games_goals, prior_games_conceded,prior_wins) %>%
  pivot_wider(id_cols = c(fixture.id, value), values_from = c(prior_games_goals,prior_games_conceded,prior_wins)) %>%
  ungroup() %>%
  mutate_if( is.numeric ,.funs = na.locf, na.rm = FALSE) %>%
  drop_na()

# Join features back to match level data for home and away teams ####
new_match_structure.1 <- match_data_seleted %>%
  inner_join(
    new_match_structure.0 %>%
      select(value, fixture.id, hometeams_goals_home = prior_games_goals_teams.home.id, hometeams_goals_away = prior_games_goals_teams.away.id),
    by = c("teams.home.id" = "value", "fixture.id" = "fixture.id")
    ) %>%
  inner_join(
    new_match_structure.0 %>%
      select(value, fixture.id, awayteams_goals_home = prior_games_goals_teams.home.id, awayteams_goals_away = prior_games_goals_teams.away.id),
    by = c("teams.away.id" = "value", "fixture.id" = "fixture.id")) %>%
  mutate(
    target_outcome = case_when(
      goals.home > goals.away ~ "home_win",
      goals.away > goals.home ~ "away_win",
      goals.home == goals.away ~ "tie"
      )
    )


# Add match team level features ####

match_stats_wide <- match_statistics  %>%
  mutate(
    fix = fix,
    clean_name = remove_non_alpha(type,""),
    clean_value = as.numeric(remove_non_alpha(value,""))
  ) %>%
  unnest(team) %>%
  pivot_wider(id_cols = c(fix, id) , names_from = clean_name, values_from = clean_value, values_fill = 0) %>%
  inner_join(
    match_data %>% 
      mutate(
        fix = as.character(fixture.id),
        date = date(fixture.date)
      ) %>%
      select(fix, date),
    by = c("fix" = "fix")
  ) %>%
  mutate(id = as.character(id)) %>%
  group_by(id) %>%
  arrange(date) %>%
  mutate_if(is.numeric, lag_exclude_current) %>%
  ungroup() %>%
  select(-date) %>%
  drop_na()

# Join match statistics data ####
# Need to build this out still

# Create match list to Build test and train data sets ####
match_list <- new_match_structure.1  %>% 
  group_by(fixture.id) %>%
  summarise()

train_matches <- sample_n(match_list,300)

# #Select model data ####
model_data <- new_match_structure.1 %>%
  select(fixture.id, 11:16)

# Create balanced + normalized train and normalized test data sets #### 
# abstract this section so features are list input

train_data <- model_data %>%
  inner_join(train_matches, by = c("fixture.id" = "fixture.id")) %>%
    recipe(target_outcome ~ hometeams_goals_home + hometeams_goals_away + awayteams_goals_home + awayteams_goals_away, data = .) %>%
  step_smote(target_outcome) %>%
  step_normalize(all_predictors()) %>%
  prep(retain = TRUE)

test_data <- model_data %>%
  anti_join(train_matches, by = c("fixture.id" = "fixture.id"))

test_normalize <- bake(train_data, new_data = test_data, all_predictors()) %>%
  bind_cols(test_data %>% select(fixture.id))

# Fit Classification Models ####

# Multi-nomial Regression
multinomial_regression <-
  multinom_reg() %>%
  set_engine("nnet") %>%
  fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))

# Gradient Boosting Trees
boost_tree_model <-
  boost_tree(
    mode = "classification",
    trees = 2000
  ) %>%
  set_engine("xgboost") %>%
  fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))

# Random Forest
random_forest_model <<-
  rand_forest(
    mode = "classification",
    trees = 2000
  ) %>%
  set_engine("ranger") %>%
  fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))


#Predict on holdout data ####

predicted.0 <- bind_rows(
  bind_cols(
    test_data %>% select(fixture.id,target_outcome),
    predict(multinomial_regression, new_data = test_normalize, type = "prob") %>%
    mutate(model = "multinomial regression")
    ),
  bind_cols(
    test_data %>% select(fixture.id,target_outcome),
    predict(boost_tree_model, new_data = test_normalize, type = "prob") %>%
    mutate(model = "boosted trees")
    ),
  bind_cols(
    test_data %>% select(fixture.id,target_outcome),
    predict(random_forest_model, new_data = test_normalize, type = "prob") %>%
    mutate(model = "random forest")
    )
  )

predicted <- predicted.0 %>%
  mutate(
    tie = factor(if_else(target_outcome == "tie", 1, 0), levels = c(1,0)),
    win_home = factor(if_else(target_outcome == "home_win", 1,0), levels = c(1,0)),
    away_win = factor(if_else(target_outcome == "away_win", 1,0), levels = c(1,0))
  )



tie_prediction_roc <- predicted %>%
  group_by(model) %>%
  yardstick::roc_curve(truth = tie, .pred_tie) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
    geom_path() +
  ggtitle("Tie")+
    geom_abline(lty = 3) +
    coord_equal() + 
  theme(legend.position = "none")

home_win_prediction_roc <- predicted %>%
  group_by(model) %>%
  yardstick::roc_curve(truth = win_home, .pred_home_win) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
  geom_path() +
  ggtitle("Home Win")+
  geom_abline(lty = 3) +
  coord_equal() + 
  theme(legend.position = "none")

away_win_prediction_roc <- predicted %>%
  group_by(model) %>%
  yardstick::roc_curve(truth = away_win, .pred_away_win) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
  geom_path() +
  ggtitle("Away Win")+
  geom_abline(lty = 3) +
  coord_equal()

row_legend <- cowplot::get_legend(away_win_prediction_roc)

away_win_prediction_roc <- away_win_prediction_roc +
  theme(legend.position = "none")
  
cowplot::plot_grid(cowplot::plot_grid(home_win_prediction_roc,tie_prediction_roc,away_win_prediction_roc, nrow = 1), row_legend, nrow= 1, rel_widths = c(9,1))
