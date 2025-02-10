# MAIN VPC
resource "google_compute_network" "vpc_network" {
  name                    = "designer-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}
# Artifact Registry
resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "test-registry"
  description   = "quarkus container registry"
  format        = "DOCKER"
}
# Storage Bucket
resource "google_storage_bucket" "static-site" {
  name          = "cloud-build-logs12991"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

}
resource "google_sql_database_instance" "main" {
  name             = "main-instance-tf"
  database_version = "POSTGRES_17"
  region           = "us-central1"


  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier    = "db-f1-micro"
    edition = "ENTERPRISE"
  }
}
resource "google_cloud_run_v2_service" "default" {
  name                = "cloudrun-service-java-quarkus"
  location            = "us-central1"
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  template {
    containers {
      image = "us-central1-docker.pkg.dev/test-architect-449613/test-registry/terst-quarkus"

env {
        name  = "DB_USERNAME"
        value = "quarkus"
      }
      env {
        name  = "DB_URL"
        value = "jdbc:postgresql://34.121.225.168"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.secret.secret_id
            version = "1"
          }
        }
      }
      # volume_mounts {
      #   name       = "cloudsql"
      #   mount_path = "/cloudsql"
      # }
    }
  }
}
data "google_project" "project" {
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "psql_db_password"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "secret-version-data" {
  secret = google_secret_manager_secret.secret.name
  secret_data = "secret-data"
}
resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret]
}