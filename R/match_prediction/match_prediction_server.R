#Interactive Layoout
observeEvent(
  input$match_prediction_sidebar_button, {
    shinyjs::toggle(id = "match_prediction_sidebar")
  })

# Match Long Data and Feature Engineering ####
define_model_data <- reactive({
  new_match_structure.0 <-  match_data_seleted %>%
    pivot_longer(cols = c( "teams.home.id", "teams.away.id")) %>%
    ungroup() %>%
    mutate(
      team_role = if_else(
        name == "teams.home.id",
        "teams.home.id",
        "teams.away.id"
      ),
      target_team_goals = if_else(team_role == "teams.home.name", goals.home, goals.away),
      opposing_team_goals = if_else(team_role == "teams.home.name", goals.away, goals.home),
      win_outcome_target = if_else(target_team_goals > opposing_team_goals, 1, 0),
      tie_outcome_target = if_else(target_team_goals == opposing_team_goals, 1, 0)
    ) %>%
    group_by(value, team_role) %>%
    arrange(date) %>%
    mutate(
      lag_sum_goals_scored = rollsum(
        target_team_goals,
        k = games_back,
        align = "right",
        fill = NA
      ),
      lag_sum_goals_conceded = rollsum(
        opposing_team_goals,
        k = games_back,
        align = "right",
        fill = NA
      ),
      lag_sum_wins = rollsum(
        win_outcome_target,
        k = games_back,
        align = "right",
        fill = NA
      )
    ) %>%
    ungroup() %>%
    mutate(
      prior_games_goals = lag_sum_goals_scored - target_team_goals,
      prior_games_conceded = lag_sum_goals_conceded - opposing_team_goals,
      prior_wins = lag_sum_wins - win_outcome_target
    ) %>%
    drop_na() %>%
    select(fixture.id, value, name, prior_games_goals, prior_games_conceded,prior_wins) %>%
    pivot_wider(id_cols = c(fixture.id, value), values_from = c(prior_games_goals,prior_games_conceded,prior_wins)) %>%
    ungroup() %>%
    mutate_if( is.numeric ,.funs = na.locf, na.rm = FALSE) %>%
    drop_na()
  
  # Join features back to match level data for home and away teams ####
  new_match_structure.1 <- match_data_seleted %>%
    inner_join(
      new_match_structure.0 %>%
        select(value, fixture.id, hometeams_goals_home = prior_games_goals_teams.home.id, hometeams_goals_away = prior_games_goals_teams.away.id),
      by = c("teams.home.id" = "value", "fixture.id" = "fixture.id")
    ) %>%
    inner_join(
      new_match_structure.0 %>%
        select(value, fixture.id, awayteams_goals_home = prior_games_goals_teams.home.id, awayteams_goals_away = prior_games_goals_teams.away.id),
      by = c("teams.away.id" = "value", "fixture.id" = "fixture.id")) %>%
    mutate(
      target_outcome = factor(
        case_when(
          goals.home > goals.away ~ "home_win",
          goals.away > goals.home ~ "away_win",
          goals.home == goals.away ~ "tie")
      ),
      fix = as.character(fixture.id),
      home_id = as.character(teams.home.id),
      away_id = as.character(teams.away.id)
    )
  
  
  # Add match team level features ####
  
  match_stats_wide <- match_statistics  %>%
    mutate(
      clean_name = remove_non_alpha(type,""),
      clean_value = as.numeric(remove_non_alpha(value,""))
    ) %>%
    unnest(team) %>%
    filter(clean_name != "Assists",clean_name != "CounterAttacks",clean_name != "CrossAttacks",
           clean_name != "FreeKicks",clean_name != "Goals",
           clean_name != "GoalAttempts",clean_name != "Substitutions",
           clean_name != "Throwins",clean_name != "MedicalTreatment") %>%
    pivot_wider(
      id_cols = c(fix, id), 
      names_from = clean_name, 
      values_from = clean_value, 
      values_fill = 0
    ) %>%
    inner_join(
      match_data %>% 
        mutate(
          fix = as.character(fixture.id),
          date = date(fixture.date)
        ) %>%
        select(fix, date),
      by = c("fix" = "fix")
    ) %>%
    mutate(id = as.character(id)) %>%
    group_by(id) %>%
    arrange(date) %>%
    mutate_if(is.numeric, lag_exclude_current) %>%
    ungroup() %>%
    select(-date) %>%
    drop_na()
  
  # Join match statistics data ####
  
  match_model_data <- new_match_structure.1 %>%
    inner_join(match_stats_wide %>% rename_all(paste0,"_home"), by = c("fix" = "fix_home", "home_id" = "id_home")) %>%
    inner_join(match_stats_wide  %>% rename_all(paste0,"_away"), by = c("fix" = "fix_away", "away_id" = "id_away")) %>%
    select(-fix, -away_id, -home_id)

    # #Select model data ####
  
  model_data <- match_model_data %>%
    select(fixture.id, 17:49) %>% 
    select_if(~any(!is.na(.)))
  print("success")
  
 return(model_data)
}
)

