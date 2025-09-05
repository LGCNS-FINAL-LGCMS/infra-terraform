resource "kubernetes_namespace" "backend" {
  metadata {
    annotations = {
      name = "backend"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd",
      "sidecar.istio.io/proxyCPU"     = "50m"
      "sidecar.istio.io/proxyMemory"  = "64Mi"
      "istio-injection"               = "enabled"
    }

    name = "backend"
  }

  depends_on = [
    helm_release.istiod,
  ]
}

locals {
  backend_apps = {
    "backend-auth" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_auth_chart_version,
      external_services = [
        {
          name         = "valkey-auth-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        }
      ]
    },
    "backend-member" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_member_chart_version,
      external_services = [
        {
          name         = "postgres-member-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-member-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-lecture" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_lecture_chart_version,
      external_services = [
        {
          name         = "postgres-lecture-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-core" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_core_chart_version,
      external_services = [
        {
          name         = "postgres-core-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-core-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
        {
          name         = "kafka-external-service"
          internalPort = 9094
          externalIp   = var.my_ip
          externalPort = var.kafka_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-guide" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_guide_chart_version,
      external_services = [
        {
          name         = "postgres-guide-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-lesson" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_lesson_chart_version,
      external_services = [
        {
          name         = "postgres-lesson-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-upload" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_upload_chart_version,
      external_services = []
    },
    "backend-consulting" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_consulting_chart_version,
      external_services = [
        {
          name         = "postgres-consulting-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-consulting-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-leveltest" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_leveltest_chart_version,
      external_services = [
        {
          name         = "postgres-leveltest-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-leveltest-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-payment" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_payment_chart_version,
      external_services = [
        {
          name         = "postgres-payment-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-streaming" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_streaming_chart_version,
      external_services = []
    },
    "backend-notification" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_notification_chart_version,
      external_services = [
        {
          name         = "postgres-notification-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-notification-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
      ]
    },
    "backend-tutor" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = var.backend_tutor_chart_version,
      external_services = [
        {
          name         = "postgres-tutor-external-service"
          internalPort = 5432
          externalIp   = var.my_ip
          externalPort = var.postgres_port
          type         = "ClusterIP"
        },
        {
          name         = "valkey-tutor-external-service"
          internalPort = 6379
          externalIp   = var.my_ip
          externalPort = var.valkey_port
          type         = "ClusterIP"
        },
      ]
    },
  }

  applications = {
    for app_name, app_config in local.backend_apps : app_name => {
      namespace = "argocd"
      project   = "default"
      sources = [
        {
          chart          = app_config.chart
          repoURL        = app_config.repoURL
          targetRevision = app_config.targetRevision
          helm = {
            valueFiles = [
              "$values/local/${app_name}/configmap.yaml",
              "$values/local/${app_name}/secret.yaml",
              "$values/local/${app_name}/values.yaml"
            ]
            valuesObject = {
              externalService = app_config.external_services
            }
          }
        },
        {
          repoURL        = "https://github.com/LGCNS-FINAL-LGCMS/infra-helm-values.git"
          targetRevision = "main"
          ref            = "values"
        }
      ]
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "argocd.argoproj.io/sync-wave=1"
        ]
      }
    }
  }
}

resource "helm_release" "backend_applications" {
  name       = "backend-applications"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = local.applications
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    null_resource.middleware,
    helm_release.istiod,
    kubernetes_namespace.backend,
    helm_release.metrics_server,
    helm_release.prometheus_grafana,
  ]
}