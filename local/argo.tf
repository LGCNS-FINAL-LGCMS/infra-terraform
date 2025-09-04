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
    kubernetes_namespace.argo_ns
  ]
}

resource "helm_release" "istiod" {
  name = "istiod"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argocd-apps"
  version = "2.0.2"
  namespace = "argocd"

  values = [
    file("../values/local/argocd/argocd_apps_istiod_values.yaml")
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.istio-system,
  ]
}

data "http" "istio_operator_crd" {
  url = "https://raw.githubusercontent.com/istio/istio/release-1.20/manifests/charts/base/crds/crd-operator.yaml"
}

module "kube_prometheus_stack_crds" {
  source = "rpadovani/helm-crds/kubectl"
  version = "1.0.0"

  crds_urls = [
    "https://raw.githubusercontent.com/istio/istio/release-1.20/manifests/charts/base/crds/crd-operator.yaml",
  ]
}

resource "helm_release" "istio-gateway" {
  name = "istio-gateway"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argocd-apps"
  version = "2.0.2"
  namespace = "argocd"

  values = [
    file("../values/local/argocd/argocd_apps_istio_gateway_values.yaml")
  ]

  depends_on = [
    helm_release.istiod,
    module.kube_prometheus_stack_crds,
  ]
}
