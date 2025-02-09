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

  uniform_bucket_level_access = true

}

# resource "google_cloud_run_v2_service" "default" {
#   name     = "cloudrun-service-java-quarkus"
#   location = "us-central1"
#   deletion_protection = false
#   ingress = "INGRESS_TRAFFIC_ALL"

#   template {
#     containers {
#       image = "us-docker.pkg.dev/cloudrun/container/hello"
#     }
#   }
# }