# GIT pat stored in gdoc (also in notes to be removed from )

# clean names functions:
remove_non_alpha <- function(x,y) {gsub("[^[:alnum:]]", paste(y), str_trim(x))}

# Lagged sum minus current (to be used with arange(date))
#this should use the shiny input$

lag_exclude_current <- function(x) {
  rollsum(
    x,
    k = 3, # <- change here to use shiny input
    align = "right", 
    fill = NA
  ) - x
}

#normalize between 0 and 1
normalize <- function(x) {(x - min(x))/ (max(x)-min(x))}

# preferences (I hate this unnecessary notation) ####
options(scipen = 100000000)
