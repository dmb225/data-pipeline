output "pubsub_topic" {
  value = google_pubsub_topic.topic.name
}

output "cloudsql_instance" {
  value = google_sql_database_instance.postgres_instance.connection_name
}

output "function_url" {
  value = google_cloudfunctions_function.function.https_trigger_url
}
