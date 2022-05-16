arrow::write_parquet(match_statistics, "match_statistics.parquet")


athena_pitch_prophet <- 
  DBI::dbConnect(
    noctua::athena(),
    aws_access_key_id = Sys.getenv("pitch_prophet_key"),
    aws_secret_access_key = Sys.getenv("pitch_prophet_secret"),
    s3_staging_dir = "s3://the-pitch-prophet/data/"
  )

