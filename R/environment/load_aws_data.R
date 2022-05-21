# load aws data

match_data <- tbl(athena_personal,in_schema("pitch-prophet","match_data")) %>%
  collect()

match_statistics <- tbl(athena_personal,in_schema("pitch-prophet","match_statistics"))  %>%
  collect()