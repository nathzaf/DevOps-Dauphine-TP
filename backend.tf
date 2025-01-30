terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.21"
    }
  }

  backend "gcs" {
    bucket = "devops-tp1-tfstate"
  }

  required_version = ">= 1.0"
}


provider "google" {
    project = "devops-tp1"
}