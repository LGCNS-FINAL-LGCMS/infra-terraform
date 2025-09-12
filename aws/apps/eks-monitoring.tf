resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "monitoring"
  }
}

data "aws_ebs_volume" "prometheus" {
  most_recent = true

  filter {
    name = "volume-type"
    values = [data.terraform_remote_state.infra-ebs.outputs.prometheus_ebs_type]
  }

  filter {
    name = "tag:Name"
    values = [data.terraform_remote_state.infra-ebs.outputs.prometheus_tag_Name]
  }
}

resource "kubernetes_persistent_volume" "prometheus-pv" {
  metadata {
    name = "prometheus-pv"
    labels = {
      name = "prometheus-pv"
    }
  }

  spec {
    capacity = {
      storage = "${data.aws_ebs_volume.prometheus.size}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = ""

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values = [data.aws_ebs_volume.prometheus.availability_zone]
          }
        }
      }
    }

    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = data.aws_ebs_volume.prometheus.id
        fs_type       = "ext4"
      }
    }
  }
}

data "aws_ebs_volume" "grafana" {
  most_recent = true

  filter {
    name = "volume-type"
    values = [data.terraform_remote_state.infra-ebs.outputs.grafana_ebs_type]
  }

  filter {
    name = "tag:Name"
    values = [data.terraform_remote_state.infra-ebs.outputs.grafana_tag_Name]
  }
}

resource "kubernetes_persistent_volume" "grafana-pv" {
  metadata {
    name = "grafana-pv"
    labels = {
      name = "grafana-pv"
    }
  }

  spec {
    capacity = {
      storage = "${data.aws_ebs_volume.grafana.size}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = ""

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values = [data.aws_ebs_volume.grafana.availability_zone]
          }
        }
      }
    }

    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = data.aws_ebs_volume.grafana.id
        fs_type       = "ext4"
      }
    }
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
                  "$values/aws/monitoring/prometheus-grafana-values.yaml"
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
    kubernetes_persistent_volume.grafana-pv,
    kubernetes_persistent_volume.prometheus-pv,
  ]
}

data "aws_ebs_volume" "loki" {
  most_recent = true

  filter {
    name = "volume-type"
    values = [data.terraform_remote_state.infra-ebs.outputs.loki_ebs_type]
  }

  filter {
    name = "tag:Name"
    values = [data.terraform_remote_state.infra-ebs.outputs.loki_tag_Name]
  }
}

resource "kubernetes_persistent_volume" "loki-pv" {
  metadata {
    name = "loki-pv"
    labels = {
      name = "loki-pv"
    }
  }

  spec {
    capacity = {
      storage = "${data.aws_ebs_volume.loki.size}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = ""

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values = [data.aws_ebs_volume.loki.availability_zone]
          }
        }
      }
    }

    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = data.aws_ebs_volume.loki.id
        fs_type       = "ext4"
      }
    }
  }
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
                  "$values/aws/monitoring/loki-values.yaml"
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
    kubernetes_persistent_volume.loki-pv,
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
                  "$values/aws/monitoring/promtail-values.yaml"
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

data "aws_ebs_volume" "tempo" {
  most_recent = true

  filter {
    name = "volume-type"
    values = [data.terraform_remote_state.infra-ebs.outputs.tempo_ebs_type]
  }

  filter {
    name = "tag:Name"
    values = [data.terraform_remote_state.infra-ebs.outputs.tempo_tag_Name]
  }
}

resource "kubernetes_persistent_volume" "tempo-pv" {
  metadata {
    name = "tempo-pv"
    labels = {
      name = "tempo-pv"
    }
  }

  spec {
    capacity = {
      storage = "${data.aws_ebs_volume.tempo.size}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = ""

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "topology.kubernetes.io/zone"
            operator = "In"
            values = [data.aws_ebs_volume.tempo.availability_zone]
          }
        }
      }
    }

    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = data.aws_ebs_volume.tempo.id
        fs_type       = "ext4"
      }
    }
  }
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
                  "$values/aws/monitoring/tempo-values.yaml"
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
    kubernetes_persistent_volume.tempo-pv
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
                  "$values/aws/monitoring/otel-collector-values.yaml"
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

resource "helm_release" "kiali-server" {
  name       = "kiali-server"
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
        kiali-server = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "kiali-server"
              repoURL        = "https://kiali.org/helm-charts"
              targetRevision = "2.14.0"
              helm = {
                valueFiles = [
                  "$values/aws/monitoring/kiali-server-values.yaml"
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
            namespace = "istio-system"
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