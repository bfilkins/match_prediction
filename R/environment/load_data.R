metrica_tracking_tidy <- read.csv("R/metrica_tracking_tidy.csv") %>%
  filter(
    game_id == 1,
    period == 1,
    frame >= 3670,
    frame <= 12000) 

#inputs

max_frame <- metrica_tracking_tidy %>%
  summarise(max = max(frame)) %>%
  pull(max)
