#Light Colors
  bg_color <- "#DEDEE0"
  fg_color <- "#363636"
  detail_color <- "#444444"

#Dark Colors
#bg_color <- "#222222"
#fg_color <- "#DADDD8"
#detail_color <- "#F9F9F9"

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

minimal_light <-
  function (default_text = 11,
            orientation = c("x", "y", "xy",
                            "none"))
  {
    orientation <- match.arg(orientation)
    pcolors <- c(
      black = "#222222",
      `dark gray` = "#444444",
      `medium gray` = "#888888",
      `medium light gray` = "#dddddd",
      `light gray` = "#eaeaea"
    )
    text_sizes <- c(
      default = default_text,
      title = default_text *
        1.4,
      subtitle = default_text * 1.25,
      caption = default_text,
      axis_title = default_text,
      axis_text = default_text
    )
    line_size <- pt_to_mm(default_text) * 0.15
    out_theme <-
      theme_minimal() + theme(
        text = element_text(
          family = "sans",
          color = pcolors[["dark gray"]],
          size = text_sizes[["default"]]
        ),
        line = element_line(size = line_size),
        plot.background = element_rect(color = NA,
                                       fill = "white"),
        plot.title = element_text(
          family = "Verdana",
          face = "bold",
          size = text_sizes[["title"]],
          color = pcolors[["black"]],
          hjust = 0.5
        ),
        plot.subtitle = element_text(
          size = text_sizes[["subtitle"]],
          color = pcolors[["medium gray"]],
          family = "sans",
          face = "plain",
          hjust = 0.5,
          margin = margin(0, 0,
                          text_sizes[["default"]], 0)
        ),
        plot.caption = element_text(
          size = text_sizes[["caption"]],
          color = pcolors[["medium gray"]],
          margin = margin(text_sizes[["default"]],
                          0, 0, 0)
        ),
        plot.title.position = "plot",
        panel.spacing.x = unit(default_text *
                                 2, "pt"),
        panel.spacing.y = unit(default_text * 2,
                               "pt"),
        axis.title = element_text(color = pcolors[["medium gray"]],
                                  size = text_sizes[["axis_title"]]),
        axis.text = element_text(color = pcolors[["dark gray"]],
                                 size = text_sizes[["axis_text"]]),
        axis.line.x = element_blank(),
        axis.line.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(
          linetype = "dashed",
          color = pcolors[["medium light gray"]],
          size = line_size
        ),
        legend.direction = "horizontal",
        legend.position = "top",
        legend.margin = margin(0, 0, text_sizes[["default"]],
                               0),
        legend.title = element_text(face = "bold", size = text_sizes[["default"]]),
        legend.text = element_text(size = text_sizes[["default"]]),
        strip.background = element_blank(),
        strip.text = element_text(
          size = text_sizes[["default"]],
          face = "italic",
          lineheight = 0.9
        ),
        
      )
    if (orientation == "none") {
      out_theme <- out_theme + theme(panel.grid.major = element_blank())
    }
    else if (orientation == "x") {
      out_theme <-
        out_theme + theme(
          axis.line.x = element_line(color = pcolors[["medium light gray"]],
                                     size = line_size * 3),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_line(
            color = pcolors[["light gray"]],
            size = line_size,
            linetype = "solid"
          )
        )
    }
    else if (orientation == "y") {
      out_theme <-
        out_theme + theme(
          axis.line.y = element_line(color = pcolors[["medium light gray"]],
                                     size = line_size * 3),
          panel.grid.major.x = element_line(
            color = pcolors[["light gray"]],
            size = line_size,
            linetype = "solid"
          ),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(),
        )
    }
    .suggest_dimensions(default_text)
    out_theme
  }


my_theme <- bs_theme(
  bg = bg_color,
  fg = fg_color,
  primary = detail_color,
  secondary = detail_color,
  base_font =  "Monaco"
)
