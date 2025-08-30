provider "google" {
  project = var.project_id
  region  = var.region
}

# --------------------
# Pub/Sub
# --------------------
resource "google_pubsub_topic" "topic" {
  name = "dummy-topic"
}

# --------------------
# Cloud SQL (Postgres)
# --------------------
resource "google_sql_database_instance" "postgres_instance" {
  name             = "data-pipeline-sql"
  database_version = "POSTGRES_17"
  region           = var.region

  settings {
    tier = "db-f1-micro" # Free tier / cheapest
  }
}

resource "google_sql_database" "postgres_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

# --------------------
# Cloud Function
# --------------------
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-bucket"
  location = var.region
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/../cloud_function/function-source.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "pubsub-to-sql"
  runtime     = "python312"
  entry_point = "pubsub_handler"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic.name
  }
  environment_variables = {
    POSTGRES_HOST     = google_sql_database_instance.postgres_instance.connection_name
    POSTGRES_DB       = var.db_name
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
  }
}
