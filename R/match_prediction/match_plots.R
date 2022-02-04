# Match Data Visualizations

team_plot <- match_team_long %>%
  filter(value == "Levante") %>%
  ggplot(aes(x = date)) +
  geom_smooth(aes(y = lag_sum_goals_scored), method = "lm" , color = colors$skyBlue) +
  geom_line(aes(y = lag_sum_goals_scored), color = colors$skyBlue) +
  geom_line(aes(y = lag_sum_goals_conceded), color = colors$red) +
  geom_smooth(aes(y = lag_sum_goals_conceded), method = "lm" , color = colors$red) +
  facet_grid(facets = "value", scales = "free_y")
team_plot
ggsave("team_goal_trends.png", device = "png" )