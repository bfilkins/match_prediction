

athena_personal <- 
  DBI::dbConnect(
    noctua::athena(),
    aws_access_key_id = Sys.getenv("pitch_prophet_key"),
    aws_secret_access_key =Sys.getenv("pitch_prophet_secret"),
    s3_staging_dir = "s3://the-pitch-prophet/",
    region = "us-east-1"
  )

