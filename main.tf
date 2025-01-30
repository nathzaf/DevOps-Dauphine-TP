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