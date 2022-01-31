# Match data transform/tidy for analysis

match_data <- py$matches_data %>%
  mutate(date = date(fixture.date)) %>%
  filter(date >= date("2020-1-1"),
         date <= date("2022-1-23")
         )

game_lag <- 3

match_data_seleted <- match_data %>%
  filter(fixture.status.short == "FT") %>%
  select(
    fixture.id,fixture.status.long, score.fulltime.home, 
    score.fulltime.away, goals.home, goals.away, 
    teams.home.name,teams.away.name, date)

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
    by = c("fixture.id"= "fixture.id", "opposing_team_role" = "opposing_team_role"))
  

  
set.seed(1234)

# Create match list to Build test and train data sets
match_list <- prior_match_data %>%
  group_by(fixture.id) %>%
  summarise() 

train_matches <- sample_n(match_list,100)

#Select Model data
model_data <- prior_match_data %>%
  select(
    fixture.id, win_outcome_target, prior_games_goals.x, prior_games_conceded.x,
    prior_wins.x,prior_games_goals.y,prior_games_conceded.y,prior_wins.y
    )
# Create train and test splits

library(recipes)
library(modeldata)
library(themis)


train_data <- model_data %>%
  inner_join(train_matches, by = c("fixture.id" = "fixture.id")) %>%
  mutate(target = as.factor(win_outcome_target)) %>%
  recipe(target ~ prior_games_goals.x + prior_games_conceded.x + 
           prior_wins.x+prior_games_goals.y + prior_games_conceded.y + 
           prior_wins.y, data = .) %>%
  step_smote(target) %>%
  step_normalize(all_predictors()) %>%
  prep(retain = TRUE)


test_data <- model_data %>%
  anti_join(train_matches, by = c("fixture.id" = "fixture.id"))

# For validation:
train_normalize <- bake(train_data, new_data = test_data, all_predictors())

set.seed(57974)
nnet_fit <-
  mlp(epochs = 100, hidden_units = 5, dropout = 0.1) %>%
  set_mode("classification") %>% 
  # Also set engine-specific `verbose` argument to prevent logging the results: 
  set_engine("keras", verbose = 0) %>%
  fit(target ~ ., data = bake(train_data, new_data = NULL))

nnet_fit
keras::install_keras()

install.packages("keras")
# Fit logistic regression

model_linear <- train_data %>%
  glm(
    data = ., win_outcome_target ~ prior_games_goals.x + prior_games_conceded.x + 
    prior_wins.x+prior_games_goals.y + prior_games_conceded.y + 
    prior_wins.y, family=binomial(link='logit')
    )

model_stats <-model_linear %>%
  tidy()

test_data$score <- test_data %>%
  predict(model_linear, newdata = .,  type = "response")

performance_plot <- test_data %>%
  ggplot(aes(group = win_outcome_target,x = win_outcome_target, y = score)) +
  geom_boxplot()+
  geom_jitter(aes(color = score)) +
  coord_flip() +
  custom_theme()

ggplotly(performance_plot)