print("working")
#Create Train and Test Data Sets + Fit and Predict Models ####
model_and_predict <- reactive(
  {
  # Create match list to Build test and train data sets ####
  match_list <- define_model_data()  %>% 
      group_by(fixture.id) %>%
      summarise()
  
  # define training sample  
  train_matches <- sample_n(match_list,2000)

    
  # Create balanced + normalized train and normalized test data sets #### 
  # next steps; abstract this section so features are list input
    
  train_data <- define_model_data() %>%
    inner_join(train_matches, by = c("fixture.id" = "fixture.id")) %>%
    select(-fixture.id) %>%
    recipe(target_outcome ~ ., data = .) %>%
    step_smote(target_outcome) %>%
    step_normalize(all_predictors()) %>%
    prep(retain = TRUE)
    
    test_data <- define_model_data() %>%
      anti_join(train_matches, by = c("fixture.id" = "fixture.id"))
    
    test_normalize <- bake(train_data, new_data = test_data, all_predictors()) %>%
      bind_cols(test_data %>% select(fixture.id))
    
    # Fit Classification Models ####
    
    # Multi-nomial Regression
    multinomial_regression <-
      multinom_reg() %>%
      set_engine("nnet") %>%
      fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))
    
    # Gradient Boosting Trees
    boost_tree_model <-
      boost_tree(
        mode = "classification",
        trees = 2000
      ) %>%
      set_engine("xgboost") %>%
      fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))
    
    # Random Forest
    random_forest_model <-
      rand_forest(
        mode = "classification",
        trees = 2000
      ) %>%
      set_engine("randomForest") %>%
      fit(target_outcome ~ ., data = bake(train_data, new_data = NULL))
    
    # create feature importance table 
    #random_forest_model$fit$importance
    #feature_importance <- tibble(value = random_forest_model$fit$importance, name = rownames(random_forest_model$fit$importance))
    
    #Predict on holdout data ####
    
    predicted.0 <- bind_rows(
      bind_cols(
        test_data %>% select(fixture.id,target_outcome),
        predict(multinomial_regression, new_data = test_normalize, type = "prob") %>%
          mutate(model = "multinomial regression"),
        predict(multinomial_regression, new_data = test_normalize)
      ),
      bind_cols(
        test_data %>% select(fixture.id,target_outcome),
        predict(boost_tree_model, new_data = test_normalize, type = "prob") %>%
          mutate(model = "boosted trees"),
        predict(boost_tree_model, new_data = test_normalize)
      ),
      bind_cols(
        test_data %>% select(fixture.id,target_outcome),
        predict(random_forest_model, new_data = test_normalize, type = "prob") %>%
          mutate(model = "random forest"),
        predict(random_forest_model, new_data = test_normalize)
      )
    )
    
    predicted <- predicted.0 %>%
      mutate(
        tie = factor(if_else(target_outcome == "tie", 1, 0), levels = c(1,0)),
        home_win = factor(if_else(target_outcome == "home_win", 1,0), levels = c(1,0)),
        away_win = factor(if_else(target_outcome == "away_win", 1,0), levels = c(1,0))
      )
    return(predicted)
  }
)

print("working 2")



# Visualize ROC

