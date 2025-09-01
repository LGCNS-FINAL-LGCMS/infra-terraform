resource "kubernetes_namespace" "frontend" {
  metadata {
    annotations = {
      name = "frontend"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "frontend"
  }
}

resource "helm_release" "frontend_application" {
  name       = "frontend-application"
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
        frontend = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "nginx-chart"
              repoURL        = "https://lgcns-final-lgcms.github.io/infra-helm-packages"
              targetRevision = var.frontend_chart_version
              helm = {
                valueFiles = [
                  "$values/aws/frontend/values.yaml"
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
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.frontend,
  ]
}