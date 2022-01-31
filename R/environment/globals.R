

# clean names functions:
remove_non_alpha <- function(x,y) {gsub("[^[:alnum:]]", paste(y), str_trim(x))}

# preferences ####
options(scipen = 100000000)
