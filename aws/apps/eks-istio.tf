resource "kubernetes_namespace" "istio-system" {
  metadata {
    annotations = {
      name = "istio-system"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "istio-system"
  }
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("../../values/aws/argocd/argocd_apps_istiod_values.yaml")
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_namespace.istio-system,
    kubernetes_manifest.argocd-github-access,
  ]
}

resource "helm_release" "istio-gateway" {
  name       = "istio-gateway"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  values = [
    file("../../values/aws/argocd/argocd_apps_istio_gateway_values.yaml")
  ]

  depends_on = [
    helm_release.istiod,
  ]
}