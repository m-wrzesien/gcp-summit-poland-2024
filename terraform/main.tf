terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
  required_version = "~> 1.9.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0"

  project_id = var.project_id

  activate_apis = [
    "binaryauthorization.googleapis.com",
    "cloudkms.googleapis.com",
    "container.googleapis.com",
    "containerscanning.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 33.0"

  project_id = var.project_id
  regional   = false
  region     = var.region
  zones      = [var.zone]

  name = "demo-cluster"

  network                  = google_compute_network.main.name
  subnetwork               = google_compute_subnetwork.main.name
  ip_range_pods            = google_compute_subnetwork.main.secondary_ip_range[0].range_name
  ip_range_services        = google_compute_subnetwork.main.secondary_ip_range[1].range_name
  service_account          = "create"
  remove_default_node_pool = true
  deletion_protection      = false
  maintenance_start_time   = "00:00"
  maintenance_end_time     = "04:00"

  enable_binary_authorization = true
  network_policy              = true

  node_pools = [
    {
      name         = "node-pool"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 2
      machine_type = "e2-standard-4"
    },
  ]
  depends_on = [module.project-services]
}

module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.2"

  project_id    = var.project_id
  location      = var.location
  format        = "docker"
  repository_id = "docker-repo"

  members = {
    readers = [
      "serviceAccount:${module.gke.service_account}"
    ]
  }

  depends_on = [module.project-services]
}
