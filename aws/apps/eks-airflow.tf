resource "kubernetes_namespace" "airflow" {
  metadata {
    annotations = {
      name = "airflow"
    }

    labels = {
      "argocd.argoproj.io/managed-by" = "argocd"
    }

    name = "airflow"
  }
}

resource "kubernetes_service" "airflow_postgres_external_service" {
  metadata {
    name      = "airflow-postgres-external-service"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  spec {
    type = "ExternalName"

    external_name = data.terraform_remote_state.infra.outputs.aws_db_instance_main_address

    port {
      name        = "postgres"
      port        = 5432
      target_port = data.terraform_remote_state.infra.outputs.aws_db_instance_main_port
    }
  }

  depends_on = [
    kubernetes_namespace.airflow,
  ]
}

resource "helm_release" "airflow" {
  name       = "airflow"
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
        airflow = {
          namespace = "argocd"
          project   = "default"
          sources = [
            {
              chart          = "airflow"
              repoURL        = "https://airflow.apache.org/"
              targetRevision = "1.18.0"
              helm = {
                valueFiles = [
                  "$values/aws/airflow/airflow-values.yaml",
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
            namespace = "airflow"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true",
              "ServerSideApply=true",
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.argo-cd,
    kubernetes_manifest.argocd-github-access,
    kubernetes_namespace.airflow,
    kubernetes_service.airflow_postgres_external_service,
  ]
}