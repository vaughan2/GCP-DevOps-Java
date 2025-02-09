# MAIN VPC
resource "google_compute_network" "vpc_network" {
  name                    = "Designer-VPC"
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