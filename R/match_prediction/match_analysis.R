# Match data transform/tidy and feature engineering for analysis ####


game_lag <- 12


match_team_long <- match_data_seleted %>% 
  pivot_longer(cols = c(teams.home.name,teams.away.name)) %>%
  ungroup() %>%
  mutate(
    opposing_team_role = if_else(name == "teams.home.name", "teams.away.name","teams.home.name"),
    target_team_goals = if_else(name == "teams.home.name", goals.home,goals.away),
    opposing_team_goals = if_else(name == "teams.home.name", goals.away, goals.home),
    win_outcome_target = if_else(target_team_goals > opposing_team_goals,1,0),
    tie_outcome_target = if_else(target_team_goals == opposing_team_goals,1,0)
    ) %>%
  group_by(value) %>%
  arrange(date) %>%
  mutate(
    lag_sum_goals_scored = rollsum(target_team_goals, k = game_lag, align = "right", fill = NA),
    lag_sum_goals_conceded = rollsum(opposing_team_goals, k = game_lag, align = "right", fill = NA),
    lag_sum_wins = rollsum(win_outcome_target, k = game_lag, align = "right", fill = NA)
    ) %>%
  ungroup() %>%
  mutate(
    prior_games_goals = lag_sum_goals_scored-target_team_goals, 
    prior_games_conceded = lag_sum_goals_conceded-opposing_team_goals,
    prior_wins = lag_sum_wins-win_outcome_target
    ) %>%
  filter(!is.na(lag_sum_goals_conceded))

# Join on opposing team and select fields for modeling ####
prior_match_data <- match_team_long %>%
  select(-c(lag_sum_goals_scored, lag_sum_goals_conceded,lag_sum_wins)) %>%
  inner_join(
    match_team_long %>%
      select(opposing_team_role = name, fixture.id, prior_games_goals, prior_games_conceded, prior_wins),
    by = c("fixture.id"= "fixture.id", "opposing_team_role" = "opposing_team_role")) %>%
  mutate(target = reorder(as.factor(if_else(win_outcome_target == 1, "win", "not_win")),-win_outcome_target)) %>%
  select(-win_outcome_target)
  
# Create match list to Build test and train data sets ####
match_list <- prior_match_data %>%
  group_by(fixture.id) %>%
  summarise() 

train_matches <- sample_n(match_list,300)

#Select model data ####
model_data <- prior_match_data %>%
  select(
    fixture.id, target, prior_games_goals.x, prior_games_conceded.x,
    prior_wins.x,prior_games_goals.y,prior_games_conceded.y,prior_wins.y
    )
# Create balanced + normalized train and normalized test data sets ####

train_data <- model_data %>%
  inner_join(train_matches, by = c("fixture.id" = "fixture.id")) %>%
  recipe(target ~ prior_games_goals.x + prior_games_conceded.x + 
           prior_wins.x+prior_games_goals.y + prior_games_conceded.y + 
           prior_wins.y, data = .) %>%
  step_smote(target) %>%
  step_normalize(all_predictors()) %>%
  prep(retain = TRUE)

test_data <- model_data %>%
  anti_join(train_matches, by = c("fixture.id" = "fixture.id"))

test_normalize <- bake(train_data, new_data = test_data, all_predictors())

# Fit Classification Models ####

# Logistic Regression
logistic_regression_model <-
  logistic_reg(
    mode = "classification",
    engine = "glm"
  ) %>%
  fit(target ~ ., data = bake(train_data, new_data = NULL))


# Gradient Boosting Trees
boost_tree_model <-
  boost_tree(
    mode = "classification",
    engine = "xgboost",
    trees = 2000
  ) %>%
  fit(target ~ ., data = bake(train_data, new_data = NULL))

# Random Forest
random_forest_model <-
  rand_forest(
    mode = "classification",
    engine = "ranger",
    trees = 2000
  ) %>%
  fit(target ~ ., data = bake(train_data, new_data = NULL))

# Multivariate adaptive regression splines
mars <-
  mars(
    mode = "classification",
    engine = "earth"
  ) %>%
  fit(target ~ ., data = bake(train_data, new_data = NULL))

#Predict on holdout data ####

predicted <- test_data %>%
  bind_cols(
    predict(logistic_regression_model, new_data = test_normalize, type = "prob") %>%
      select(logistic_regression = .pred_win),
    predict(boost_tree_model, new_data = test_normalize, type = "prob") %>%
      select(xgboost = .pred_win),
    predict(random_forest_model, new_data = test_normalize, type = "prob") %>%
      select(random_forest = .pred_win),
    predict(mars, new_data = test_normalize, type = "prob") %>%
    select(mars = .pred_win)
    )

predicted_long <- predicted %>%
  pivot_longer(cols = c(xgboost, random_forest, mars, logistic_regression)) 

# Model Performance ####
output_auc <- predicted_long %>%
  group_by(name) %>%
  roc_auc(target, value)

prediction_roc <- predicted_long %>%
  group_by(name) %>%
  roc_curve(truth = target, value) #%>%
  ungroup() %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = name)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal() #+
  #custom_theme()
thematic::thematic_on()
ggplotly(prediction_roc)

# Plot predictions Performance ####

performance_plot <- predicted_long %>%
  ggplot(aes(group = target, x = target, y = value)) +
  geom_violin() +
  geom_jitter(aes(color = value)) +
  coord_flip() +
  custom_theme() +
  facet_wrap(facets = "name")

ggplotly(performance_plot)

# Feature importance 
log_reg_tidy <- logistic_regression_model %>%
  tidy()
