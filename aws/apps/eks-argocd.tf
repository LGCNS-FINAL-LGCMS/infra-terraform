resource "kubernetes_namespace" "argo_ns" {
  metadata {
    annotations = {
      name = "argocd"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "argocd"
  }
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.1.3"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("../../values/aws/argocd/argocd_values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argo_ns,
    helm_release.aws_alb_controller,
  ]
}

resource "kubernetes_manifest" "argocd-github-access" {
  manifest = yamldecode(file("../../values/aws/argocd/argocd_github_secret.yaml"))
  depends_on = [
    kubernetes_namespace.argo_ns,
  ]
}
