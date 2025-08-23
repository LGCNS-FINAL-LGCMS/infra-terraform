resource "kubernetes_namespace" "backend" {
  metadata {
    annotations = {
      name = "backend"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
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
      targetRevision = "0.0.6",
      external_services = [
        {
          name         = "valkey-auth-external-service"
          internalPort = 6379
          externalName = data.terraform_remote_state.infra.outputs.aws_cache_main_address
          externalPort = data.terraform_remote_state.infra.outputs.aws_cache_main_port
        }
      ]
    },
    "backend-member" = {
      repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages",
      chart          = "spring-chart",
      targetRevision = "0.0.6",
      external_services = [
        {
          name         = "postgres-member-external-service"
          internalPort = 5432
          externalName = data.terraform_remote_state.infra.outputs.aws_db_instance_main_address
          externalPort = data.terraform_remote_state.infra.outputs.aws_db_instance_main_port
        },
        {
          name         = "valkey-member-external-service"
          internalPort = 6379
          externalName = data.terraform_remote_state.infra.outputs.aws_cache_main_address
          externalPort = data.terraform_remote_state.infra.outputs.aws_cache_main_port
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
              "$values/aws/${app_name}/configmap.yaml",
              "$values/aws/${app_name}/secret.yaml",
              "$values/aws/${app_name}/values.yaml"
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
        syncOptions = ["CreateNamespace=true"]
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
    helm_release.istiod,
    kubernetes_namespace.backend,
  ]
}