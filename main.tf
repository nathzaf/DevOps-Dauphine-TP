resource "google_project_service" "ressource_manager" {
    service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "ressource_usage" {
    for_each = toset(["serviceusage.googleapis.com"])
    service = "serviceusage.googleapis.com"
    depends_on = [ google_project_service.ressource_manager ]
}

resource "google_project_service" "artifact" {
    service = "artifactregistry.googleapis.com"
    depends_on = [ google_project_service.ressource_manager ]
}

resource "google_artifact_registry_repository" "demo-repo" {
  location      = "us-central1"
  repository_id = "demo-repository"
  description   = "Exemple de repo Docker"
  format        = "DOCKER"

  depends_on = [ google_project_service.artifact ]
}

resource "google_storage_bucket" "default" {
    name          = "devops-tp1-tfstate" 
    location      = "US"
    force_destroy = true
}

resource "google_sql_database" "database" {
  name     = "wordpress"
  instance = "main-instance"
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instance" {
  name             = "main-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0_31"
  settings {
    tier = "db-f1-micro"
  }


  deletion_protection  = true
}

resource "google_sql_user" "wordpress" {
   name     = "wordpress"
   instance = "main-instance"
   password = "ilovedevops"
}

resource "google_cloud_run_service" "wordpress" {
  name     = "my-wordpress"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/devops-tp1/demo-repository/wp-db:0.2"
        ports {
          container_port = 80
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
   binding {
      role = "roles/run.invoker"
      members = [
         "allUsers",
      ]
   }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = "us-central1"
   project     = "devops-tp1"
   service     = "my-wordpress"

   policy_data = data.google_iam_policy.noauth.policy_data

   depends_on = [google_cloud_run_service.wordpress]
}


data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = "gke-dauphine"
  location = "us-central1-a"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
}

