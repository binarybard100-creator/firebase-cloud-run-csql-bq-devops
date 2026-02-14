resource "google_project_service" "services" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "bigquery.googleapis.com"
  ])
  service = each.value
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "app-repo"
  format        = "DOCKER"
}

resource "google_sql_database_instance" "postgres" {
  name             = "mini-postgres"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = false
    }
  }
  deletion_protection = false
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "appanalytics"
  location   = var.region
}

resource "google_cloud_run_service" "backend" {
  name     = "mini-backend"
  location = var.region

  template {
    metadata {
      labels = {
        environment = var.env
        owner       = "mandy"
      }
    }
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }

  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloudbuild_trigger" "github_trigger" {
  name = "backend-auto-deploy"

  github {
    owner = "binarybard100-creator"
    name  = "firebase-cloud-run-csql-bq-devops"

    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
# gcloud beta builds triggers create github \
#   --repo-name= \
#   --repo-owner=YOUR_GITHUB \
#   --branch-pattern="^main$" \
#   --build-config=cloudbuild.yaml