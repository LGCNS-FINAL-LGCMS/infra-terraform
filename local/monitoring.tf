resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    name = "monitoring"
  }
}

resource "helm_release" "prometheus_grafana" {
  name       = "prometheus-grafana"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        prometheus-grafana = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "kube-prometheus-stack"
              repoURL        = "https://prometheus-community.github.io/helm-charts"
              targetRevision = "77.1.0"
              helm = {
                valueFiles = [
                  "$values/local/monitoring/prometheus-grafana-values.yaml"
                ]
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        loki = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "loki"
              repoURL        = "https://grafana.github.io/helm-charts"
              targetRevision = "6.38.0"
              helm = {
                valueFiles = [
                  "$values/local/monitoring/loki-values.yaml"
                ]
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        promtail = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "promtail"
              repoURL        = "https://grafana.github.io/helm-charts"
              targetRevision = "6.17.0"
              helm = {
                valueFiles = [
                  "$values/local/monitoring/promtail-values.yaml"
                ]
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        tempo = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "tempo"
              repoURL        = "https://grafana.github.io/helm-charts"
              targetRevision = "1.23.3"
              helm = {
                valueFiles = [
                  "$values/local/monitoring/tempo-values.yaml"
                ]
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "otel-collector" {
  name       = "otel-collector"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    yamlencode({
      applications = {
        otel-collector = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "opentelemetry-collector"
              repoURL        = "https://open-telemetry.github.io/opentelemetry-helm-charts"
              targetRevision = "0.132.0"
              helm = {
                valueFiles = [
                  "$values/local/monitoring/otel-collector-values.yaml"
                ]
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
            namespace = "monitoring"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
              "argocd.argoproj.io/sync-wave=0"
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.monitoring,
  ]
}

# resource "helm_release" "otel-collector" {
#   name = "otel-collector"
#   repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#   chart = "opentelemetry-collector"
#   version = "0.132.0"
#   namespace = "monitoring"
#
#   values = [
#     file("../values/local/monitoring/otel-collector-values.yaml")
#   ]
#
#   depends_on = [
#     kubernetes_namespace.monitoring,
#   ]
# }
#
# resource "helm_release" "kiali-server" {
#   name = "kiali-server"
#   repository = "https://kiali.org/helm-charts"
#   chart = "kiali-server"
#   version = "2.14.0"
#   namespace = "istio-system"
#
#   values = [
#     file("../values/local/monitoring/kiali-server-values.yaml")
#   ]
#
#   depends_on = [
#     kubernetes_namespace.monitoring,
#   ]
# }