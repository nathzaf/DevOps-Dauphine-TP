resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:15" # Utilisation d'une version récente
          env {
            name  = "POSTGRES_USER"
            value = "wordpress"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "securepassword"
          }
          env {
            name  = "POSTGRES_DB"
            value = "wordpress"
          }
          port {
            container_port = 5432
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }
    cluster_ip = "None" # Service interne pour la communication
  }
}
