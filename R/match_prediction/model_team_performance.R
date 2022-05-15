top_x <- 7

home_team_predictions <- predicted %>%
  mutate(
    fixture.id = as.character(fixture.id),
    correct = if_else(target_outcome==.pred_class,1,0)) %>%
  inner_join(match_data, by = c("fixture.id" = "fixture.id")) %>%
  group_by(model, teams.home.name) %>%
  summarise(
    accurate_predictions = sum(correct),
    n = n(),
    percent_accurate = accurate_predictions/n
  )
  
home_team_plot <- home_team_predictions %>%
  filter(n >= 10) %>%
  group_by(teams.home.name) %>%
  mutate(
    aggregate = max(percent_accurate)
    ) %>%
  ungroup() %>%
  mutate(
    label = scales::percent_format(accuracy = .1)(percent_accurate),
    `model performance` = if_else(percent_accurate == aggregate, "top model", "non-top model")) %>%
  top_n(top_x*3,aggregate) %>%
  ggplot(aes(x = as.factor(reorder(teams.home.name, aggregate)))) +
  geom_bar(aes(y = percent_accurate, fill = `model performance`), stat = "identity") +
  geom_text(aes(y = .09, label = label )) +
  geom_hline(yintercept = .33, linetype = "dotted") +
  scale_fill_manual(values = c("non-top model" = colors$grey, "top model" = colors$skyBlue))+
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  xlab("") +
  ylab("accuracy") +
  facet_wrap(facets = "model", nrow = 1) +
  theme_light_min() +
  theme(
    plot.title = element_text(hjust = 0.67),
    plot.subtitle = element_text(hjust = 0.5)) +
  ggtitle("Most predictable football clubs at home") +
  labs(caption = "[games accurately predicted] / [games predicted] \ndotted line represents naive prediction for 3-class predictions: win - tie - loss")

home_team_plot


away_team_predictions <- predicted %>%
  mutate(
    fixture.id = as.character(fixture.id),
    correct = if_else(target_outcome==.pred_class,1,0)) %>%
  inner_join(match_data, by = c("fixture.id" = "fixture.id")) %>%
  group_by(model, teams.away.name) %>%
  summarise(
    accurate_predictions = sum(correct),
    n = n(),
    percent_accurate = accurate_predictions/n
  )

away_team_plot <- away_team_predictions %>%
  filter(n >= 20) %>%
  group_by(teams.away.name) %>%
  mutate(
    aggregate = max(percent_accurate)
  ) %>%
  ungroup() %>%
  mutate(
    label = scales::percent_format(accuracy = .1)(percent_accurate),
    `model performance` = if_else(percent_accurate == aggregate, "top model", "non-top model")) %>%
  top_n(top_x*3,aggregate) %>%
  ggplot(aes(x = as.factor(reorder(teams.away.name, aggregate)))) +
  geom_bar(aes(y = percent_accurate, fill = `model performance`), stat = "identity") +
  geom_text(aes(y = .09, label = label )) +
  geom_hline(yintercept = .33, linetype = "dotted") +
  scale_fill_manual(values = c("non-top model" = colors$grey, "top model" =wesanderson::wes_palettes$FantasticFox1[3] ))+
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  xlab("") +
  ylab("accuracy") +
  facet_wrap(facets = "model", nrow = 1) +
  theme_light_min() +
  theme(
    plot.title = element_text(hjust = 0.67),
    plot.subtitle = element_text(hjust = 0.5)) +
  ggtitle("Most predictable football clubs away") +
  labs(caption = "[games accurately predicted] / [games predicted] \ndotted line represents naive prediction for 3-class predictions: win - tie - loss")

away_team_plot