roc_curve <- reactive(
  {
    tie_prediction_roc <<- model_and_predict() %>%
      group_by(model) %>%
      yardstick::roc_curve(truth = tie, .pred_tie) %>%
      ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
      geom_path() +
      ggtitle("Tie")+
      geom_abline(lty = 3) +
      coord_equal() + 
      theme(legend.position = "none")
    
    home_win_prediction_roc <<- model_and_predict() %>%
      group_by(model) %>%
      yardstick::roc_curve(truth = home_win, .pred_home_win) %>%
      ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
      geom_path() +
      ggtitle("Home Win")+
      geom_abline(lty = 3) +
      coord_equal() + 
      theme(legend.position = "none")
    
    away_win_prediction_roc <<- model_and_predict() %>%
      group_by(model) %>%
      yardstick::roc_curve(truth = away_win, .pred_away_win) %>%
      ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) +
      geom_path() +
      ggtitle("Away Win")+
      geom_abline(lty = 3) +
      coord_equal()
    
    row_legend <<- cowplot::get_legend(away_win_prediction_roc)
    
    away_win_prediction_roc <<- away_win_prediction_roc +
      theme(legend.position = "none")
    
    output_roc <- cowplot::plot_grid(cowplot::plot_grid(home_win_prediction_roc,tie_prediction_roc,away_win_prediction_roc, nrow = 1), row_legend, nrow= 2)
    return(output_roc)
  }
)

output$roc_curve <- renderPlot({roc_curve()})

print("working 3")

performance_table <- reactive(
  {
    # Performance Stats Summary for model evaluation ####
    performance_stats <<- model_and_predict() %>%
      group_by(model) %>%
      nest(
        class_data = c(fixture.id, target_outcome,.pred_class),
        home_win_data = c(home_win, .pred_home_win),
        away_win_data = c(away_win,.pred_away_win),
        tie_data = c(tie, .pred_tie)
      ) %>%
      mutate(
        accuracy = map(class_data, .f = yardstick::accuracy, truth = target_outcome, .pred_class),
        F1_score = map(class_data, .f = yardstick::f_meas, truth = target_outcome, .pred_class),
        recall = map(class_data, .f = yardstick::recall, truth = target_outcome, .pred_class),
        home_win_auc = map(home_win_data, .f = yardstick::roc_auc, truth = home_win, .pred_home_win),
        away_win_auc = map(away_win_data, .f = yardstick::roc_auc, truth = away_win, .pred_away_win),
        tie_auc = map(tie_data, .f = yardstick::roc_auc, truth = tie, .pred_tie)
      ) %>%
      unnest_wider(c(accuracy, F1_score, recall, home_win_auc, away_win_auc, tie_auc), names_sep = "") %>%
      select(model,contains("estimate")) %>%
      DT::datatable(options = list(dom = 't',  style = "font-size:80%")) %>%
      formatStyle("model", target = 'row',  backgroundColor = bg_color, color = fg_color) %>%
      formatRound(
        columns = c(
          "accuracy.estimate", "F1_score.estimate", 
          "recall.estimate", "home_win_auc.estimate", 
          "away_win_auc.estimate", "tie_auc.estimate"),
        digits = 3)
    
    return(performance_stats)
  }
)

print("working 4")

output$performance_plot <- DT::renderDataTable(performance_table())
modalVisible <- reactiveVal(FALSE)
observeEvent(input$showModal, modalVisible(TRUE))
observeEvent(input$hideModal, modalVisible(FALSE))

output$modal <- renderReact({
  Modal(isOpen = modalVisible(),
        Stack(tokens = list(padding = "15px", childrenGap = "10px"),
              div(style = list(display = "flex"),
                  Text("Title", variant = "large"),
                  div(style = list(flexGrow = 1)),
                  IconButton.shinyInput("hideModal", iconProps = list(iconName = "Cancel")),
              ),
              div(
                p("A paragraph of text."),
                p("Another paragraph.")
                )
              )
  )
  }
  )

home_src <- "https://media.api-sports.io/football/teams/541.png"

output$logo_home_team<-renderText({c('<img src="',home_src,'">')})

away_src <- "https://media.api-sports.io/football/teams/529.png"

output$logo_away_team<-renderText({c('<img src="',away_src,'">')})

print("working 5")
