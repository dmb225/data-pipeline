variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region"
  default     = "europe-west9" # Paris
}

variable "region_for_cloud_functions" {
  description = "Region for cloud function"
  default     = "europe-west1" # Belgium (Paris not always available for Cloud Functions)
}

variable "db_name" {
  description = "Postgres database name"
  default     = "data_pipeline"
}

variable "db_user" {
  description = "Postgres username"
  default     = "postgres"
}

variable "db_password" {
  description = "Postgres password"
  type        = string
}
