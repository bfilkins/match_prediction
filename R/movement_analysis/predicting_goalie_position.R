metrica_tracking_wide <- metrica_tracking_tidy %>%
  filter(!is.na(x),
         !is.na(y)) %>%
  mutate(player = if_else(team == "Ball", "Ball", player)) %>%
  select(-team) %>%
  pivot_wider(names_from = player, values_from = c("x", "y")) %>% 
  select(frame,y_11,x_11, y_Ball, x_Ball, y_2,x_2) %>%
  filter(!is.na(y_Ball))

goalie_position_model <- lm(formula = cbind(y_11, x_11) ~ y_Ball + x_Ball + y_2 + x_2, data = metrica_tracking_wide )

predicted_position <- predict(goalie_position_model, metrica_tracking_wide) %>%
  cbind(
    metrica_tracking_wide %>%
      select(frame)) %>%
  select(frame, x = x_11, y = y_11) %>%
  mutate(player = "predicted",
         team = "modeled")

modeled_data <- metrica_tracking_tidy %>%
  bind_rows(predicted_position)
