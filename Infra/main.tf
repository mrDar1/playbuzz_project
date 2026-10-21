# 1. Local cluster: minikube on Docker -> 1 control-plane + 2 workers.
resource "minikube_cluster" "this" {
  cluster_name = var.cluster_name
  driver       = "docker"
  nodes        = var.node_count
  cpus         = var.cpus
  memory       = "${var.memory}mb"
  wait         = ["apiserver", "system_pods", "default_sa", "apps_running", "node_ready", "kubelet"]
}

# Helm talks to the cluster using the credentials minikube just generated.
provider "helm" {
  kubernetes = {
    host                   = minikube_cluster.this.host
    cluster_ca_certificate = minikube_cluster.this.cluster_ca_certificate
    client_certificate     = minikube_cluster.this.client_certificate
    client_key             = minikube_cluster.this.client_key
  }
}

# 2. Ingress controller (NodePort: minikube has no cloud load balancer).
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_chart_version

  values = [yamlencode({
    controller = {
      service = { type = "NodePort" }
    }
  })]
}

# 3. Argo CD.
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  # Argo CD's argocd-server serves HTTPS by default; "insecure" = plain HTTP so
  # it works behind the ingress / port-forward without a TLS certificate.
  values = [yamlencode({
    configs = {
      params = { "server.insecure" = true }
    }
  })]

  depends_on = [helm_release.ingress_nginx]
}
