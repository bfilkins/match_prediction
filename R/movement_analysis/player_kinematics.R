

movement_analysis_stats <- modeled_data %>%
  mutate(t = frame) %>%
  filter(player == 10) %>%
  append_dynamics() %>%
  select(frame, vx, vy, aspeed, ax, ay, aaccel)%>%
  pivot_longer(cols = c(aspeed,aaccel)) %>%
  ggplot(aes(x = frame, y = value, color = name)) +
  geom_line()

ggplotly(movement_analysis_stats)


what <- example_mov %>%
  append_dynamics() %>%
  select(t, vx, vy, aspeed, ax, ay, aaccel)%>%
  pivot_longer(cols = c(vx, vy, aspeed, aaccel, ax, ay)) %>%
  group_by(name) %>%
  mutate(actual = value/(max(value)- min(value))) %>%
  ggplot(aes(x = t, y = actual, color = name)) +
  geom_line()

ggplotly(what)
