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
}

resource "helm_release" "argo-cd" {
  name = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "8.1.3"
  namespace = "argocd"

  values = [
    file("../values/local/argocd/argocd_values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argo_ns
  ]
}

resource "kubernetes_manifest" "argocd-github-access" {
  manifest = yamldecode(file("../values/local/argocd/argocd_github_secret.yaml"))
  depends_on = [
    kubernetes_namespace.argo_ns,
    kubernetes_namespace.backend
  ]
}

resource "helm_release" "argocd-apps" {
  name = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argocd-apps"
  version = "2.0.2"
  namespace = "argocd"

  values = [
    file("../values/local/argocd/argocd_apps_values.yaml")
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
  ]
}