
resource "kubernetes_deployment" "tenant_svc" {
  metadata {
    name      = "tenant-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "tenant-svc"
      }
    }

    template {
      metadata {
        labels = {
          app                           = "tenant-svc"
          "azure.workload.identity/use" = "true"
        }
      }

      spec {
        service_account_name = "workload"

        node_selector = {
          agentpool = "npworkload"
        }

        container {
          name  = "tenant-svc"
          image = "${var.container_registry}/${var.tenant_svc_image.name}:${var.tenant_svc_image.version}"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.tenant_svc.metadata.0.name
            }
          }

          resources {
            requests = {
              memory = "5Gi"
            }
            limits = {
              memory = "5Gi"
            }
          }

          port {
            container_port = 80
          }

          liveness_probe {
            http_get {
              path = "/api/Tenant/healthz/live"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 20
          }

          readiness_probe {
            http_get {
              path = "/api/Tenant/healthz/ready"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 20
          }

          volume_mount {
            name       = "secrets-store01-inline"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }

          env {
            name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.shared_secrets.manifest.spec.secretObjects.0.secretName
                key  = "app-insights-connection-string"
              }
            }
          }

          // Additional environment variables omitted for brevity
        }

        volume {
          name = "secrets-store01-inline"

          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true

            volume_attributes = {
              secretProviderClass = kubernetes_manifest.shared_secrets.manifest.metadata.name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tenant_svc" {
  metadata {
    name      = "tenant-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = kubernetes_deployment.tenant_svc.metadata.0.name
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "tenant_svc" {
  metadata {
    name      = "tenant-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/api/Tenant"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.tenant_svc.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "tenant_svc" {
  metadata {
    name      = "tenant-svc-config"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  data = {
    HELLO_WORLD          = "Azure Terraformer"
    "CosmosDb__Endpoint" = var.cosmos_endpoint
    "CosmosDb__Database" = var.tenant_svc_database
  }

}