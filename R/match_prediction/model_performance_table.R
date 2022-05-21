
performance_table <- performance_stats %>%
  rename(
    c(Model = model, Accuracy = accuracy.estimate, `F1 Score` = F1_score.estimate, 
      Recall = recall.estimate, `Home Win AUC` = home_win_auc.estimate, `Away Win AUC` = away_win_auc.estimate,
      `Tie AUC` = tie_auc.estimate)
    ) %>%
  reactable(
    columns = list(
      #Model = colDef(format = colFormat(minWidth = 120)),
      `Accuracy` = colDef(format = colFormat(digits = 2)),
      `F1 Score` = colDef(format = colFormat(digits = 3)),
      `Recall` = colDef(format = colFormat(digits = 3)),
      `Home Win AUC` = colDef(format = colFormat(digits = 2)),
      `Away Win AUC` = colDef(format = colFormat(digits = 2)),
      `Tie AUC` = colDef(format = colFormat(digits = 2))
      ),
    striped = TRUE,
    wrap = FALSE,
    highlight = TRUE,
    resizable = TRUE,
    bordered = TRUE,
    theme = reactableTheme(
      borderColor = "#dfe2e5",
      stripedColor = "#f6f8fa",
      highlightColor = "#f0f5f9",
      cellPadding = "8px 12px",
      style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Gotham Book")
    )
  )

performance_table
