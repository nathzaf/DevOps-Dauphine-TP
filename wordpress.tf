resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "postgres"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "wordpress"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "securepassword"
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = "wordpress"
          }
          env {
            name  = "WORDPRESS_DB_TYPE"
            value = "pgsql"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }
  spec {
    selector = {
      app = "wordpress"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}


