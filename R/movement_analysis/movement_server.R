#Interactive Layoout
observeEvent(
  input$movement_sidebar_button, {
  shinyjs::toggle(id = "movement_sidebar")
})

# Movement Data ####
movement_data <- reactive(
  modeled_data %>%
    filter(
      frame <= input$match_time,
      frame >= input$match_time - input$n_trail,
      frame %% 9 == 1
    )
  )

#Field Plot ####
movement_plot <- reactive(
  {
    explore <- movement_data() %>%
      ggplot(aes(x = x, y = y, color = team, label = player)) +
      geom_rect(aes(xmin= 0, xmax = 1, ymin = 0, ymax = 1),color = "white", fill = "light green")+
      annotate("rect", xmin = -.07, xmax = 0, ymin = .35, ymax = .65, fill = "grey")+
      annotate("rect", xmin = 1, xmax = 1.07, ymin = .35, ymax = .65, fill = "grey")+
      geom_segment(aes(x = .5,xend = .5, y = 0, yend= 1), color = "grey", size = 1)+
      geom_point(aes(alpha = frame),size = 2) +
      scale_color_manual(values = c("home" = colors$skyBlue, "away" = colors$grey,"Ball" = "white", "modeled" = colors$red))+
      scale_y_continuous(limits = c(-0.05,1))+
      scale_x_continuous(limits = c(-0.08,1.08))+
      custom_theme() +
      theme(legend.position = "none",
            axis.title.x = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank()
            )
    return(ggplotly(explore))
    }
  )

output$movement_plot <- renderPlotly({movement_plot()})

# Create X Ball Density ####
ball_x_density_plot <- reactive(
  {
    ball_x_density <- metrica_tracking_tidy %>%
      filter(team == "Ball") %>%
      ggplot(aes(x = x)) +
      geom_density(fill = "white", color = "white") +
      scale_x_continuous(limits = c(-0.08,1.08))+
      custom_theme() +
      theme(legend.position = "none",
            axis.title.x = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank()
      )
    return(ggplotly(ball_x_density))
  }
)

output$ball_x_density_plot <- renderPlotly({ball_x_density_plot()})

# Create Y Ball Density ####
ball_y_density_plot <- reactive(
  {
    ball_y_density <- metrica_tracking_tidy %>%
      filter(team == "Ball") %>%
      ggplot(aes(x = y)) +
      geom_density(fill = "white", color = "white") +
      scale_x_continuous(limits = c(-0.08,1.08))+
      custom_theme() +
      theme(legend.position = "none",
            axis.title.x = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank()
      ) +
      coord_flip()
    return(ggplotly(ball_y_density))
  }
)

output$ball_y_density_plot <- renderPlotly({ball_y_density_plot()})


output$ball_x_density_plot <- renderPlotly({ball_x_density_plot()})