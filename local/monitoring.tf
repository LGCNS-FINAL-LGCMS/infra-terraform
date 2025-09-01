resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    name = "monitoring"
  }
}

resource "helm_release" "monitoring" {
  name = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "77.1.0"
  namespace = "monitoring"

  values = [
    file("../values/local/monitoring/prometheus-grafana-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "loki" {
  name = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki"
  version = "6.38.0"
  namespace = "monitoring"

  values = [
    file("../values/local/monitoring/loki-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "tempo" {
  name = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart = "tempo"
  version = "1.23.3"
  namespace = "monitoring"

  values = [
    file("../values/local/monitoring/tempo-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "otel-collector" {
  name = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart = "opentelemetry-collector"
  version = "0.132.0"
  namespace = "monitoring"

  values = [
    file("../values/local/monitoring/otel-collector-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}

resource "helm_release" "kiali-server" {
  name = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart = "kiali-server"
  version = "2.14.0"
  namespace = "istio-system"

  values = [
    file("../values/local/monitoring/kiali-server-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}