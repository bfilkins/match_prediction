# Select and Transform Stats going into match ####

chosen_match <- match_statistics %>%
  filter(id == 546| id == 530) %>%
  group_by(id) %>%
  summarise(n = n())


match_statistics <- read_parquet("match_stats.parquet")# %>%
unnest(cols = c(team)) %>%
  mutate(value = as.numeric(remove_non_alpha(if_else(is.na(value),"0",value),""))) %>%
  group_by(type) %>%
  mutate(normized_value = normalize(value)) %>%
  ungroup() %>%
  inner_join(chosen_match, by = c("id" = "id"))

match_stats_wide <- match_statistics %>%
  select(-normized_value) %>%
  pivot_wider(names_from = type, values_from = value)


# Visualize Stats going into match ####
match_up_viz <- match_statistics %>%
  ggplot() +
  ggridges::geom_density_ridges(aes(x = normized_value, y = type, fill = name))
match_up_viz
