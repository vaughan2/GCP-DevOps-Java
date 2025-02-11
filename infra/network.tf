# Internal HTTP load balancer with a managed instance group backend
resource "google_compute_network" "vpc_network" {
  name                    = "designer-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Backend Service
resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  protocol    = "HTTPS"
  timeout_sec = 30
  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
}

# Health Check
resource "google_compute_health_check" "default" {
  name               = "health-check"
  timeout_sec        = 5
  check_interval_sec = 10
  http_health_check {
    port = "80"
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.self_link
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy"
  url_map = google_compute_url_map.default.self_link
}

# Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "cloudrun-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

