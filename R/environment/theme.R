#Light Colors
 # bg_color <- "#DEDEE0"
 # fg_color <- "#363636"
 # detail_color <- "#444444"

#Dark Colors
bg_color <- "#222222"
fg_color <- "#DADDD8"
detail_color <- "#F9F9F9"

colors <-   list(
  "red" = "#f50537",  # red
  "grey" = "#4c4c4c",  # dark grey
  "ultramarine" = "#0e1d7f",  # blue
  "skyBlue" = "#1E71B4",  # light blue
  "turquiose" = "#0E5469",  # blue-green
  "darkTeal" = "#183438",  # dark blue-green
  "sage" = "#5B5F46",  # dark green
  "sunflower" = "#B76001",  # orange
  "chocolate" = "#452914",  # brown
  "burgundy" = "#7e0e1c",  # deep red
  "eggplant" = "#4F1830",  # purple
  "lilac" = "#7A87B9",  # purple gray
  "slate" = "#98A2AD",  # blue gray
  "vanilla" = "#D6C7AA",  # beige
  "black" = "#000000"  # black
)

# font_add("Gotham Bold", "/Library/Fonts/AudiType-Normal.ttf")  # Use the actual file path
# showtext_auto()

custom_theme <- function(p) {
  ggplot2::theme_bw() +
    ggplot2::theme(
      text = element_text(family = "Monaco", size = 12),
      plot.background = element_rect(fill = "transparent", colour = NA),
      panel.background = element_rect(fill = "transparent", colour = NA),
      panel.border = element_rect(color = detail_color, size = .5),
      plot.title = element_text(color = detail_color),
      plot.subtitle = element_text(color = detail_color),
      axis.title.x = element_text(color = detail_color),
      axis.title.y = element_text(color = detail_color),
      axis.text.x = element_text(color = detail_color),
      axis.text.y = element_text(color = detail_color),
      plot.caption = element_text(color = detail_color),
      legend.title = element_blank(),
      legend.background = element_rect(fill = "transparent", colour = NA),
      legend.text = element_text(color = detail_color),
      legend.box.background = element_rect(fill = "transparent", colour = NA),
      legend.key = element_blank(),
      strip.background = element_rect(fill = bg_color, color = detail_color),
      strip.text = element_text(color = detail_color),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_blank()
    )
}

my_theme <- bs_theme(
  bg = bg_color,
  fg = fg_color,
  primary = detail_color,
  secondary = detail_color,
  base_font =  "Monaco"
)
